import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../math/globe_projection.dart';
import '../math/matrix3d.dart';
import '../math/quaternion.dart';
import '../models/globe_style.dart';
import '../themes/globe_style_models.dart';
import 'land_data.dart';

/// Batched Canvas renderer for geographic land dots.
/// Uses [Canvas.drawRawPoints] with pre-allocated [Float32List] buffers to render
/// land points in up to six Canvas point batches. Backend GPU calls and allocations
/// depend on the Flutter renderer.
class DotsRenderer {
  DotsRenderer() {
    for (var i = 0; i < _kBucketCount; i++) {
      _buffers[i] = Float32List(LandData.pointCount * 2);
    }
  }

  static const int _kBucketCount = 6;
  final List<Float32List> _buffers =
      List<Float32List>.filled(_kBucketCount, Float32List(0));
  final List<int> _counts = List<int>.filled(_kBucketCount, 0);

  final Paint _batchPaint = Paint()
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round;

  /// Draws all rotated land points onto [canvas] using batched GPU draw calls.
  void draw(
    Canvas canvas,
    GlobeCamera camera,
    Quaternion3D rotation,
    GlobeStyle style, {
    GlobeSurfaceStyle? surfaceOverride,
    GlobeQuality quality = GlobeQuality.auto,
    double opacityMultiplier = 1.0,
  }) {
    if (opacityMultiplier <= 0.0) return;

    final raw = LandData.rawCoords;
    const pointCount = LandData.pointCount;
    final center = camera.center;
    final radius = camera.radius;
    final altitude = camera.altitude;
    final isOrthographic = camera.projection == GlobeProjection.orthographic;

    final surface = surfaceOverride;
    final baseColor = surface?.landColor ?? style.neutralColor;
    final baseSize = surface?.pointSize ?? style.pointSize;
    final basePointOpacity = surface?.pointOpacity ?? style.pointOpacity;
    final rearOpacity = surface?.rearPointOpacity ?? style.rearPointOpacity;
    final globeOpacity =
        (surface?.globeOpacity ?? style.globeOpacity) * opacityMultiplier;

    final lightDir = style.lightDirection.normalized;
    final lx = lightDir.x;
    final ly = lightDir.y;
    final lz = lightDir.z;
    final ambient = style.ambientLight;
    final diffuseWeight = style.diffuseLight;

    // Pre-calculate loop invariants
    final radiusAltitude = radius * altitude;
    final frontBaseAlpha = basePointOpacity * globeOpacity;
    final rearBaseAlpha = rearOpacity * 0.4 * globeOpacity;

    // Determine sampling step based on quality profile
    final step = switch (quality) {
      GlobeQuality.low => 4,
      GlobeQuality.medium => 2,
      GlobeQuality.high || GlobeQuality.ultra => 1,
      GlobeQuality.auto => radius < 180 ? 4 : 2,
    };

    // Reset buffer counters
    for (var i = 0; i < _kBucketCount; i++) {
      _counts[i] = 0;
    }

    // Quaternion components for fast inline rotation
    final qx = rotation.x;
    final qy = rotation.y;
    final qz = rotation.z;
    final qw = rotation.w;

    final cx = center.dx;
    final cy = center.dy;

    const bucketMaxIndex = _kBucketCount - 1;

    for (var i = 0; i < pointCount; i += step) {
      final offset = i * 3;
      final vx = raw[offset];
      final vy = raw[offset + 1];
      final vz = raw[offset + 2];

      // Fast inline quaternion rotation (0 allocations)
      final tx = 2.0 * (qy * vz - qz * vy);
      final ty = 2.0 * (qz * vx - qx * vz);
      final tz = 2.0 * (qx * vy - qy * vx);

      final rx = vx + qw * tx + (qy * tz - qz * ty);
      final ry = vy + qw * ty + (qz * tx - qx * tz);
      final rz = vz + qw * tz + (qx * ty - qy * tx);

      // Occlusion & Depth
      final isFront = rz >= 0.0;
      if (!isFront && rearOpacity <= 0.0) {
        continue;
      }

      // Projection calculation with hoisted invariants
      final double screenX;
      final double screenY;
      if (isOrthographic) {
        screenX = cx + rx * radius;
        screenY = cy + ry * radius;
      } else {
        final denom = math.max(0.1, altitude - rz);
        final rScale = radiusAltitude / denom;
        screenX = cx + rx * rScale;
        screenY = cy + ry * rScale;
      }

      // Diffuse directional lighting
      final dotProduct = rx * lx + ry * ly + rz * lz;
      final diffuse = dotProduct > 0.0 ? dotProduct : 0.0;
      final lighting = (ambient + diffuse * diffuseWeight).clamp(0.0, 1.0);

      final double alpha;
      if (isFront) {
        final depthFade = 0.35 + 0.65 * (rz * rz);
        alpha = (frontBaseAlpha * lighting * depthFade).clamp(0.0, 1.0);
      } else {
        alpha = (rearBaseAlpha * lighting).clamp(0.0, 1.0);
      }

      if (alpha <= 0.02) continue;

      // Quantize alpha into lighting buckets
      final bucket = (alpha * bucketMaxIndex).round().clamp(0, bucketMaxIndex);
      final count = _counts[bucket];
      final buf = _buffers[bucket];
      final ptr = count * 2;
      buf[ptr] = screenX;
      buf[ptr + 1] = screenY;
      _counts[bucket] = count + 1;
    }

    // Execute GPU batched drawRawPoints for each bucket
    _batchPaint.strokeWidth = math.max(1.0, baseSize * 2.0);

    for (var b = 0; b < _kBucketCount; b++) {
      final count = _counts[b];
      if (count == 0) continue;

      final bucketAlpha = ((b + 1) / _kBucketCount).clamp(0.15, 1.0);
      _batchPaint.color =
          baseColor.withValues(alpha: bucketAlpha * globeOpacity);

      final activeBuffer = Float32List.sublistView(_buffers[b], 0, count * 2);
      canvas.drawRawPoints(ui.PointMode.points, activeBuffer, _batchPaint);
    }
  }
}
