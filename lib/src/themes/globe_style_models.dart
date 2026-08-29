import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../math/vector3.dart';

/// Performance and detail quality modes for globe rendering.
enum GlobeQuality {
  /// Optimized for low-end hardware or battery saving.
  low,

  /// Balanced point, arc, and particle density for typical mobile scenes.
  medium,

  /// High visual fidelity with full point density.
  high,

  /// Maximum point, arc, and particle density.
  ultra,

  /// Selects low, medium, or high from the rendered globe diameter.
  auto,
}

/// Visual styling configuration for the globe's geographic surface.
@immutable
class GlobeSurfaceStyle {
  /// Creates the dotted land and base-sphere style.
  const GlobeSurfaceStyle({
    this.surfaceColor = const Color(0xFF030712),
    this.landColor = const Color(0xFF9CA3AF),
    this.pointSize = 1.65,
    this.pointOpacity = 0.95,
    this.rearPointOpacity = 0.0,
    this.globeOpacity = 1.0,
  })  : assert(pointSize >= 0 && pointSize < double.infinity),
        assert(pointOpacity >= 0 && pointOpacity <= 1),
        assert(rearPointOpacity >= 0 && rearPointOpacity <= 1),
        assert(globeOpacity >= 0 && globeOpacity <= 1);

  /// Base sphere fill color.
  final Color surfaceColor;

  /// Color of geographic land dots.
  final Color landColor;

  /// Land-dot radius in logical pixels; use a nonnegative finite value.
  final double pointSize;

  /// Front land-dot opacity multiplier in (0 to 1).
  final double pointOpacity;

  /// Rear land-dot opacity in (0 to 1); zero hides rear points.
  final double rearPointOpacity;

  /// Sphere and land opacity multiplier in (0 to 1).
  final double globeOpacity;

  /// Copies these tokens, retaining any field whose argument is omitted.
  GlobeSurfaceStyle copyWith({
    Color? surfaceColor,
    Color? landColor,
    double? pointSize,
    double? pointOpacity,
    double? rearPointOpacity,
    double? globeOpacity,
  }) {
    return GlobeSurfaceStyle(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      landColor: landColor ?? this.landColor,
      pointSize: pointSize ?? this.pointSize,
      pointOpacity: pointOpacity ?? this.pointOpacity,
      rearPointOpacity: rearPointOpacity ?? this.rearPointOpacity,
      globeOpacity: globeOpacity ?? this.globeOpacity,
    );
  }

  /// Linearly interpolates between two [GlobeSurfaceStyle] instances.
  static GlobeSurfaceStyle lerp(
      GlobeSurfaceStyle a, GlobeSurfaceStyle b, double t) {
    return GlobeSurfaceStyle(
      surfaceColor:
          Color.lerp(a.surfaceColor, b.surfaceColor, t) ?? b.surfaceColor,
      landColor: Color.lerp(a.landColor, b.landColor, t) ?? b.landColor,
      pointSize: ui.lerpDouble(a.pointSize, b.pointSize, t) ?? b.pointSize,
      pointOpacity:
          ui.lerpDouble(a.pointOpacity, b.pointOpacity, t) ?? b.pointOpacity,
      rearPointOpacity:
          ui.lerpDouble(a.rearPointOpacity, b.rearPointOpacity, t) ??
              b.rearPointOpacity,
      globeOpacity:
          ui.lerpDouble(a.globeOpacity, b.globeOpacity, t) ?? b.globeOpacity,
    );
  }
}

/// Visual styling configuration for the atmosphere glow surrounding the globe.
@immutable
class GlobeAtmosphereStyle {
  /// Creates a Canvas gradient halo and rim configuration.
  const GlobeAtmosphereStyle({
    this.visible = true,
    this.color = const Color(0xFF38BDF8),
    this.altitude = 0.22,
    this.glowIntensity = 0.75,
    this.innerShadowIntensity = 0.45,
    this.secondaryGlowColor,
  })  : assert(altitude >= 0 && altitude < double.infinity),
        assert(glowIntensity >= 0 && glowIntensity <= 1),
        assert(innerShadowIntensity >= 0 && innerShadowIntensity <= 1);

