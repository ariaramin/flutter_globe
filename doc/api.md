# Public API and architecture review

Import only `package:flutter_globe/flutter_globe.dart`. Renderer classes remain in `src/`; projection/math types remain public because custom layers and controllers use them. Camera tour types are exported to match the existing public widget/controller signatures.

## Structure

```text
lib/flutter_globe.dart          public entry point
lib/src/globe.dart              widget, scene clock, owned renderers
lib/src/globe_controller.dart   camera state and transitions
lib/src/models/                coordinates, marker/arc and legacy style values
lib/src/themes/                style tokens, named palettes, interpolation
lib/src/rendering/             Canvas rendering and bundled land data
lib/src/layers/                composable overlays
lib/src/math/                  vectors, quaternions, geodesics, projections
example/lib/main.dart          showcase and playground
example/lib/benchmark.dart     deterministic scenes and engine timing collection
test/                          package regressions and recording microbenchmarks
doc/                           integration, release, and contribution references
```

## Ownership and defaults

The widget owns its scene ticker and renderer caches. It owns the controller only when no external controller is supplied. External controllers can set orientation before mounting, and their owner disposes them. Avoid sharing one controller across simultaneously mounted globes because each scene advances its own clock.

Model constructors are const where practical. Collections are read-only by convention: pass const or unmodifiable lists and replace them on updates. Do not mutate built-in templates or their lists. Coordinates have a checked factory for release-time input validation; const constructors provide debug assertions.

`const Globe()` defaults to an empty overlay scene, perspective projection, automatic rotation, a staged intro, and a dark sphere with land dots and atmosphere. Pinch zoom is opt-in. A localizable `semanticLabel` describes the canvas; accessible per-location controls belong in Flutter UI alongside it.

## Compatibility decisions

- Keep `skin` as the convenient name for a `GlobeTheme` preset; explicit `theme` takes precedence.
- Use `GlobeTheme` as the single public appearance model; renderer bridge values stay internal.
- Keep `reset`/`animateTo` aliases for existing callers; primary names are `resetView`/`flyTo`.
- Export `GlobeTour` and `GlobeTourStop`; no example Tour destination is added.
- Keep `GlobeInteractionConfig` as the grouped advanced path while retaining concise primitive widget options.
- Do not invent `GlobeSkin`, `GlobeMarkerStyle`, or `GlobeArcStyle` wrappers.
- Correct the speed calculation so documented radians/second no longer has an undocumented 0.35 multiplier. Existing integrations may need to reduce their configured speed.

## Stabilization decisions

The v1 audit removed unused surface-algorithm, scanline, rim/specular, arc-animation, particle-preset, and layer-hit metadata rather than freezing promises the renderer did not implement. Theme interaction and quality now affect the widget. Quality profiles control land sampling, arc subdivision, and particle density; `auto` selects a profile from rendered size. Moving-object trail settings now affect airplane trails.

Region horizon clipping remains approximate, and custom layer opacity is controlled by each layer rather than the intro multiplier. Native platform, screen-reader, and lowest-supported-SDK checks remain external release gates.
