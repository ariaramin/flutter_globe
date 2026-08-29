# Getting started

Use a Flutter application with Dart 3.6+ and Flutter 3.27+. The local release audit uses Flutter 3.47; the minimum SDK still requires a separate CI run.

1. Add a path dependency pointing to this checkout, as shown in the [README](../README.md).
2. Run `flutter pub get`.
3. Import Material and `package:flutter_globe/flutter_globe.dart`.
4. Give the widget bounded width and height.

```dart
const SizedBox.square(dimension: 320, child: Globe());
```

For a responsive view in a bounded parent:

```dart
const AspectRatio(aspectRatio: 1, child: Globe());
```

The default scene uses an empty list of markers, arcs, and layers. The globe rotates and reveals itself on entrance. Use `Globe.template(GlobeTemplates.globalNetwork)` to evaluate a populated sample.

For production data, validate latitude/longitude before creating markers, keep network access outside widgets, and replace lists when data changes instead of mutating lists already passed to the renderer. See [markers](markers.md) and [controller](controller.md).

For animation-free presentation, use a `MediaQuery` with `disableAnimations: true`, or honor the operating system's reduced-motion preference. `autoRotate: false` alone only freezes the camera.

A standalone `Globe` has image semantics when `semanticLabel` is provided, but individual Canvas markers are not semantic buttons. Provide a labeled list or equivalent accessible interaction alongside it.
