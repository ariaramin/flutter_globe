# Skins and themes

Skins are named `GlobeTheme` constants. Use a skin for a complete palette and `copyWith` for focused changes.

```dart
final theme = GlobeSkins.midnight.copyWith(
  surface: GlobeSkins.midnight.surface.copyWith(pointSize: 2),
  atmosphere: GlobeSkins.midnight.atmosphere.copyWith(glowIntensity: 0.6),
);

Globe(theme: theme);
```

`GlobeSkins.named` contains the canonical identifiers. All built-in skins use the dotted land renderer; Grid-oriented presets become grid-like when paired with `GlobeGridLayer`. `GlobeThemeTransition` interpolates colors and numeric tokens without replacing the controller or replaying the intro.

Marker and arc colors belong to their data objects and do not inherit the theme accent automatically. This keeps data-series colors stable during a theme transition.
