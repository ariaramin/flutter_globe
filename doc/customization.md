# Customization, skins, and themes

Use `skin` for a named preset; use `theme` for an explicit configuration. Both accept `GlobeTheme`; no separate skin type is needed.

```dart
Globe(theme: GlobeSkins.cyberpunk.copyWith(
  surface: GlobeSkins.cyberpunk.surface.copyWith(
    pointSize: 2.2, pointOpacity: 0.8, landColor: Colors.cyanAccent,
  ),
  atmosphere: GlobeSkins.cyberpunk.atmosphere.copyWith(
    visible: true, altitude: 0.18, glowIntensity: 0.8,
  ),
));
```

## Precedence

`theme` wins over `skin`. Without either, `GlobeTheme` defaults apply. Renderer bridge values stay internal, so there is one public appearance path.

Marker and arc colors are explicit fields on their data objects; they do not automatically inherit `theme.accentColor`. A grid appears only when a `GlobeGridLayer` is supplied, and that layer reads `theme.grid` unless `customStyle` is set.

`Globe.interaction` supplies the grouped base over theme or skin interaction. Non-null widget shortcuts such as `enableZoom` and `autoRotateSpeed` override the corresponding grouped value. `Globe.quality` similarly takes precedence over the selected theme quality. External controllers retain their initial orientation and rotation state when first attached.

```dart
const Globe(
  interaction: GlobeInteractionConfig(
    dragEnabled: true,
    zoomEnabled: true,
    inertiaEnabled: true,
    inertiaFriction: 0.9,
    autoRotateSpeed: 0.25,
  ),
  quality: GlobeQuality.high,
);
```

## Theme transitions

```dart
GlobeThemeTransition(
  theme: GlobeSkins.ocean,
  builder: (context, theme) => Globe(theme: theme),
);
```

Rebuild this wrapper with another theme to interpolate colors and numeric fields. Discrete fields switch halfway. A skin change should not replace the controller or replay the intro. Provide `duration: Duration.zero` for a manually disabled transition.

## Presets

`GlobeSkins.named` provides 24 presets including reference, classic, minimal, midnight, cyberpunk, hologram, neon, blueprint, glass, terminal, space, ocean, aurora, sunset, ice, lava, monochrome, retro, wireframe, pointCloud, monolith, light, realistic, and topographic. Preset names describe palettes, not separate rendering engines. Aliases include earth/satellite, matrix, and deepSpace.

## Current limits

The built-in surface renderer is dotted. Names such as Hologram and Wireframe describe complete palette/grid presets, not separate surface algorithms. Higher point sizes/opacity can obscure dense data. Atmosphere is a Canvas gradient rather than physical scattering. Theme choices do not change geographic accuracy.
