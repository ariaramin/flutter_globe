# Showcase and playground

Run the example from `example/` with `flutter run`. Use the horizontal navigation for Showcase, Skins, Arcs, Markers, Data Layers, Playground, and Benchmarks.

- **Showcase:** default scene, camera pause/reset, intro replay, quick palettes.
- **Skins:** all named presets and theme transitions.
- **Arcs:** altitude and duration controls for the sample connections.
- **Markers:** tap a beacon or focus London with an accessible button.
- **Data Layers:** toggle grids, shading, heatmaps, routes, and particles.
- **Playground:** tune projection, quality, scale, zoom, rotation, inertia, surface/lighting, atmosphere, arcs, and markers; choose presets, reset, randomize, copy code, or hide panels for fullscreen preview.
- **Benchmarks:** deterministic workloads and measured engine timings.

Fullscreen is an in-app preview mode, not the operating system's fullscreen API. Use its exit button to restore controls. Reset restores the reference configuration and zoom; camera orientation reset remains a separate action.

**Copy code** provides a Globe expression or a complete runnable Material app. The geographic marker/arc objects are serialized from the same sample data used by the preview. The export does not include current camera orientation, callbacks, or data-layer configurations; it is disabled on Data Layers and Benchmarks rather than claiming a complete export.

Skin changes may animate through intermediate colors. The export represents the target configuration, not the in-flight interpolation. See [assets](assets.md) for capture instructions.
