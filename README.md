<p align="center">
  <img src="assets/readme/banner.png" alt="Isometric Flutter Globe with geographic connection arcs and rendering controls" />
</p>

# Flutter Globe

Interactive Canvas globes for Flutter: markers, animated arcs, themes, and composable data layers.

**v1.0.0 · MIT · Flutter 3.27+ / Dart 3.6+**

The banner is original concept artwork, not a rendering screenshot. See the [release audit](doc/release_readiness.md) for verified checks and platform limits.

[![pub package](https://img.shields.io/pub/v/flutter_globe.svg)](https://pub.dev/packages/flutter_globe)
[![CI](https://github.com/ariaramin/flutter_globe/actions/workflows/ci.yml/badge.svg)](https://github.com/ariaramin/flutter_globe/actions/workflows/ci.yml)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Overview

Use Flutter Globe for a geographic overview in a dashboard, a network visualization, or an interactive location picker. It projects geographic coordinates with Dart math and draws them using Flutter Canvas. It does not embed a web view or download map tiles.

It is a visualization toolkit, not a navigation map or a geographic boundary authority.

## Features

- Perspective and orthographic projection, drag rotation, momentum, and pinch zoom.
- A staged reference-inspired intro with reduced-motion support.
- 24 named theme presets and animated theme transitions.
- Geographic markers with labels, pulses, payloads, and tap callbacks.
- Elevated great-circle arcs and moving vehicles on multi-stop routes.
- Grid, heatmap, region, label, particle, and day/night overlay layers.
- Programmatic camera controls and eight example scene templates.
- A seven-destination showcase with a playground and reproducible benchmark scenes.

Themes map to implemented surface, atmosphere, lighting, interaction, and quality behavior. Preset names describe visual treatments, not separate shader engines. There are no custom fragment shaders or guaranteed frame-rate claims.

## Installation

```bash
flutter pub add flutter_globe
```

```yaml
dependencies:
  flutter_globe: ^1.0.0
```

```bash
flutter pub get
```

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:flutter_globe/flutter_globe.dart';

void main() => runApp(const MaterialApp(
  home: Scaffold(
    backgroundColor: Color(0xFF020617),
    body: Center(child: SizedBox.square(dimension: 360, child: Globe())),
  ),
));
```

In a bounded layout, the minimal widget is `const Globe()`. Default scenes contain no sample markers or arcs. In a `Column` or scroll view, supply a size or wrap with `SizedBox`/`AspectRatio`.

## Reference-inspired scene

```dart
Globe.template(
  GlobeTemplates.globalNetwork,
  introAnimation: GlobeIntroAnimations.reference,
  size: 400,
);
```

The intro uses staged scale, opacity, atmospheric bloom, marker reveal, and arc reveal. “Reference-inspired” describes the visual direction; it does not promise parity or affiliation with another product.

## Skins and themes

```dart
Globe(skin: GlobeSkins.cyberpunk);
```

```dart
Globe(
  theme: GlobeSkins.reference.copyWith(
    surface: GlobeSkins.reference.surface.copyWith(
      landColor: Colors.tealAccent,
      pointSize: 2,
    ),
    atmosphere: const GlobeAtmosphereStyle(color: Colors.teal),
  ),
);
```

Use `GlobeSkins.named` to discover names and `GlobeThemeTransition` for transitions. See [customization and precedence](doc/customization.md).

| Skin | Treatment |
| --- | --- |
| Reference | Slate land dots and a cyan atmosphere |
| Midnight | Violet accents on a deep navy sphere |
| Cyberpunk | Cyan land with violet and pink atmosphere |
| Hologram | Translucent cyan sphere with grid-ready styling |
| Minimal | Restrained slate palette |
| Wireframe | Fine dots intended to pair with `GlobeGridLayer` |

## Markers

```dart
Globe(markers: [
  GlobeMarker.latLng(
    latitude: 51.5074, longitude: -0.1278,
    label: 'London', color: Colors.cyan, pulse: true,
  ),
]);
```

Use `onMarkerTap` to update application state. For remote data, validate with `GlobeCoordinate.normalized`. Supply an accessible list alongside the canvas. [Marker guide](doc/markers.md).

## Arcs

```dart
const Globe(arcs: [
  GlobeArc(
    start: GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
    end: GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
    altitude: 0.28,
    duration: Duration(seconds: 3),
    repeat: true,
  ),
]);
```

[Arc and route guide](doc/arcs.md) explains timing, static baselines, gradients, and scene costs.

## Layers

```dart
const Globe(layers: [
  GlobeGridLayer(),
  GlobeHeatmapLayer(points: [
    GlobeHeatPoint(
      coordinate: GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
      intensity: 0.8,
    ),
  ]),
]);
```

[Layer guide](doc/layers.md) includes a custom painter layer and the clipping/z-order contract.

## Intro animation

```dart
const Globe(introAnimation: GlobeIntroAnimation.none);
```

```dart
const Globe(introAnimation: GlobeIntroAnimation(
  duration: Duration(seconds: 2),
  markerDelay: Duration(milliseconds: 500),
  arcDelay: Duration(milliseconds: 800),
));
```

`autoRotate: false` stops camera rotation but leaves marker/arc animations running. System reduced motion skips the intro and freezes the scene clock. [Animation guide](doc/intro_animation.md).

## Controller

```dart
final controller = GlobeController(autoRotate: false);
controller.lookAt(const GlobeCoordinate(latitude: 51.5074, longitude: -0.1278));
controller.zoom = 1.3;
controller.dispose();
```

Pass your controller into `Globe(controller: controller)` and dispose it in the owning State. Animated methods such as `flyTo` require that State's `TickerProvider`. [Complete lifecycle example](doc/controller.md).

## Example and playground

```bash
cd example
flutter pub get
flutter run -d chrome
```

Showcase · Skins · Arcs · Markers · Data Layers · Playground · Benchmarks. No Tour tab.

The playground supports theme presets, projection and quality, scale and zoom, rotation and inertia, surface/lighting, atmosphere, arc and marker controls, reset, randomization, code copy, and fullscreen preview. The exported scene includes the current geographic sample data; data-layer export is not offered. [Example guide](doc/playground.md).

## Performance

```dart
const Globe(quality: GlobeQuality.low, autoRotate: false);
```

`low`, `medium`, `high`, and `ultra` progressively increase land sampling, arc subdivision, and particle density. `auto` selects low, medium, or high from the rendered globe diameter; it does not react to measured frame time. Reduce labels, arcs, particles, and overlays before increasing quality. Reuse stable scene lists. [Performance guide](doc/performance.md).

## Benchmarks

Run the example in profile mode on a native device, select **Benchmarks**, choose a fixed scenario, and press **Run benchmark**. Each run has 2 seconds of warm-up, 8 seconds of measurement, and 2 seconds to collect batched engine timings. Export JSON with **Copy JSON**.

The report distinguishes build duration, raster duration, total latency percentiles, and over-budget frames. FPS, GPU execution time, and memory are unavailable; this web benchmark does not report native engine timings. [Methodology and interpretation](doc/benchmarks.md).

## Platform support

| Platform | Status in this checkout |
| --- | --- |
| Web | Release build and responsive browser flow verified |
| Android | Intended; native build/device validation pending |
| iOS | Intended; native build/device validation pending |
| macOS | Intended; native build/device validation pending |
| Windows | Intended; native build/device validation pending |
| Linux | Intended; native build/device validation pending |

The package uses Flutter Canvas APIs and no platform plugins. The [release report](doc/release_readiness.md) records the exact validation boundary.

## Accessibility

The canvas exposes a configurable semantic image label. Reduced-motion mode skips the intro, decorative pulses, momentum, tours, and scene-clock animation while preserving the static visualization and controls. Applications should provide semantic controls or a parallel list when geographic data must be individually accessible. See [accessibility guidance](doc/accessibility.md).

## API overview

| Area | Entry points |
| --- | --- |
| Widget | `Globe`, `Globe.template` |
| Camera and coordinates | `GlobeController`, `GlobeCoordinate`, `GlobeProjection` |
| Appearance | `GlobeTheme`, `GlobeSkins`, style models, `GlobeThemeTransition` |
| Animation | `GlobeIntroAnimation`, `GlobeIntroAnimations` |
| Geographic data | `GlobeMarker`, `GlobeArc`, `GlobeRoute`, `GlobeHeatPoint` |
| Extension | `GlobeLayer`, `GlobeRenderContext`, built-in layer classes |
| Scenes | `GlobeTemplates`, `GlobeTour`, `GlobeTourStop` |

Use `package:flutter_globe/flutter_globe.dart`; `src/` imports are unsupported. There is no separate `GlobeSkin`, `GlobeMarkerStyle`, or `GlobeArcStyle` class: skins are themes, and markers/arcs carry their own styles. See [API and architecture](doc/api.md).

## Roadmap

Future work may add more surface renderers, community themes, geographic layers, and measured adaptive quality when concrete use cases justify them. Native platform performance and accessibility results will be expanded as real device coverage is contributed.

## Documentation and contributing

Start with [getting started](doc/getting_started.md), [FAQ](doc/faq.md), or [troubleshooting](doc/troubleshooting.md). Contributions should include a focused test and, for visual changes, before/after captures. See [CONTRIBUTING](CONTRIBUTING.md), [Code of Conduct](CODE_OF_CONDUCT.md), and [security policy](SECURITY.md).

## License

The package is available under the [MIT license](LICENSE). Its offline land point cloud is derived from Natural Earth public-domain data; see [attribution](ATTRIBUTION.md). This independent Flutter implementation does not redistribute React Bits source code or proprietary assets.
