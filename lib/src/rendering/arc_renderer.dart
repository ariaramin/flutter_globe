import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../math/globe_projection.dart';
import '../math/great_circle.dart';
import '../math/matrix3d.dart';
import '../math/quaternion.dart';
import '../math/vector3.dart';
import '../models/globe_arc.dart';
import '../themes/globe_style_models.dart';

/// Canvas renderer for elevated great-circle arcs with animated traveling highlights.
class ArcRenderer {
  ArcRenderer() {
    _screenX = Float32List(_maxSampleResolution);
    _screenY = Float32List(_maxSampleResolution);
    _depths = Float32List(_maxSampleResolution);
    _scales = Float32List(_maxSampleResolution);
  }

  static const int _maxSampleResolution = 72;
  final Map<(GlobeArc, int), List<Vector3D>> _arcPointCache =
      <(GlobeArc, int), List<Vector3D>>{};

  late final Float32List _screenX;
  late final Float32List _screenY;
  late final Float32List _depths;
  late final Float32List _scales;

  final Path _baseLinePath = Path();
  final Path _dashPath = Path();

  final Paint _baseLinePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final Paint _dashPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final Paint _headGlowPaint = Paint()..isAntiAlias = true;
  final Paint _headCorePaint = Paint()..isAntiAlias = true;

  /// Draws a list of [arcs] with 3D projection, depth occlusion, and traveling animations.
  void draw({
    required Canvas canvas,
    required GlobeCamera camera,
    required Quaternion3D rotation,
    required List<GlobeArc> arcs,
    required double animationTimeMs,
    required GlobeQuality quality,
    double opacityMultiplier = 1.0,
    double Function(int arcIndex)? arcRevealProgressProvider,
  }) {
    if (arcs.isEmpty || opacityMultiplier <= 0.0) return;

    for (var i = 0; i < arcs.length; i++) {
      final arc = arcs[i];
      final reveal = arcRevealProgressProvider?.call(i) ?? 1.0;
      if (reveal <= 0.0) continue;

      _drawSingleArc(
        canvas: canvas,
        camera: camera,
        rotation: rotation,
        arc: arc,
        animationTimeMs: animationTimeMs,
        sampleResolution: switch (quality) {
          GlobeQuality.low => 24,
          GlobeQuality.medium => 36,
          GlobeQuality.high => 54,
          GlobeQuality.ultra => 72,
          GlobeQuality.auto => 36,
        },
        opacityMultiplier: opacityMultiplier * reveal,
        revealFactor: reveal,
      );
    }
  }

  void _drawSingleArc({
    required Canvas canvas,
    required GlobeCamera camera,
    required Quaternion3D rotation,
    required GlobeArc arc,
    required double animationTimeMs,
    required int sampleResolution,
    required double opacityMultiplier,
    required double revealFactor,
  }) {
    // Retrieve or compute cached 3D geodesic arc points
    final cacheKey = (arc, sampleResolution);
    var rawPoints = _arcPointCache[cacheKey];
    if (rawPoints == null) {
      if (_arcPointCache.length > 500) {
        _arcPointCache.clear();
      }
      rawPoints = GreatCircle.generateArcPoints(
        start: arc.start.toVector3D(),
        end: arc.end.toVector3D(),
        sampleCount: sampleResolution,
        maxAltitude: arc.altitude,
      );
      _arcPointCache[cacheKey] = rawPoints;
    }

    final totalPoints = rawPoints.length;
    final visibleCount = revealFactor < 1.0
        ? math.max(2, (totalPoints * revealFactor).round())
        : totalPoints;

    final qx = rotation.x;
    final qy = rotation.y;
    final qz = rotation.z;
    final qw = rotation.w;

    final cx = camera.center.dx;
    final cy = camera.center.dy;
    final radius = camera.radius;
    final altitude = camera.altitude;
    final isOrthographic = camera.projection == GlobeProjection.orthographic;
    final radiusAltitude = radius * altitude;

    // Project into the preallocated Float32List buffers.
    for (var i = 0; i < visibleCount; i++) {
      final pt = rawPoints[i];
      final vx = pt.x;
      final vy = pt.y;
      final vz = pt.z;

      final tx = 2.0 * (qy * vz - qz * vy);
      final ty = 2.0 * (qz * vx - qx * vz);
      final tz = 2.0 * (qx * vy - qy * vx);

      final rx = vx + qw * tx + (qy * tz - qz * ty);
      final ry = vy + qw * ty + (qz * tx - qx * tz);
      final rz = vz + qw * tz + (qx * ty - qy * tx);

      final double scale;
      if (isOrthographic) {
        scale = 1.0;
        _screenX[i] = cx + rx * radius;
        _screenY[i] = cy + ry * radius;
      } else {
        final denom = math.max(0.1, altitude - rz);
        scale = altitude / denom;
        final rScale = radiusAltitude / denom;
        _screenX[i] = cx + rx * rScale;
        _screenY[i] = cy + ry * rScale;
      }

      _depths[i] = rz;
      _scales[i] = scale;
    }

    if (visibleCount < 2) return;

    // 1. Draw Static Base Trajectory Line
    if (arc.showBaseLine && arc.baseLineOpacity > 0.0) {
      _drawBaseLine(canvas, visibleCount, arc, opacityMultiplier);
    }

    // 2. Draw Animated Traveling Dash Highlight
    _drawTravelingDash(
      canvas,
      visibleCount,
      arc,
      animationTimeMs,
      opacityMultiplier,
    );
  }

