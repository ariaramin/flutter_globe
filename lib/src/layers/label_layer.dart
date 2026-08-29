import 'package:flutter/material.dart';
import '../models/globe_coordinate.dart';
import 'globe_layer.dart';

/// Represents a floating text annotation label on the 3D globe.
@immutable
class GlobeLabel {
  /// Creates a text label with an explicit text direction and leader line.
  const GlobeLabel({
    required this.coordinate,
    required this.text,
    this.style = const TextStyle(
      color: Colors.white,
      fontSize: 11.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
    this.backgroundColor = const Color(0xE60F172A),
    this.borderColor = const Color(0x6638BDF8),
    this.offset = const Offset(10.0, -10.0),
    this.showConnectorLine = true,
    this.textDirection = TextDirection.ltr,
    this.data,
  });

  /// Geographic coordinate where this label is pinned.
  final GlobeCoordinate coordinate;

  /// Display text string.
  final String text;

  /// Direction used to lay out the label, including RTL scripts.
  final TextDirection textDirection;

  /// Text typography style.
  final TextStyle style;

  /// Background pill fill color.
  final Color backgroundColor;

  /// Border outline color.
  final Color borderColor;

  /// 2D screen offset from the surface anchor point.
  final Offset offset;

  /// Whether to draw a connector leader line from anchor to label pill.
  final bool showConnectorLine;

  /// Optional payload.
  final Object? data;
}

/// Renders lightweight floating text labels with leader lines and limb fading.
class GlobeLabelLayer extends GlobeLayer {
  /// Creates a label overlay. Large label counts can be expensive to lay out.
  const GlobeLabelLayer({
    super.enabled = true,
    super.zIndex = 30,
    this.labels = const <GlobeLabel>[],
  });

  /// Labels to paint; replace this list when its contents change.
  final List<GlobeLabel> labels;

  @override
  void paint(GlobeRenderContext context) {
    final Paint borderPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint bgPaint = Paint()..isAntiAlias = true;

    final Paint linePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (labels.isEmpty) return;

    final canvas = context.canvas;
    final camera = context.camera;
    final rotation = context.rotation;

    for (final label in labels) {
      final unitVec = label.coordinate.toVector3D();
      final rotated = rotation.rotateVector(unitVec);

      // Occlusion test
      if (rotated.z < -0.05) continue;

      final limbAlpha = ((rotated.z + 0.05) / 0.15).clamp(0.0, 1.0);
      if (limbAlpha <= 0.05) continue;

      final (px, py, scale, _) = camera.projectRaw(rotated);
      final anchor = Offset(px, py);

      final textPainter = TextPainter(
        text: TextSpan(text: label.text, style: label.style),
        textDirection: label.textDirection,
      )..layout();

      final labelPos = Offset(
        anchor.dx + label.offset.dx * scale,
        anchor.dy + label.offset.dy * scale,
      );

      // Draw connector leader line
      if (label.showConnectorLine) {
        linePaint.color = label.borderColor.withValues(alpha: 0.6 * limbAlpha);
        canvas.drawLine(anchor, labelPos, linePaint);
      }

      // Draw background pill
      final pillRect = Rect.fromLTWH(
        labelPos.dx - 5.0,
        labelPos.dy - 2.0,
        textPainter.width + 10.0,
        textPainter.height + 4.0,
      );

      final rrect =
          RRect.fromRectAndRadius(pillRect, const Radius.circular(5.0));
      bgPaint.color = label.backgroundColor.withValues(alpha: limbAlpha);
      borderPaint.color = label.borderColor.withValues(alpha: 0.7 * limbAlpha);

      canvas.drawRRect(rrect, bgPaint);
      canvas.drawRRect(rrect, borderPaint);
      textPainter.paint(canvas, labelPos);
      textPainter.dispose();
    }
  }
}