  /// Whether this visual component is drawn.
  final bool visible;

  /// Primary color for this visual component.
  final Color color;

  /// Halo extent relative to sphere radius; use a nonnegative finite value.
  final double altitude;

  /// Outer halo intensity multiplier, normally in (0 to 1).
  final double glowIntensity;

  /// Inner-shadow metadata; current shading uses a fixed gradient.
  final double innerShadowIntensity;

  /// Optional second halo color, falling back to the primary color.
  final Color? secondaryGlowColor;

  /// Copies these tokens, retaining any field whose argument is omitted.
  GlobeAtmosphereStyle copyWith({
    bool? visible,
    Color? color,
    double? altitude,
    double? glowIntensity,
    double? innerShadowIntensity,
    Color? secondaryGlowColor,
  }) {
    return GlobeAtmosphereStyle(
      visible: visible ?? this.visible,
      color: color ?? this.color,
      altitude: altitude ?? this.altitude,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      innerShadowIntensity: innerShadowIntensity ?? this.innerShadowIntensity,
      secondaryGlowColor: secondaryGlowColor ?? this.secondaryGlowColor,
    );
  }

  /// Linearly interpolates between two [GlobeAtmosphereStyle] instances.
  static GlobeAtmosphereStyle lerp(
      GlobeAtmosphereStyle a, GlobeAtmosphereStyle b, double t) {
    return GlobeAtmosphereStyle(
      visible: t < 0.5 ? a.visible : b.visible,
      color: Color.lerp(a.color, b.color, t) ?? b.color,
      altitude: ui.lerpDouble(a.altitude, b.altitude, t) ?? b.altitude,
      glowIntensity:
          ui.lerpDouble(a.glowIntensity, b.glowIntensity, t) ?? b.glowIntensity,
      innerShadowIntensity:
          ui.lerpDouble(a.innerShadowIntensity, b.innerShadowIntensity, t) ??
              b.innerShadowIntensity,
      secondaryGlowColor:
          Color.lerp(a.secondaryGlowColor, b.secondaryGlowColor, t),
    );
  }
}

/// Configuration for simulated directional and ambient lighting.
@immutable
class GlobeLightingStyle {
  /// Creates the directional and ambient lighting tokens used by land dots.
  const GlobeLightingStyle({
    this.ambientIntensity = 0.35,
    this.directionalIntensity = 0.65,
    this.lightDirection = const Vector3D(-0.4, -0.4, 0.9),
  })  : assert(ambientIntensity >= 0 && ambientIntensity <= 1),
        assert(directionalIntensity >= 0 && directionalIntensity <= 1);

  /// Ambient contribution to land-dot brightness in (0 to 1).
  final double ambientIntensity;

  /// Directional contribution to land-dot brightness in (0 to 1).
  final double directionalIntensity;

  /// Directional light vector; normalized by the renderer.
  final Vector3D lightDirection;

  /// Copies these tokens, retaining any field whose argument is omitted.
  GlobeLightingStyle copyWith({
    double? ambientIntensity,
    double? directionalIntensity,
    Vector3D? lightDirection,
  }) {
    return GlobeLightingStyle(
      ambientIntensity: ambientIntensity ?? this.ambientIntensity,
      directionalIntensity: directionalIntensity ?? this.directionalIntensity,
      lightDirection: lightDirection ?? this.lightDirection,
    );
  }

  /// Linearly interpolates between two [GlobeLightingStyle] instances.
  static GlobeLightingStyle lerp(
      GlobeLightingStyle a, GlobeLightingStyle b, double t) {
    return GlobeLightingStyle(
      ambientIntensity:
          ui.lerpDouble(a.ambientIntensity, b.ambientIntensity, t) ??
              b.ambientIntensity,
      directionalIntensity:
          ui.lerpDouble(a.directionalIntensity, b.directionalIntensity, t) ??
              b.directionalIntensity,
      lightDirection: Vector3D(
        ui.lerpDouble(a.lightDirection.x, b.lightDirection.x, t) ??
            b.lightDirection.x,
        ui.lerpDouble(a.lightDirection.y, b.lightDirection.y, t) ??
            b.lightDirection.y,
        ui.lerpDouble(a.lightDirection.z, b.lightDirection.z, t) ??
            b.lightDirection.z,
      ).normalized,
    );
  }
}

