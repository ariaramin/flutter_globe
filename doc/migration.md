# Migration to 1.0.0

No earlier public release is documented in this checkout. The following pre-release APIs were removed before the stable boundary because they did not affect rendering:

- `GlobeSurfaceType` and the `type`, `oceanColor`, `glowColor`, and `scanlineEffect` surface fields.
- `GlobeArcAnimation`.
- Independent rim/specular lighting fields.
- Generic layer hit-test metadata and the undispatched region tap callback.
- `GlobeParticlePreset`; the supported particle layer is deterministic orbital motion.
- The overlapping `GlobeStyle` and `GlobeAtmosphere` public models; use `GlobeTheme` and `GlobeAtmosphereStyle`.

Theme `quality` and `interaction` are now applied. `Globe.interaction` is the grouped base, non-null widget shortcuts override individual fields, and `Globe.quality` overrides theme quality. Auto-rotation speed uses radians per second without the previous hidden multiplier. Moving airplane trails now honor `showTrail` and `trailLength`.

Because these changes precede the first documented public version, no deprecated compatibility layer is carried into v1.
