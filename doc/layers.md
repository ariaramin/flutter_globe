# Layers

Use layers for overlays that are independent of the built-in marker and arc lists.

| Layer | Purpose and common configuration |
| --- | --- |
| `GlobeGridLayer` | Graticule lines; `customStyle` overrides `theme.grid`. |
| `GlobeHeatmapLayer` | Radial heat points; `points`, `gradient`, `opacity`. |
| `GlobeLabelLayer` | Labels and leader lines; supports explicit `textDirection`. |
| `GlobeRegionLayer` | Stylized polygons; selected/hovered state is supplied by the app. |
| `GlobeRouteLayer` | Multi-stop routes and moving vehicles. |
| `GlobeDayNightLayer` | Illustrative shading; not an astronomical solar calculation. |
| `GlobeParticleLayer` | Seeded orbital points; set `seed` for reproducible scenes and keep the instance stable across rebuilds. |

```dart
const Globe(layers: [
  GlobeGridLayer(customStyle: GlobeGridStyle(latitudeInterval: 30, longitudeInterval: 45)),
  GlobeLabelLayer(labels: [GlobeLabel(
    coordinate: GlobeCoordinate(latitude: 35.6892, longitude: 51.3890),
    text: 'تهران', textDirection: TextDirection.rtl,
  )]),
]);
```

## Custom layer

```dart
class CenterRing extends GlobeLayer {
  const CenterRing() : super(zIndex: 30);

  @override
  void paint(GlobeRenderContext context) {
    final paint = Paint()
      ..color = context.theme.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    context.canvas.drawCircle(context.camera.center, context.camera.radius * 0.2, paint);
  }
}
```

Add `const CenterRing()` to `layers`. The render context supplies Canvas, viewport, camera, rotation, theme, quality, and elapsed scene time. Project a coordinate by rotating its vector and passing it to `context.camera.project`. Check depth before painting a rear point.

## Paint contract

Layers are ordered by `zIndex`: below 10 before the land dots, 10–19 inside the sphere clip, and 20+ above markers/arcs. The atmospheric rim is drawn last. Balance your own `canvas.save`/`restore` calls. Do not perform I/O or change widget state while painting. `enabled: false` skips the layer.

Heatmaps accept any gradient of at least two colors; shorter gradients and empty point lists render nothing. Regions with fewer than three vertices are skipped. Region horizon clipping is approximate, so do not use it for precise boundaries.

Layers paint only; use marker/surface callbacks or parallel Flutter controls for interaction and selection.