/// Configuration for geographic graticule grid lines (latitudes, longitudes, equator).
@immutable
class GlobeGridStyle {
  /// Creates graticule styling; add a GlobeGridLayer to render it.
  const GlobeGridStyle({
    this.visible = true,
    this.color = const Color(0x3394A3B8),
    this.strokeWidth = 0.8,
    this.latitudeInterval = 30.0,
    this.longitudeInterval = 30.0,
    this.highlightEquator = true,
    this.highlightPrimeMeridian = true,
    this.equatorColor = const Color(0x6638BDF8),
  })  : assert(strokeWidth >= 0 && strokeWidth < double.infinity),
        assert(latitudeInterval > 0 && latitudeInterval <= 90),
        assert(longitudeInterval > 0 && longitudeInterval <= 180);

  /// Whether this visual component is drawn.
  final bool visible;

  /// Primary color for this visual component.
  final Color color;

  /// Stroke width in logical pixels; use a nonnegative finite value.
  final double strokeWidth;

  /// Spacing of parallels in degrees; renderer clamps to (10 to 90).
  final double latitudeInterval;

  /// Spacing of meridians in degrees; renderer clamps to (10 to 180).
  final double longitudeInterval;

  /// Whether an equator line receives emphasis when included in the grid.
  final bool highlightEquator;

  /// Whether the prime-meridian line receives emphasis.
  final bool highlightPrimeMeridian;

  /// Color for emphasized equator and prime-meridian lines.
  final Color equatorColor;

  /// Copies these tokens, retaining any field whose argument is omitted.
  GlobeGridStyle copyWith({
    bool? visible,
    Color? color,
    double? strokeWidth,
    double? latitudeInterval,
    double? longitudeInterval,
    bool? highlightEquator,
    bool? highlightPrimeMeridian,
    Color? equatorColor,
  }) {
    return GlobeGridStyle(
      visible: visible ?? this.visible,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      latitudeInterval: latitudeInterval ?? this.latitudeInterval,
      longitudeInterval: longitudeInterval ?? this.longitudeInterval,
      highlightEquator: highlightEquator ?? this.highlightEquator,
      highlightPrimeMeridian:
          highlightPrimeMeridian ?? this.highlightPrimeMeridian,
      equatorColor: equatorColor ?? this.equatorColor,
    );
  }

  /// Linearly interpolates between two [GlobeGridStyle] instances.
  static GlobeGridStyle lerp(GlobeGridStyle a, GlobeGridStyle b, double t) {
    return GlobeGridStyle(
      visible: t < 0.5 ? a.visible : b.visible,
      color: Color.lerp(a.color, b.color, t) ?? b.color,
      strokeWidth:
          ui.lerpDouble(a.strokeWidth, b.strokeWidth, t) ?? b.strokeWidth,
      latitudeInterval:
          ui.lerpDouble(a.latitudeInterval, b.latitudeInterval, t) ??
              b.latitudeInterval,
      longitudeInterval:
          ui.lerpDouble(a.longitudeInterval, b.longitudeInterval, t) ??
              b.longitudeInterval,
      highlightEquator: t < 0.5 ? a.highlightEquator : b.highlightEquator,
      highlightPrimeMeridian:
          t < 0.5 ? a.highlightPrimeMeridian : b.highlightPrimeMeridian,
      equatorColor:
          Color.lerp(a.equatorColor, b.equatorColor, t) ?? b.equatorColor,
    );
  }
}

