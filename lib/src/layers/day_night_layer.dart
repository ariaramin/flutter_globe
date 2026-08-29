import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../math/vector3.dart';
import 'globe_layer.dart';

/// Renders a simulated day/night solar terminator shadow across the globe.
class GlobeDayNightLayer extends GlobeLayer {
  /// Creates illustrative shading from a supplied sun direction, not a solar ephemeris.
  const GlobeDayNightLayer({
    super.enabled = true,
    super.zIndex = 8,
    this.sunDirection = const Vector3D(1.0, 0.2, 0.6),
    this.nightOpacity = 0.6,
    this.nightColor = const Color(0xFF020408),
  });

  /// 3D directional vector pointing towards the sun.
  final Vector3D sunDirection;

  /// Darkness opacity of the night side.
  final double nightOpacity;

  /// Base tint color of the night shadow.
  final Color nightColor;

  @override
  void paint(GlobeRenderContext context) {
    final Paint nightPaint = Paint()..isAntiAlias = true;

    if (nightOpacity <= 0.0) return;

    final canvas = context.canvas;
    final camera = context.camera;
    final center = camera.center;
    final radius = camera.radius;

    final sun = sunDirection.normalized;
    final rotatedSun = context.rotation.rotateVector(sun);

    // Light offset in screen space
    final sunScreenOffset = Offset(
      center.dx + rotatedSun.x * radius,
      center.dy + rotatedSun.y * radius,
    );

    nightPaint.shader = ui.Gradient.radial(
      sunScreenOffset,
      radius * 1.6,
      <Color>[
        nightColor.withValues(alpha: 0.0),
        nightColor.withValues(alpha: nightOpacity * 0.4),
        nightColor.withValues(alpha: nightOpacity),
      ],
      const <double>[0.0, 0.5, 1.0],
    );

    canvas.drawCircle(center, radius, nightPaint);
  }
}
