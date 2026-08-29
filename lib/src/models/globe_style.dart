import 'package:flutter/material.dart';
import '../math/vector3.dart';

/// Complete visual styling tokens and rendering configuration for the globe.
@immutable
class GlobeStyle {
  /// Creates a style configuration for the globe.
  const GlobeStyle({
    this.primaryColor = const Color(0xFF3B82F6),
    this.neutralColor = const Color(0xFF9CA3AF),
    this.surfaceColor = const Color(0xFF070B14),
    this.atmosphereColor,
    this.globeOpacity = 1.0,
    this.pointSize = 1.65,
    this.pointOpacity = 0.95,
    this.rearPointOpacity = 0.0,
    this.showAtmosphere = true,
    this.atmosphereAltitude = 0.2,
    this.lightDirection = const Vector3D(-0.4, -0.4, 0.9),
    this.ambientLight = 0.35,
    this.diffuseLight = 0.65,
  });

  /// Primary accent color used for arcs, marker beacons, and highlights.
  final Color primaryColor;

  /// Neutral color used for land dots and surface geography.
  final Color neutralColor;

  /// Base surface color of the globe sphere.
  final Color surfaceColor;

  /// Optional specific color for the atmosphere. Defaults to [primaryColor] or [neutralColor].
  final Color? atmosphereColor;

  /// Overall opacity multiplier for the globe surface (0.0 to 1.0).
  final double globeOpacity;

  /// Base radius of land dots in logical pixels.
  final double pointSize;

  /// Opacity multiplier for front-facing land dots.
  final double pointOpacity;

  /// Opacity for rear-facing land dots (0.0 = completely occluded/hidden, >0.0 = translucent back).
  final double rearPointOpacity;

  /// Whether to render the atmosphere glow around the globe.
  final bool showAtmosphere;

  /// Altitude of the atmosphere rim if [atmosphere] is not provided.
  final double atmosphereAltitude;

  /// Normalized 3D directional light vector for spherical diffuse shading.
  final Vector3D lightDirection;

  /// Ambient lighting level across the globe (0.0 to 1.0).
  final double ambientLight;

  /// Diffuse directional lighting intensity (0.0 to 1.0).
  final double diffuseLight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobeStyle &&
          primaryColor == other.primaryColor &&
          neutralColor == other.neutralColor &&
          surfaceColor == other.surfaceColor &&
          atmosphereColor == other.atmosphereColor &&
          globeOpacity == other.globeOpacity &&
          pointSize == other.pointSize &&
          pointOpacity == other.pointOpacity &&
          rearPointOpacity == other.rearPointOpacity &&
          showAtmosphere == other.showAtmosphere &&
          atmosphereAltitude == other.atmosphereAltitude &&
          lightDirection == other.lightDirection &&
          ambientLight == other.ambientLight &&
          diffuseLight == other.diffuseLight;

  @override
  int get hashCode => Object.hashAll(<Object?>[
        primaryColor,
        neutralColor,
        surfaceColor,
        atmosphereColor,
        globeOpacity,
        pointSize,
        pointOpacity,
        rearPointOpacity,
        showAtmosphere,
        atmosphereAltitude,
        lightDirection,
        ambientLight,
        diffuseLight,
      ]);
}