  void _drawBaseLine(
    Canvas canvas,
    int count,
    GlobeArc arc,
    double opacityMultiplier,
  ) {
    _baseLinePath.reset();
    var hasStarted = false;
    var scaleSum = 0.0;

    for (var i = 0; i < count; i++) {
      final depth = _depths[i];
      scaleSum += _scales[i];

      // Fade out points behind the globe horizon
      if (depth < -0.15) {
        hasStarted = false;
        continue;
      }

      final sx = _screenX[i];
      final sy = _screenY[i];

      if (!hasStarted) {
        _baseLinePath.moveTo(sx, sy);
        hasStarted = true;
      } else {
        _baseLinePath.lineTo(sx, sy);
      }
    }

    if (!hasStarted) return;

    final avgScale = scaleSum / count;
    _baseLinePaint
      ..color = arc.color
          .withValues(alpha: arc.baseLineOpacity * 0.7 * opacityMultiplier)
      ..strokeWidth = math.max(1.0, arc.strokeWidth * 0.65 * avgScale);

    canvas.drawPath(_baseLinePath, _baseLinePaint);
  }

  void _drawTravelingDash(
    Canvas canvas,
    int count,
    GlobeArc arc,
    double animationTimeMs,
    double opacityMultiplier,
  ) {
    final durationMs = arc.duration.inMilliseconds.toDouble();
    final delayMs = arc.delay.inMilliseconds.toDouble();

    if (animationTimeMs < delayMs || durationMs <= 0.0) return;

    final rawElapsed = animationTimeMs - delayMs;
    final elapsed = arc.repeat
        ? rawElapsed % durationMs
        : rawElapsed.clamp(0.0, durationMs);
    final progress = elapsed / durationMs; // 0.0 to 1.0

    final dashLength = arc.dashLength.clamp(0.05, 0.9);
    final headIndexFloat = progress * (count - 1);
    final tailIndexFloat = math.max(0.0, (progress - dashLength) * (count - 1));

    final startIndex = tailIndexFloat.floor();
    final endIndex = math.min(count - 1, headIndexFloat.ceil());

    if (startIndex >= endIndex) return;

    final startColor = arc.startColor ?? arc.color;
    final endColor = arc.endColor ?? arc.color;
    final strokeBase = arc.strokeWidth;
    final hasColorGradient = startColor != endColor;

    // Draw sub-segments of the dash with head-to-tail alpha gradient
    for (var i = startIndex; i < endIndex; i++) {
      final depth1 = _depths[i];
      final depth2 = _depths[i + 1];

      // Occlusion check
      final avgDepth = (depth1 + depth2) * 0.5;
      if (avgDepth < -0.15) continue;

      final limbAlpha = ((avgDepth + 0.15) / 0.25).clamp(0.0, 1.0);

      // Dash gradient factor: 0.0 at tail to 1.0 at head
      final segmentFraction =
          (i - tailIndexFloat) / (headIndexFloat - tailIndexFloat);
      final dashAlpha = segmentFraction.clamp(0.0, 1.0);

      final alpha = (dashAlpha * dashAlpha * limbAlpha * opacityMultiplier)
          .clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      final avgScale = (_scales[i] + _scales[i + 1]) * 0.5;
      final Color segColor;
      if (hasColorGradient) {
        segColor =
            Color.lerp(startColor, endColor, i / (count - 1)) ?? arc.color;
      } else {
        segColor = arc.color;
      }

      _dashPaint
        ..color = segColor.withValues(alpha: alpha)
        ..strokeWidth =
            math.max(1.2, strokeBase * (0.6 + 0.6 * dashAlpha) * avgScale);

      _dashPath.reset();
      _dashPath.moveTo(_screenX[i], _screenY[i]);
      _dashPath.lineTo(_screenX[i + 1], _screenY[i + 1]);
      canvas.drawPath(_dashPath, _dashPaint);
    }

    // Glowing highlight circle at the head of the dash (reference comet head)
    final headIndex = math.min(count - 1, headIndexFloat.round());
    final headDepth = _depths[headIndex];

    if (headDepth >= -0.05) {
      final headAlpha =
          (((headDepth + 0.05) / 0.2).clamp(0.0, 1.0)) * opacityMultiplier;
      final headColor = arc.endColor ?? arc.color;
      final headScale = _scales[headIndex];
      final headOffset = Offset(_screenX[headIndex], _screenY[headIndex]);

      // Glow halo
      _headGlowPaint.color = headColor.withValues(alpha: 0.45 * headAlpha);
      canvas.drawCircle(
        headOffset,
        arc.glowRadius * headScale * 1.8,
        _headGlowPaint,
      );

      // Bright core point
      _headCorePaint.color = Colors.white.withValues(alpha: 0.95 * headAlpha);
      canvas.drawCircle(
        headOffset,
        arc.strokeWidth * headScale * 0.7,
        _headCorePaint,
      );
    }
  }
}
