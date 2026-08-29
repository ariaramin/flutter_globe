import 'package:flutter/material.dart';
import '../models/globe_coordinate.dart';
import 'globe_layer.dart';

/// Represents a geographic polygonal region or country outline.
@immutable
class GlobeRegion {
  /// Creates a stylized polygon; supply selection state from the application.
  const GlobeRegion({
    required this.id,
    required this.polygon,
    this.name,
    this.fillColor = const Color(0x3338BDF8),
    this.borderColor = const Color(0xFF38BDF8),
    this.borderWidth = 1.5,
    this.isSelected = false,
    this.isHovered = false,
    this.selectedFillColor = const Color(0x6638BDF8),
    this.data,
  }) : assert(borderWidth >= 0 && borderWidth < double.infinity);

  /// Unique identifier for this region.
  final String id;

  /// Optional display name.
  final String? name;

  /// Polygon vertices defining the region boundary.
  final List<GlobeCoordinate> polygon;

  /// Interior fill color.
  final Color fillColor;

  /// Outline border color.
  final Color borderColor;

  /// Width of boundary border in logical pixels.
  final double borderWidth;

  /// Whether the region is currently in a selected state.
  final bool isSelected;

  /// Whether the region is currently hovered by cursor.
  final bool isHovered;

  /// Fill color when [isSelected] is true.
  final Color selectedFillColor;

  /// Optional custom payload.
  final Object? data;
}

/// Renders country outlines, territorial boundaries, and interactive polygonal regions.
class GlobeRegionLayer extends GlobeLayer {
  /// Creates a polygon overlay with approximate horizon clipping.
  const GlobeRegionLayer({
    super.enabled = true,
    super.zIndex = 5,
    this.regions = const <GlobeRegion>[],
  });

  /// Polygons to paint; replace this list when data changes.
  final List<GlobeRegion> regions;

  @override
  void paint(GlobeRenderContext context) {
    final Paint borderPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final Path path = Path();

    if (regions.isEmpty) return;

    final canvas = context.canvas;
    final camera = context.camera;
    final rotation = context.rotation;

    for (final region in regions) {
      if (region.polygon.length < 3) continue;

      final vectors =
          region.polygon.map((c) => c.toVector3D()).toList(growable: false);

      path.reset();
      var hasStarted = false;
      var frontPointCount = 0;

      for (final v in vectors) {
        final rotated = rotation.rotateVector(v);
        if (rotated.z >= -0.05) {
          frontPointCount++;
        }

        final (px, py, _, _) = camera.projectRaw(rotated);
        if (!hasStarted) {
          path.moveTo(px, py);
          hasStarted = true;
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();

      // Only draw if majority of region is facing the camera
      if (frontPointCount > vectors.length * 0.4) {
        final currentFill = region.isSelected
            ? region.selectedFillColor
            : (region.isHovered
                ? region.fillColor.withValues(alpha: 0.5)
                : region.fillColor);

        fillPaint.color = currentFill;
        borderPaint
          ..strokeWidth = region.borderWidth
          ..color = region.borderColor;

        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
      }
    }
  }
}
