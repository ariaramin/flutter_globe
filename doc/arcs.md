# Arcs and routes

Use an arc for a connection between two points. It follows an elevated great circle, with a baseline and traveling highlight.

```dart
const Globe(arcs: [GlobeArc(
  start: GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
  end: GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
  color: Colors.cyan, altitude: 0.3, strokeWidth: 1.5,
  duration: Duration(seconds: 3), delay: Duration(milliseconds: 400),
  dashLength: 0.25, baseLineOpacity: 0.2,
)]);
```

`repeat: false` stops the travel at its endpoint. `duration: Duration.zero` suppresses the traveling highlight while leaving the baseline when enabled. Set `showBaseLine: false` to show only the highlight. Delays use the globe's scene clock; changing an arc does not reset that clock. A new widget key replays the scene/intro.

`startColor` and `endColor` describe the color progression where supported by the arc renderer. `GlobeArcAnimation` is not an input to `GlobeArc`; there is no selectable comet/particle animation engine.

## Multi-stop routes

```dart
const Globe(layers: [GlobeRouteLayer(routes: [GlobeRoute(
  waypoints: [
    GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
    GlobeCoordinate(latitude: 25.2048, longitude: 55.2708),
    GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
  ],
  vehicleType: GlobeVehicleType.airplane,
  duration: Duration(seconds: 8), repeat: false,
)])]);
```

Each leg receives equal animation time, not distance-proportional travel. Empty and single-point routes are skipped. Vehicles are stylized Canvas shapes. Use smaller route counts on constrained devices; each leg records sampled geometry every frame. Existing moving-object trail options do not yet control all vehicle trails.
