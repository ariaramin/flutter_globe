# Benchmarks

The example's **Benchmarks** destination measures fixed scenes, not production guarantees.

```bash
cd example
flutter run --profile -d YOUR_DEVICE_ID
```

Select the scenario and quality, then press **Run benchmark**. Keep the app foregrounded and do not resize it during a run. Every scene uses seed `1337`, fixed geographic coordinates, fixed camera initialization, a reference palette, and a bounded square viewport.

| Scenario | Markers | Arcs | Particles |
| --- | ---: | ---: | ---: |
| baseline | 25 | 10 | 0 |
| typical | 100 | 75 | 250 |
| dense | 500 | 250 | 1,000 |
| stress | 1,000 | 500 | 5,000 |
| developerExtreme | 5,000 | 2,000 | 10,000 |

`developerExtreme` is a profiling stress test, not a recommended production scene.

A run warms up for 2 seconds, measures for 8 seconds, and waits another 2 seconds for batched engine timings. Samples are filtered by their vsync timestamp against the measurement window, so a late warm-up batch is excluded. Navigating away cancels timers and unregisters the callback.

## Metrics

| Metric | Interpretation |
| --- | --- |
| buildMeanMs | Mean engine-reported UI/build duration. |
| rasterMeanMs | Mean engine-reported raster-thread duration; not GPU execution time. |
| latencyMeanMs / P90 / P95 / P99 | `FrameTiming.totalSpan`, including pipeline latency. Percentiles use nearest rank. |
| overBudgetFrames | Frames whose build or raster duration exceeds the display's reported refresh budget. Not dropped frames. |
| samples | Number of engine frames in the measurement window. |
| FPS / GPU / memory | Unavailable (`null`), never inferred from reciprocal latency. |

The result view includes a frame-time timeline and the display-derived frame budget. The benchmark deliberately reports native timing metrics as unavailable on web. Missing samples on any platform remain unavailable rather than zero. Debug builds display a warning and cannot support performance comparisons.

**Copy JSON** exports a versioned object with package version, seed, scenario, scene counts, quality, platform/build mode, viewport, pixel ratio, refresh rate, phase durations, samples, and metrics. Add the device model, OS, Flutter/Dart versions, renderer, power/thermal conditions, and commit identifier when sharing a report; values unavailable to the app are not guessed.

Flutter's [timing callback contract](https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addTimingsCallback.html) explains batching and the distinction between pipeline latency and missed-frame budgets.
