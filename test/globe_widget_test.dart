import 'package:flutter/material.dart';
import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_globe/src/rendering/globe_painter.dart';

void main() {
  testWidgets(
      'paused camera still advances intro and scene time; reduced motion freezes it',
      (tester) async {
    Widget scene(bool reduced) => MaterialApp(
            home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: const Center(child: Globe(size: 200, autoRotate: false)),
        ));
    GlobePainter painter() => tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((w) => w.painter)
        .whereType<GlobePainter>()
        .single;
    await tester.pumpWidget(scene(false));
    await tester.pump(const Duration(milliseconds: 500));
    expect(painter().introProgress, greaterThan(0));
    final elapsed = painter().animationTimeMs;
    await tester.pump(const Duration(milliseconds: 100));
    expect(painter().animationTimeMs, greaterThan(elapsed));
    await tester.pumpWidget(scene(true));
    await tester.pump(const Duration(milliseconds: 20));
    final frozen = painter().animationTimeMs;
    await tester.pump(const Duration(seconds: 1));
    expect(painter().introProgress, 1);
    expect(painter().animationTimeMs, frozen);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty and tiny scenes and zero-duration marker pulses are safe',
      (tester) async {
    for (final size in [0.0, 1.0, 1000.0]) {
      await tester.pumpWidget(MaterialApp(
          home: Center(
              child: Globe(
        size: size,
        introAnimation: GlobeIntroAnimation.none,
        markers: const [
          GlobeMarker(
              coordinate: GlobeCoordinate(latitude: 0, longitude: 0),
              pulseDuration: Duration.zero)
        ],
        layers: const [GlobeHeatmapLayer(points: [], gradient: [])],
      ))));
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
      'external controller survives widget disposal during an autoplay tour',
      (tester) async {
    final controller = GlobeController();
    await tester.pumpWidget(MaterialApp(
        home: Globe(
      size: 200,
      controller: controller,
      tour: const GlobeTour(stops: [
        GlobeTourStop(coordinate: GlobeCoordinate(latitude: 0, longitude: 0)),
        GlobeTourStop(coordinate: GlobeCoordinate(latitude: 20, longitude: 30)),
      ]),
    )));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
    expect(controller.isTourPlaying, isFalse);
    expect(tester.takeException(), isNull);
    controller.zoom = 1.2;
    controller.dispose();
  });

  testWidgets('momentum releases interaction after completing', (tester) async {
    final controller = GlobeController(autoRotate: false);
    await tester.pumpWidget(MaterialApp(
        home: Center(child: Globe(size: 300, controller: controller))));
    await tester.fling(find.byType(Globe), const Offset(100, 0), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(controller.isInteracting, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('grouped interaction settings disable drag rotation',
      (tester) async {
    final controller = GlobeController(autoRotate: false);
    final initialRotation = controller.rotation;
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: Globe(
          size: 300,
          controller: controller,
          interaction: const GlobeInteractionConfig(
            dragEnabled: false,
            autoRotate: false,
          ),
        ),
      ),
    ));
    await tester.drag(find.byType(Globe), const Offset(80, 20));
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.rotation, initialRotation);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  group('Globe Widget Tests', () {
    testWidgets('mounts default Globe widget cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Globe(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Globe), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Pump frames to verify animation ticker runs smoothly without throwing
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('renders markers and animated arcs without exceptions',
        (tester) async {
      final markers = [
        GlobeMarker.latLng(
          latitude: 37.7749,
          longitude: -122.4194,
          label: 'San Francisco',
          color: Colors.cyan,
        ),
        GlobeMarker.latLng(
          latitude: 51.5074,
          longitude: -0.1278,
          label: 'London',
          color: Colors.amber,
        ),
      ];

      final arcs = [
        const GlobeArc(
          start: GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
          end: GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
          color: Colors.cyan,
          altitude: 0.3,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: Globe(
                  markers: markers,
                  arcs: arcs,
                  autoRotate: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Globe), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('handles pan drag rotation interactions', (tester) async {
      final controller = GlobeController(autoRotate: false);
      final initialRot = controller.rotation;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Globe(
                  controller: controller,
                  autoRotate: false,
                ),
              ),
            ),
          ),
        ),
      );

      // Perform a pan drag gesture across the globe
      await tester.drag(find.byType(Globe), const Offset(60.0, 0.0));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      expect(controller.rotation, isNot(equals(initialRot)));
    });

    testWidgets(
        'swiping bottom moves globe top and swiping top moves globe bottom',
        (tester) async {
      final controller = GlobeController(
        initialRotation: Quaternion3D.identity,
        autoRotate: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Globe(
                  controller: controller,
                  autoRotate: false,
                ),
              ),
            ),
          ),
        ),
      );

      // Swiping bottom (positive dy drag down) tilts globe towards top
      await tester.drag(find.byType(Globe), const Offset(0.0, 50.0));
      await tester.pump(const Duration(milliseconds: 50));

      final frontPoint =
          controller.rotation.rotateVector(const Vector3D(0.0, 0.0, 1.0));
      expect(frontPoint.y, greaterThan(0.0));
    });

    testWidgets('fires onGlobeTap and onMarkerTap callbacks', (tester) async {
      GlobeCoordinate? tappedGlobeCoord;
      GlobeMarker? tappedMarker;

      final testMarker = GlobeMarker.latLng(
        latitude: 0.0,
        longitude: 0.0, // Center front
        size: 5.0,
        onTap: () {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: Globe(
                  autoRotate: false,
                  controller: GlobeController(
                    initialRotation: Quaternion3D.identity,
                    autoRotate: false,
                  ),
                  markers: [testMarker],
                  onGlobeTap: (coord) => tappedGlobeCoord = coord,
                  onMarkerTap: (marker) => tappedMarker = marker,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      // Tap marker directly at center
      await tester.tap(find.byType(Globe));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tappedMarker, equals(testMarker));

      // Tap off-center on the globe surface outside marker radius
      final globeCenter = tester.getCenter(find.byType(Globe));
      await tester.tapAt(globeCenter + const Offset(80.0, 0.0));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tappedGlobeCoord, isNotNull);
    });

    testWidgets('honors size, width, and height customization options',
        (tester) async {
      // 1. Test square size customization
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Globe(
                size: 250,
                autoRotate: false,
              ),
            ),
          ),
        ),
      );

      final globeSizeBox = tester.renderObject(find.byType(Globe));
      expect(globeSizeBox.paintBounds.size, equals(const Size(250, 250)));

      // 2. Test explicit width and height customization
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Globe(
                width: 320,
                height: 240,
                autoRotate: false,
                layers: [
                  GlobeGridLayer(
                    customStyle: GlobeGridStyle(
                      color: Colors.cyan,
                      strokeWidth: 1.2,
                      equatorColor: Colors.amber,
                      highlightEquator: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final rectGlobeBox = tester.renderObject(find.byType(Globe));
      expect(rectGlobeBox.paintBounds.size, equals(const Size(320, 240)));
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
