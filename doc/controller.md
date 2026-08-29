# Controller and lifecycle

Use `lookAt`, `rotation`, and `zoom` before attachment to set an initial view. Animated methods need a living `TickerProvider`; a controller is not itself a ticker provider. One controller per mounted globe is recommended.

```dart
class OfficeGlobe extends StatefulWidget {
  const OfficeGlobe({super.key});
  @override
  State<OfficeGlobe> createState() => _OfficeGlobeState();
}

class _OfficeGlobeState extends State<OfficeGlobe> with TickerProviderStateMixin {
  final controller = GlobeController(autoRotate: false);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    SizedBox.square(dimension: 300, child: Globe(controller: controller)),
    FilledButton(
      onPressed: () => controller.flyTo(
        coordinate: const GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
        vsync: this,
        zoom: 1.2,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero : const Duration(seconds: 1),
      ),
      child: const Text('Show London'),
    ),
  ]);
}
```

`flyTo`/`animateTo`, `focusMarker`, `zoomTo`, and `resetView` replace an active camera transition. Zoom is clamped to 0.5–3.5; nonfinite setter/animation targets are rejected. Auto-rotation pauses while a camera transition runs. `reset` is a compatibility alias for `resetView`.

`selectMarker` and `clearSelection` notify listeners; they do not inject UI. Use `ListenableBuilder` or your state system to display the selected payload. Do not call the internal gesture/tick hooks from application code.

The widget disposes only controllers it creates. When supplied externally, dispose the controller before the owning State's `super.dispose`. Widget-started tours are stopped on unmount. Caller-started animations/tours remain the caller's responsibility.

## Camera tours

`GlobeTour` and `GlobeTourStop` are exported for existing controller users, though the showcase intentionally has no Tour tab. `playTour` takes a ticker provider; `stopTour` cancels the timer and stops movement. `onArrival` runs after the transition, followed by the dwell interval. Callbacks may stop the active tour safely. Auto-play is suppressed by system reduced motion.
