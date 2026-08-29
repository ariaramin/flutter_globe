import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../math/matrix3d.dart';
import '../math/quaternion.dart';
import '../math/vector3.dart';
import '../models/globe_coordinate.dart';
import '../models/globe_marker.dart';

/// Renders pulsing location beacons, core markers, radar rings, and cached labels on the globe surface.
class MarkerRenderer {
  MarkerRenderer();

  final Map<GlobeCoordinate, Vector3D> _vectorCache =
      <GlobeCoordinate, Vector3D>{};
  final Map<String, TextPainter> _textPainterCache = <String, TextPainter>{};

  final Paint _corePaint = Paint()..isAntiAlias = true;
  final Paint _glowPaint = Paint()..isAntiAlias = true;
  final Paint _innerPaint = Paint()..isAntiAlias = true;
  final Paint _pulsePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;
  final Paint _labelBgPaint = Paint()..isAntiAlias = true;
  final Paint _labelBorderPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  /// Releases cached text layout resources when the owning globe is removed.
  void dispose() {
    for (final painter in _textPainterCache.values) {
      painter.dispose();
    }
    _textPainterCache.clear();
    _vectorCache.clear();
  }

  /// Draws a list of [markers] onto [canvas] with depth testing, intro pop-in, and pulse animations.
  void draw({
    required Canvas canvas,
    required GlobeCamera camera,
    required Quaternion3D rotation,
    required List<GlobeMarker> markers,
    required double animationTimeMs,
    double opacityMultiplier = 1.0,
    double Function(int markerIndex)? markerRevealProgressProvider,
  }) {
    if (markers.isEmpty || opacityMultiplier <= 0.0) return;

    for (var i = 0; i < markers.length; i++) {
      final marker = markers[i];
      final reveal = markerRevealProgressProvider?.call(i) ?? 1.0;
      if (reveal <= 0.0) continue;

      var unitVector = _vectorCache[marker.coordinate];
      if (unitVector == null) {
        if (_vectorCache.length > 1000) {
          _vectorCache.clear();
        }
        unitVector = marker.coordinate.toVector3D();
        _vectorCache[marker.coordinate] = unitVector;
      }

      final rotated = rotation.rotateVector(unitVector);
      final z = rotated.z;

      // Occlusion: Rear hemisphere markers fade out quickly past the horizon
      if (z < -0.05) continue;

      final limbAlpha = (z + 0.05) / 0.15;
      final horizonFade = (limbAlpha.clamp(0.0, 1.0)) *
          opacityMultiplier *
          (reveal > 1.0 ? 1.0 : reveal);

      final (px, py, projScale, _) = camera.projectRaw(rotated);
      final center = Offset(px, py);
      final scale = projScale * (reveal.clamp(0.0, 1.2));
      final coreRadius = marker.size * scale;
      final markerColor = marker.color;

      // 1. Expanding Pulse Rings
      final durationMs = marker.pulseDuration.inMicroseconds / 1000.0;
      if (marker.pulse && reveal >= 0.5 && durationMs > 0) {
        final cycle = (animationTimeMs % durationMs) / durationMs;
        final pulseColor = marker.pulseColor ?? markerColor;

        // Render two staggered pulse wave rings
        for (var ring = 0; ring < 2; ring++) {
          final ringPhase = (cycle + ring * 0.5) % 1.0;
          final pulseRadius = coreRadius +
              (marker.pulseRadius * scale - coreRadius) * ringPhase;
          final pulseAlpha = (1.0 - ringPhase) * 0.7 * horizonFade;

          if (pulseAlpha > 0.01) {
            _pulsePaint
              ..color = pulseColor.withValues(alpha: pulseAlpha)
              ..strokeWidth = 1.6 * (1.0 - ringPhase * 0.4) * scale;

            canvas.drawCircle(center, pulseRadius, _pulsePaint);
          }
        }
      }

      // 2. Outer Soft Glow
      _glowPaint.color = markerColor.withValues(alpha: 0.35 * horizonFade);
      canvas.drawCircle(center, coreRadius * 1.8, _glowPaint);

      // 3. Central Solid Beacon
      _corePaint.color = markerColor.withValues(alpha: horizonFade);
      canvas.drawCircle(center, coreRadius, _corePaint);

      // 4. White Center Dot
      _innerPaint.color = Colors.white.withValues(alpha: 0.9 * horizonFade);
      canvas.drawCircle(center, math.max(1.0, coreRadius * 0.45), _innerPaint);

      // 5. Optional Text Label
      if (marker.label != null && horizonFade > 0.4 && reveal >= 0.8) {
        _drawLabel(
          canvas,
          center,
          marker.label!,
          scale,
          horizonFade,
          markerColor,
        );
      }
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset markerCenter,
    String label,
    double scale,
    double alpha,
    Color accentColor,
  ) {
    var textPainter = _textPainterCache[label];
    if (textPainter == null) {
      if (_textPainterCache.length > 200) {
        for (final painter in _textPainterCache.values) {
          painter.dispose();
        }
        _textPainterCache.clear();
      }
      final textSpan = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      );
      textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      _textPainterCache[label] = textPainter;
    }

    final labelOffset = Offset(
      markerCenter.dx + 8.0 * scale,
      markerCenter.dy - textPainter.height * 0.5,
    );

    // Pill background
    final bgRect = Rect.fromLTWH(
      labelOffset.dx - 4.0,
      labelOffset.dy - 2.0,
      textPainter.width + 8.0,
      textPainter.height + 4.0,
    );

    final rrect = RRect.fromRectAndRadius(bgRect, const Radius.circular(4.0));
    _labelBgPaint.color =
        const Color(0xFF0F172A).withValues(alpha: 0.85 * alpha);
    _labelBorderPaint.color = accentColor.withValues(alpha: 0.4 * alpha);

    canvas.drawRRect(rrect, _labelBgPaint);
    canvas.drawRRect(rrect, _labelBorderPaint);
    textPainter.paint(canvas, labelOffset);
  }
}
