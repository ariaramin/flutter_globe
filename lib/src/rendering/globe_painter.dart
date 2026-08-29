import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../animation/globe_intro_animation.dart';
import '../layers/globe_layer.dart';
import '../math/globe_projection.dart';
import '../math/matrix3d.dart';
import '../math/quaternion.dart';
import '../models/globe_arc.dart';
import '../models/globe_marker.dart';
import '../models/globe_style.dart';
import '../themes/globe_style_models.dart';
import '../themes/globe_theme.dart';
import 'arc_renderer.dart';
import 'atmosphere_renderer.dart';
import 'dots_renderer.dart';
import 'marker_renderer.dart';

/// The master [CustomPainter] orchestrating the multi-layered 3D globe rendering pipeline.
class GlobePainter extends CustomPainter {
  /// Creates a globe painter with orientation, style tokens, markers, arcs, layers, and animation state.
  GlobePainter({
    required this.rotation,
    required this.style,
    required this.markers,
    required this.arcs,
    required this.animationTimeMs,
    this.theme,
    List<GlobeLayer> layers = const <GlobeLayer>[],
    this.cameraAltitude = 2.6,
    this.radiusMultiplier = 0.82,
    this.quality = GlobeQuality.auto,
    this.projection = GlobeProjection.perspective,
    this.introAnimation = GlobeIntroAnimation.none,
    this.introProgress = 1.0,
    AtmosphereRenderer? atmosphereRenderer,
    DotsRenderer? dotsRenderer,
    ArcRenderer? arcRenderer,
    MarkerRenderer? markerRenderer,
    super.repaint,
  })  : layers = List<GlobeLayer>.of(layers)
          ..sort((a, b) => a.zIndex.compareTo(b.zIndex)),
        _atmosphereRenderer = atmosphereRenderer ?? AtmosphereRenderer(),
        _dotsRenderer = dotsRenderer ?? DotsRenderer(),
        _arcRenderer = arcRenderer ?? ArcRenderer(),
        _markerRenderer = markerRenderer ?? MarkerRenderer();

  /// Current 3D orientation quaternion of the globe.
  final Quaternion3D rotation;

  /// Visual styling tokens.
  final GlobeStyle style;

  /// Active global theme.
  final GlobeTheme? theme;

  /// List of geographic location markers.
  final List<GlobeMarker> markers;

  /// List of animated connection arcs.
  final List<GlobeArc> arcs;

  /// Custom extensible render layers.
  final List<GlobeLayer> layers;

  /// Elapsed animation time in milliseconds for driving pulse and dash motion.
  final double animationTimeMs;

  /// Camera altitude distance (default 2.6).
  final double cameraAltitude;

  /// Globe radius as a fraction of half the canvas size (default 0.82).
  final double radiusMultiplier;

  /// Current quality level.
  final GlobeQuality quality;

  /// Active projection mode.
  final GlobeProjection projection;

  /// Configuration for entrance/reveal animation.
  final GlobeIntroAnimation introAnimation;

  /// Current normalized progress of the entrance animation (0.0 to 1.0).
  final double introProgress;

  final AtmosphereRenderer _atmosphereRenderer;
  final DotsRenderer _dotsRenderer;
  final ArcRenderer _arcRenderer;
  final MarkerRenderer _markerRenderer;

