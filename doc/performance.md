# Performance

The renderer records Canvas operations; it does not directly measure GPU execution. Performance depends on device, renderer, viewport, pixel ratio, scene complexity, and other widgets on the screen.

## Quality settings

```dart
const Globe(quality: GlobeQuality.low, size: 300);
```

| Quality | Land stride | Arc samples | Particle stride |
| --- | ---: | ---: | ---: |
| `low` | 4 | 24 | 4 |
| `medium` | 2 | 36 | 2 |
| `high` | 1 | 54 | 1 |
| `ultra` | 1 | 72 | 1 |

`auto` selects low below 320 logical pixels, medium below 600, and high otherwise. This selection uses rendered size, not frame-time feedback. An explicit widget quality overrides theme quality.

## Tune the scene

- Keep marker/arc/layer lists stable until data changes. Replace lists instead of mutating them in place.
- Avoid hundreds of labels; use a detail panel on selection.
- Reduce arcs, route legs, particles, and heat points before reducing land quality.
- Use `pulse: false`, static baselines, or reduced motion when animation is unnecessary.
- Give the globe a bounded viewport and avoid unnecessary parent rebuilds.

Built-in renderer caches are owned by the widget; text layouts are disposed when their cache is evicted or the widget is disposed. Stateless overlays do not retain application coordinates globally. Grid and route geometry is recomputed during painting to avoid process-wide caches; profile dense route scenes before shipping them.

`TickerMode` mutes the scene ticker when Flutter disables an offstage subtree. The next auto-rotation delta is capped to prevent a large camera jump. The component still maintains a ticker when visible; use a static image if a large list needs many noninteractive globe thumbnails.

## Measure

Use a native profile build and the [benchmark workflow](benchmarks.md). Repeat the same scenario several times and compare distributions, not one run or one average. Unit-test PictureRecorder timing excludes rasterization/display and is only an informational CPU recording measurement.
