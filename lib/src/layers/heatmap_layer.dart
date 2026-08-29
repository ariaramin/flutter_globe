import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/globe_coordinate.dart';
import 'globe_layer.dart';

/// Represents a data-driven geographic heat point.
@immutable
class GlobeHeatPoint {
  /// Creates a radial heat source with intensity in (0 to 1).
  const GlobeHeatPoint({
    required this.coordinate,
    this.intensity = 0.8,
    this.radius = 24.0,
    this.data,
  })  : assert(intensity >= 0 && intensity <= 1),
        assert(radius >= 0 && radius < double.infinity);

  /// Geographic coordinate of the heat source.
  final GlobeCoordinate coordinate;

  /// Intensity factor between 0.0 (minimal) and 1.0 (maximum).
  final double intensity;

  /// Base radius of the heat splat in logical pixels.
  final double radius;

  /// Optional custom payload data.
  final Object? data;
}

/// Renders a geographic heatmap layer across the globe surface.
class GlobeHeatmapLayer extends GlobeLayer {
  /// Creates a heat overlay. Gradients shorter than two colors are skipped.
  const GlobeHeatmapLayer({
    super.enabled = true,
    super.zIndex = 15,
    required this.points,
    this.gradient = const <Color>[
      Color(0x003B82F6),
      Color(0x6606B6D4),
      Color(0xAA10B981),
      Color(0xCCFBBF24),
      Color(0xFFEF4444),
    ],
    this.opacity = 0.85,
  }) : assert(opacity >= 0 && opacity <= 1);

  /// List of geographic heat points.
  final List<GlobeHeatPoint> points;

  /// Gradient color spectrum from cold (0.0) to hot (1.0).
  final List<Color> gradient;

  /// Global opacity multiplier for the heatmap layer.
  final double opacity;

  @override
  void paint(GlobeRenderContext context) {
    final Paint paint = Paint()..isAntiAlias = true;

    if (points.isEmpty || gradient.length < 2 || opacity <= 0.0) return;

    final canvas = context.canvas;
    final camera = context.camera;
    final rotation = context.rotation;

    for (final point in points) {
      final unitVec = point.coordinate.toVector3D();
      final rotated = rotation.rotateVector(unitVec);
      final z = rotated.z;

      // Occlusion: fade out heat points at the horizon
      if (z < -0.05) continue;

      final limbAlpha = ((z + 0.05) / 0.2).clamp(0.0, 1.0);
      final (px, py, scale, _) = camera.projectRaw(rotated);
      final center = Offset(px, py);
      final splatRadius = point.radius * scale;
      final pointAlpha =
          (point.intensity * opacity * limbAlpha).clamp(0.0, 1.0);

      if (pointAlpha <= 0.01 || splatRadius <= 0 || !splatRadius.isFinite) {
        continue;
      }

      final colors = List<Color>.generate(
        gradient.length,
        (i) => gradient[i].withValues(alpha: gradient[i].a * pointAlpha),
        growable: false,
      );

      paint.shader = ui.Gradient.radial(
        center,
        splatRadius,
        colors,
        List<double>.generate(colors.length, (i) => i / (colors.length - 1),
            growable: false),
      );

      canvas.drawCircle(center, splatRadius, paint);
    }
  }
}