  final Path _spherePath = Path();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.width.isFinite || !size.height.isFinite) return;
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final minDimension = math.min(size.width, size.height);
    final resolvedQuality = quality == GlobeQuality.auto
        ? (minDimension < 320
            ? GlobeQuality.low
            : minDimension < 600
                ? GlobeQuality.medium
                : GlobeQuality.high)
        : quality;

    // Compute entrance scale and opacity factors
    final introScale = introAnimation.computeScale(introProgress);
    final introOpacity = introAnimation.computeOpacity(introProgress);
    final atmosphereProgress =
        introAnimation.computeAtmosphereProgress(introProgress);

    final radius = (minDimension * 0.5) * radiusMultiplier * introScale;

    if (radius <= 0.0 || introOpacity <= 0.0) return;

    final camera = GlobeCamera(
      altitude: cameraAltitude,
      center: center,
      radius: radius,
      projection: projection,
    );

    final effectiveTheme = theme ??
        GlobeTheme(
          surface: GlobeSurfaceStyle(
            surfaceColor: style.surfaceColor,
            landColor: style.neutralColor,
            pointSize: style.pointSize,
            pointOpacity: style.pointOpacity,
            rearPointOpacity: style.rearPointOpacity,
            globeOpacity: style.globeOpacity,
          ),
          atmosphere: GlobeAtmosphereStyle(
            visible: style.showAtmosphere,
            altitude: style.atmosphereAltitude,
            color: style.atmosphereColor ?? style.primaryColor,
          ),
          lighting: GlobeLightingStyle(
            ambientIntensity: style.ambientLight,
            directionalIntensity: style.diffuseLight,
            lightDirection: style.lightDirection,
          ),
          quality: resolvedQuality,
          accentColor: style.primaryColor,
        );

    final renderContext = GlobeRenderContext(
      canvas: canvas,
      size: size,
      camera: camera,
      rotation: rotation,
      theme: effectiveTheme,
      animationTimeMs: animationTimeMs,
      quality: resolvedQuality,
    );

    // 1. Draw Background Atmosphere Outer Glow and Base Shading
    _atmosphereRenderer.drawBackground(
      canvas,
      camera,
      style,
      atmosphereOverride: effectiveTheme.atmosphere,
      atmosphereProgress: atmosphereProgress,
      opacityMultiplier: introOpacity,
    );

    final layerCount = layers.length;

    // 2. Draw Pre-surface Layers (zIndex < 10)
    for (var i = 0; i < layerCount; i++) {
      final layer = layers[i];
      if (layer.enabled && layer.zIndex < 10) {
        layer.paint(renderContext);
      }
    }

    // 3. Clip sphere interior for clean surface boundary
    canvas.save();
    _spherePath.reset();
    _spherePath.addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(_spherePath);

    // 4. Draw dotted geographic land.
    _dotsRenderer.draw(
      canvas,
      camera,
      rotation,
      style,
      surfaceOverride: effectiveTheme.surface,
      quality: resolvedQuality,
      opacityMultiplier: introOpacity,
    );

    // 5. Draw Mid-surface Layers (10 <= zIndex < 20)
    for (var i = 0; i < layerCount; i++) {
      final layer = layers[i];
      if (layer.enabled && layer.zIndex >= 10 && layer.zIndex < 20) {
        layer.paint(renderContext);
      }
    }

    // 6. Restore clip so elevated arcs and marker pulses can extend beyond base sphere
    canvas.restore();

    // 7. Draw 3D Elevated Great-Circle Arcs
    _arcRenderer.draw(
      canvas: canvas,
      camera: camera,
      rotation: rotation,
      arcs: arcs,
      animationTimeMs: animationTimeMs,
      quality: resolvedQuality,
      opacityMultiplier: introOpacity,
      arcRevealProgressProvider: (index) =>
          introAnimation.computeArcProgress(introProgress, index),
    );

    // 8. Draw Location Markers & Pulsing Beacons
    _markerRenderer.draw(
      canvas: canvas,
      camera: camera,
      rotation: rotation,
      markers: markers,
      animationTimeMs: animationTimeMs,
      opacityMultiplier: introOpacity,
      markerRevealProgressProvider: (index) =>
          introAnimation.computeMarkerProgress(introProgress, index),
    );

    // 9. Draw Post-surface Layers (zIndex >= 20)
    for (var i = 0; i < layerCount; i++) {
      final layer = layers[i];
      if (layer.enabled && layer.zIndex >= 20) {
        layer.paint(renderContext);
      }
    }

    // 10. Draw Foreground Atmosphere Rim Highlight
    _atmosphereRenderer.drawForegroundRim(
      canvas,
      camera,
      style,
      atmosphereOverride: effectiveTheme.atmosphere,
      atmosphereProgress: atmosphereProgress,
      opacityMultiplier: introOpacity,
    );
  }

  @override
  bool shouldRepaint(covariant GlobePainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.animationTimeMs != animationTimeMs ||
        oldDelegate.introProgress != introProgress ||
        oldDelegate.style != style ||
        oldDelegate.theme != theme ||
        oldDelegate.cameraAltitude != cameraAltitude ||
        oldDelegate.radiusMultiplier != radiusMultiplier ||
        oldDelegate.quality != quality ||
        oldDelegate.projection != projection ||
        oldDelegate.introAnimation != introAnimation ||
        oldDelegate.markers != markers ||
        oldDelegate.arcs != arcs ||
        !listEquals(oldDelegate.layers, layers);
  }
}
