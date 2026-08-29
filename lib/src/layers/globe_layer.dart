import 'package:flutter/material.dart';
import '../math/matrix3d.dart';
import '../math/quaternion.dart';
import '../themes/globe_style_models.dart';
import '../themes/globe_theme.dart';

/// Context provided to every [GlobeLayer] during the painting phase.
@immutable
class GlobeRenderContext {
  /// Creates the paint-time view of a globe scene.
  const GlobeRenderContext({
    required this.canvas,
    required this.size,
    required this.camera,
    required this.rotation,
    required this.theme,
    required this.animationTimeMs,
    required this.quality,
  });

  /// The active Flutter Canvas.
  final Canvas canvas;

  /// The size of the globe canvas.
  final Size size;

  /// The 3D camera projection parameters (altitude, center, screen radius).
  final GlobeCamera camera;

  /// The current orientation quaternion of the globe.
  final Quaternion3D rotation;

  /// Active visual theme tokens.
  final GlobeTheme theme;

  /// Elapsed time in milliseconds for driving layer animations.
  final double animationTimeMs;

  /// Current quality level.
  final GlobeQuality quality;
}

/// Abstract base class for extensible globe render layers.
abstract class GlobeLayer {
  /// Creates a render layer with visibility and a z-order band.
  const GlobeLayer({this.enabled = true, this.zIndex = 0});

  /// Whether this layer is rendered.
  final bool enabled;

  /// Rendering order priority (lower zIndex paints first).
  final int zIndex;

  /// Paints the layer contents onto the canvas.
  void paint(GlobeRenderContext context);
}
