import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../math/matrix3d.dart';
import '../models/globe_style.dart';
import '../themes/globe_style_models.dart';

/// Renders the atmospheric outer glow halo and spherical depth lighting shaders for the globe.
/// Caches radial gradient shaders to eliminate Skia/Impeller shader re-instantiation.
class AtmosphereRenderer {
  AtmosphereRenderer();

  final Paint _outerGlowPaint = Paint()..isAntiAlias = true;
  final Paint _sphereBasePaint = Paint()..isAntiAlias = true;
  final Paint _innerShadowPaint = Paint()..isAntiAlias = true;
  final Paint _rimPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8;

  // Shader cache keys
  double _lastOuterGlowCenterX = 0.0;
  double _lastOuterGlowCenterY = 0.0;
  double _lastOuterGlowRadius = 0.0;
  int _lastOuterGlowColor = 0;
  int _lastOuterRimColor = 0;

  double _lastInnerShadowLightX = 0.0;
  double _lastInnerShadowLightY = 0.0;
  double _lastInnerShadowRadius = 0.0;
  int _lastInnerShadowHighlight = 0;
  double _lastInnerShadowOpacity = 0.0;
  double _lastInnerShadowStrength = 0.0;

  /// Draws the background atmosphere glow and solid spherical base.
  void drawBackground(
    Canvas canvas,
    GlobeCamera camera,
    GlobeStyle style, {
    GlobeAtmosphereStyle? atmosphereOverride,
    double atmosphereProgress = 1.0,
    double opacityMultiplier = 1.0,
  }) {
    final center = camera.center;
    final radius = camera.radius;
    final atmosphere = atmosphereOverride ??
        GlobeAtmosphereStyle(
          visible: style.showAtmosphere,
          altitude: style.atmosphereAltitude,
          color: style.atmosphereColor ?? style.primaryColor,
        );

    if (radius <= 0.0) return;

    // 1. Outer Atmospheric Glow Halo
    final effectiveIntensity =
        atmosphere.glowIntensity * atmosphereProgress * opacityMultiplier;
    if (atmosphere.visible && effectiveIntensity > 0.0) {
      final bloomAltitude =
          atmosphere.altitude * (0.4 + 0.6 * atmosphereProgress);
      final outerRadius = radius * (1.0 + bloomAltitude);
      final glowColor =
          atmosphere.color.withValues(alpha: effectiveIntensity * 0.45);
      final secondaryColor = atmosphere.secondaryGlowColor ?? atmosphere.color;
      final rimColor =
          secondaryColor.withValues(alpha: effectiveIntensity * 0.20);

      final glowColorValue = glowColor.toARGB32();
      final rimColorValue = rimColor.toARGB32();

      if (_lastOuterGlowCenterX != center.dx ||
          _lastOuterGlowCenterY != center.dy ||
          _lastOuterGlowRadius != outerRadius ||
          _lastOuterGlowColor != glowColorValue ||
          _lastOuterRimColor != rimColorValue) {
        _lastOuterGlowCenterX = center.dx;
        _lastOuterGlowCenterY = center.dy;
        _lastOuterGlowRadius = outerRadius;
        _lastOuterGlowColor = glowColorValue;
        _lastOuterRimColor = rimColorValue;

        _outerGlowPaint.shader = ui.Gradient.radial(
          center,
          outerRadius,
          <Color>[
            glowColor,
            rimColor,
            atmosphere.color.withValues(alpha: 0.0),
          ],
          <double>[
            (radius / outerRadius).clamp(0.0, 0.95),
            ((radius + (outerRadius - radius) * 0.4) / outerRadius)
                .clamp(0.0, 0.98),
            1.0,
          ],
        );
      }

      canvas.drawCircle(center, outerRadius, _outerGlowPaint);
    }

    // 2. Base Sphere Surface
    if (style.surfaceColor.a > 0.0 && opacityMultiplier > 0.0) {
      _sphereBasePaint.color = style.surfaceColor.withValues(
        alpha: style.surfaceColor.a * style.globeOpacity * opacityMultiplier,
      );
      canvas.drawCircle(center, radius, _sphereBasePaint);
    }

    // 3. Inner Spherical Shading / Depth Gradient
    const shadowColor = Color(0xFF000000);
    final highlightColor = atmosphere.color.withValues(
        alpha:
            0.15 * style.globeOpacity * opacityMultiplier * atmosphereProgress);
    final highlightValue = highlightColor.toARGB32();

    // Light source coming from upper-left and slightly front
    final lightOffset =
        Offset(center.dx - radius * 0.35, center.dy - radius * 0.35);
    final combinedOpacity = style.globeOpacity * opacityMultiplier;
    final shadowStrength =
        (atmosphere.innerShadowIntensity * 1.9).clamp(0.0, 1.0);

    if (_lastInnerShadowLightX != lightOffset.dx ||
        _lastInnerShadowLightY != lightOffset.dy ||
        _lastInnerShadowRadius != radius ||
        _lastInnerShadowHighlight != highlightValue ||
        _lastInnerShadowOpacity != combinedOpacity ||
        _lastInnerShadowStrength != shadowStrength) {
      _lastInnerShadowLightX = lightOffset.dx;
      _lastInnerShadowLightY = lightOffset.dy;
      _lastInnerShadowRadius = radius;
      _lastInnerShadowHighlight = highlightValue;
      _lastInnerShadowOpacity = combinedOpacity;
      _lastInnerShadowStrength = shadowStrength;

      _innerShadowPaint.shader = ui.Gradient.radial(
        lightOffset,
        radius * 1.35,
        <Color>[
          highlightColor,
          shadowColor.withValues(alpha: 0.0),
          shadowColor.withValues(
              alpha: 0.65 * shadowStrength * combinedOpacity),
          shadowColor.withValues(alpha: shadowStrength * combinedOpacity),
        ],
        const <double>[0.0, 0.45, 0.8, 1.0],
      );
    }

    canvas.drawCircle(center, radius, _innerShadowPaint);
  }

  /// Draws the foreground atmosphere rim/edge highlight over the land dots and arcs.
  void drawForegroundRim(
    Canvas canvas,
    GlobeCamera camera,
    GlobeStyle style, {
    GlobeAtmosphereStyle? atmosphereOverride,
    double atmosphereProgress = 1.0,
    double opacityMultiplier = 1.0,
  }) {
    final atmosphere = atmosphereOverride ??
        GlobeAtmosphereStyle(
          visible: style.showAtmosphere,
          altitude: style.atmosphereAltitude,
          color: style.atmosphereColor ?? style.primaryColor,
        );
    final effectiveIntensity =
        atmosphere.glowIntensity * atmosphereProgress * opacityMultiplier;
    if (!atmosphere.visible || effectiveIntensity <= 0.0) return;

    final center = camera.center;
    final radius = camera.radius;

    _rimPaint.color =
        atmosphere.color.withValues(alpha: effectiveIntensity * 0.35);

    canvas.drawCircle(center, radius - 0.9, _rimPaint);
  }
}
