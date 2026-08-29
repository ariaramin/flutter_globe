# Markers

Markers show points of interest and can carry application data. Use a list outside the build method when data is static.

```dart
final coordinate = GlobeCoordinate.normalized(latitude: 35.6762, longitude: 139.6503);
final marker = GlobeMarker(
  coordinate: coordinate, label: 'Tokyo', size: 4,
  pulse: true, pulseRadius: 16,
  pulseDuration: const Duration(seconds: 2),
  color: Colors.cyan, data: 'tokyo-office',
);
Globe(markers: [marker]);
```

`GlobeCoordinate`'s const constructor asserts latitude [-90, 90] and longitude [-180, 180] in debug builds. Use the `normalized` factory at a data boundary: it rejects nonfinite values and invalid latitude in release builds, then wraps longitude to [-180, 180).

## Selection and accessible alternatives

```dart
final controller = GlobeController(autoRotate: false);
Globe(
  controller: controller,
  onMarkerTap: controller.selectMarker,
  semanticLabel: 'Office locations. Select an office from the adjacent list.',
);
controller.dispose();
```

In a real widget, own and dispose that controller in State, as in the [controller guide](controller.md). A marker's own `onTap` runs before the globe's `onMarkerTap`. Selection does not change marker appearance automatically; rebuild your marker list with the selected color.

Rear markers are occluded. Labels are drawn near visible markers, so dense labels can overlap. Put descriptions in a Flutter panel instead of rendering hundreds of labels. Supply accessible buttons/list items with the same selection callbacks for keyboard and screen-reader users.

Zero pulse duration disables pulse rings. To suppress all motion while preserving the data, honor `MediaQuery.disableAnimations`; disabling auto-rotation alone does not stop pulses.