/// Configuration for touch, pointer, and gesture interaction.
@immutable
class GlobeInteractionConfig {
  /// Creates gesture and idle-rotation behavior for the globe widget.
  const GlobeInteractionConfig({
    this.dragEnabled = true,
    this.zoomEnabled = false,
    this.inertiaEnabled = true,
    this.inertiaFriction = 0.93,
    this.rotationSensitivity = 0.005,
    this.invertVerticalPan = false,
    this.autoRotate = true,
    this.autoRotateSpeed = 0.85,
    this.pauseOnTouch = true,
  })  : assert(
            rotationSensitivity >= 0 && rotationSensitivity < double.infinity),
        assert(inertiaFriction >= 0 && inertiaFriction < 1),
        assert(autoRotateSpeed > -double.infinity &&
            autoRotateSpeed < double.infinity);

  /// Whether drag gestures rotate the globe.
  final bool dragEnabled;

  /// Whether pinch and pointer-scale gestures change zoom.
  final bool zoomEnabled;

  /// Whether a fast drag continues with decaying momentum.
  final bool inertiaEnabled;

  /// Per-frame momentum multiplier; lower values stop sooner.
  final double inertiaFriction;

  /// Radians applied per logical pixel of drag.
  final double rotationSensitivity;

  /// Whether vertical drag direction is inverted.
  final bool invertVerticalPan;

  /// Whether the camera rotates automatically while idle.
  final bool autoRotate;

  /// Idle rotation speed in radians per second.
  final double autoRotateSpeed;

  /// Whether pointer interaction pauses idle rotation.
  final bool pauseOnTouch;

  /// Copies these tokens, retaining any field whose argument is omitted.
  GlobeInteractionConfig copyWith({
    bool? dragEnabled,
    bool? zoomEnabled,
    bool? inertiaEnabled,
    double? inertiaFriction,
    double? rotationSensitivity,
    bool? invertVerticalPan,
    bool? autoRotate,
    double? autoRotateSpeed,
    bool? pauseOnTouch,
  }) {
    return GlobeInteractionConfig(
      dragEnabled: dragEnabled ?? this.dragEnabled,
      zoomEnabled: zoomEnabled ?? this.zoomEnabled,
      inertiaEnabled: inertiaEnabled ?? this.inertiaEnabled,
      inertiaFriction: inertiaFriction ?? this.inertiaFriction,
      rotationSensitivity: rotationSensitivity ?? this.rotationSensitivity,
      invertVerticalPan: invertVerticalPan ?? this.invertVerticalPan,
      autoRotate: autoRotate ?? this.autoRotate,
      autoRotateSpeed: autoRotateSpeed ?? this.autoRotateSpeed,
      pauseOnTouch: pauseOnTouch ?? this.pauseOnTouch,
    );
  }

  /// Linearly interpolates between two [GlobeInteractionConfig] instances.
  static GlobeInteractionConfig lerp(
      GlobeInteractionConfig a, GlobeInteractionConfig b, double t) {
    return GlobeInteractionConfig(
      dragEnabled: t < 0.5 ? a.dragEnabled : b.dragEnabled,
      zoomEnabled: t < 0.5 ? a.zoomEnabled : b.zoomEnabled,
      inertiaEnabled: t < 0.5 ? a.inertiaEnabled : b.inertiaEnabled,
      inertiaFriction: ui.lerpDouble(a.inertiaFriction, b.inertiaFriction, t) ??
          b.inertiaFriction,
      rotationSensitivity:
          ui.lerpDouble(a.rotationSensitivity, b.rotationSensitivity, t) ??
              b.rotationSensitivity,
      invertVerticalPan: t < 0.5 ? a.invertVerticalPan : b.invertVerticalPan,
      autoRotate: t < 0.5 ? a.autoRotate : b.autoRotate,
      autoRotateSpeed: ui.lerpDouble(a.autoRotateSpeed, b.autoRotateSpeed, t) ??
          b.autoRotateSpeed,
      pauseOnTouch: t < 0.5 ? a.pauseOnTouch : b.pauseOnTouch,
    );
  }
}
