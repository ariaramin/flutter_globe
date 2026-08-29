# Interaction

Use grouped settings when interaction needs more than one override:

```dart
const Globe(
  interaction: GlobeInteractionConfig(
    dragEnabled: true,
    zoomEnabled: true,
    inertiaEnabled: true,
    inertiaFriction: 0.91,
    rotationSensitivity: 0.004,
    autoRotate: true,
    autoRotateSpeed: 0.25,
    pauseOnTouch: true,
  ),
);
```

`inertiaFriction` is the retained velocity per animation frame and must be at least zero and below one. Lower values settle sooner. Reduced motion disables momentum regardless of this setting.

`Globe.interaction` supplies the grouped base over theme or skin interaction. Non-null `enableZoom`, `rotationSensitivity`, `invertVerticalPan`, `autoRotate`, and `autoRotateSpeed` widget values override their corresponding grouped fields. `interactive: false` remains the master switch for gesture and tap handling.

Marker taps are tested before globe-surface taps. Only front-facing markers are interactive. Canvas layers do not expose a generic hit-testing contract in v1; provide Flutter controls around the globe for layer-specific selection.
