import 'package:flutter/material.dart';
import 'globe_style_models.dart';

/// Complete theme configuration bundling all visual styles, lighting, atmosphere, and grid settings.
@immutable
class GlobeTheme {
  /// Creates a complete visual, interaction, and quality configuration.
  const GlobeTheme({
    this.surface = const GlobeSurfaceStyle(),
    this.atmosphere = const GlobeAtmosphereStyle(),
    this.lighting = const GlobeLightingStyle(),
    this.grid = const GlobeGridStyle(),
    this.interaction = const GlobeInteractionConfig(),
    this.quality = GlobeQuality.auto,
    this.accentColor = const Color(0xFF38BDF8),
  });

  /// Surface rendering and land topology style.
  final GlobeSurfaceStyle surface;

  /// Atmospheric glow and halo style.
  final GlobeAtmosphereStyle atmosphere;

  /// Directional and ambient lighting style.
  final GlobeLightingStyle lighting;

  /// Geographic graticule grid style.
  final GlobeGridStyle grid;

  /// Touch, gesture, and rotation interaction configuration.
  final GlobeInteractionConfig interaction;

  /// Performance and detail quality mode.
  final GlobeQuality quality;

  /// Primary accent color used across markers and default arcs.
  final Color accentColor;

  /// Creates a copy of this theme with modified properties.
  GlobeTheme copyWith({
    GlobeSurfaceStyle? surface,
    GlobeAtmosphereStyle? atmosphere,
    GlobeLightingStyle? lighting,
    GlobeGridStyle? grid,
    GlobeInteractionConfig? interaction,
    GlobeQuality? quality,
    Color? accentColor,
  }) {
    return GlobeTheme(
      surface: surface ?? this.surface,
      atmosphere: atmosphere ?? this.atmosphere,
      lighting: lighting ?? this.lighting,
      grid: grid ?? this.grid,
      interaction: interaction ?? this.interaction,
      quality: quality ?? this.quality,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  /// Linearly interpolates between two [GlobeTheme] instances.
  static GlobeTheme lerp(GlobeTheme a, GlobeTheme b, double t) {
    return GlobeTheme(
      surface: GlobeSurfaceStyle.lerp(a.surface, b.surface, t),
      atmosphere: GlobeAtmosphereStyle.lerp(a.atmosphere, b.atmosphere, t),
      lighting: GlobeLightingStyle.lerp(a.lighting, b.lighting, t),
      grid: GlobeGridStyle.lerp(a.grid, b.grid, t),
      interaction: GlobeInteractionConfig.lerp(a.interaction, b.interaction, t),
      quality: t < 0.5 ? a.quality : b.quality,
      accentColor: Color.lerp(a.accentColor, b.accentColor, t) ?? b.accentColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobeTheme &&
          runtimeType == other.runtimeType &&
          surface == other.surface &&
          atmosphere == other.atmosphere &&
          lighting == other.lighting &&
          grid == other.grid &&
          interaction == other.interaction &&
          quality == other.quality &&
          accentColor == other.accentColor;

  @override
  int get hashCode => Object.hash(
        surface,
        atmosphere,
        lighting,
        grid,
        interaction,
        quality,
        accentColor,
      );
}
