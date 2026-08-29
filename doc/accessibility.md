# Accessibility

Provide a localized `semanticLabel` for the globe canvas:

```dart
const Globe(semanticLabel: 'Global delivery routes and destination markers');
```

The canvas is exposed as one semantic image. Individual painted markers, arcs, and regions are not separate semantic nodes, so important data needs a parallel list, table, or Flutter control surface. Do not rely on color alone to communicate state.

When `MediaQuery.disableAnimations` is true, the widget skips the intro, freezes decorative scene animation and marker pulses, suppresses autoplay tours and momentum, and stops idle rotation. Static rendering, taps, and programmatic state remain available. Callers should use zero-duration controller transitions when they initiate motion themselves.

Example controls use Flutter buttons, sliders, and switches with touch-sized targets. Validate final applications with their actual localization, text scaling, keyboard path, contrast requirements, and screen reader; the package cannot infer the semantics of application data.
