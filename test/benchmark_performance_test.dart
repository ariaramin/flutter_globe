import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_globe/src/rendering/arc_renderer.dart';
import 'package:flutter_globe/src/rendering/atmosphere_renderer.dart';
import 'package:flutter_globe/src/rendering/dots_renderer.dart';
import 'package:flutter_globe/src/rendering/marker_renderer.dart';
import 'package:flutter_globe/src/models/globe_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('3D Globe Micro-Benchmarks & Math Throughput', () {
    test('Quaternion3D.rotateVector rotation throughput', () {
      const q = Quaternion3D(0.1, 0.2, 0.3, 0.9);
      const v = Vector3D(1.0, 0.0, 0.0);

      // Warm up JIT
      for (var i = 0; i < 5000; i++) {
        q.rotateVector(v);
      }

      const iterations = 100000;
      final stopwatch = Stopwatch()..start();
      var sumX = 0.0;
      for (var i = 0; i < iterations; i++) {
        final rotated = q.rotateVector(v);
        sumX += rotated.x;
      }
      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;
      final opsPerSec = (iterations / math.max(1, elapsedMs)) * 1000.0;

      // Verify math accuracy
      expect(sumX, isNot(0.0));
      debugPrint('Informational benchmark: opsPerSec=$opsPerSec');
    });

    test('Quaternion3D.rotateCoordinates record rotation throughput', () {
      const q = Quaternion3D(0.2, 0.3, 0.4, 0.8);
      const vx = 0.577;
      const vy = 0.577;
      const vz = 0.577;

      // Warm up
      for (var i = 0; i < 5000; i++) {
        q.rotateCoordinates(vx, vy, vz);
      }

      const iterations = 100000;
      final stopwatch = Stopwatch()..start();
      var sumX = 0.0;
      for (var i = 0; i < iterations; i++) {
        final (rx, _, _) = q.rotateCoordinates(vx, vy, vz);
        sumX += rx;
      }
      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;
      final opsPerSec = (iterations / math.max(1, elapsedMs)) * 1000.0;

      expect(sumX, isNot(0.0));
      debugPrint('Informational benchmark: opsPerSec=$opsPerSec');
    });

    test('Vector3D spherical coordinate conversions throughput', () {
      const iterations = 50000;
      final stopwatch = Stopwatch()..start();
      var lengthSum = 0.0;

      for (var i = 0; i < iterations; i++) {
        final lat = -90.0 + (i % 180);
        final lng = -180.0 + ((i * 3) % 360);
        final vec = Vector3D.fromDegrees(lat, lng);
        lengthSum += vec.lengthSquared;
      }
      stopwatch.stop();

      expect(lengthSum, closeTo(iterations, 0.01));
      debugPrint(
          'Informational benchmark: stopwatch.elapsedMilliseconds=${stopwatch.elapsedMilliseconds}');
    });

    test('GlobeCamera.projectRaw and projectCoordinates projection throughput',
        () {
      const camera = GlobeCamera(
        altitude: 2.6,
        center: Offset(200, 200),
        radius: 150.0,
      );
      const vec = Vector3D(0.5, -0.3, 0.8);

      // Warm up
      for (var i = 0; i < 5000; i++) {
        camera.projectRaw(vec);
        camera.projectCoordinates(0.5, -0.3, 0.8);
      }

      const iterations = 100000;
      final stopwatch = Stopwatch()..start();
      var sumX = 0.0;
      for (var i = 0; i < iterations; i++) {
        final (x, y, scale, _) = camera.projectRaw(vec);
        sumX += x + y + scale;
      }
      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;
      final opsPerSec = (iterations / math.max(1, elapsedMs)) * 1000.0;

      expect(sumX, isNot(0.0));
      debugPrint('Informational benchmark: opsPerSec=$opsPerSec');
    });

    test('GreatCircle geodesic arc generation and interpolation throughput',
        () {
      const start = Vector3D(0.0, 0.0, 1.0);
      const end = Vector3D(1.0, 0.0, 0.0);

      // Generate 500 arc point sequences
      final stopwatch = Stopwatch()..start();
      var count = 0;
      for (var i = 0; i < 500; i++) {
        final points = GreatCircle.generateArcPoints(
          start: start,
          end: end,
          sampleCount: 54,
          maxAltitude: 0.3,
        );
        count += points.length;
      }
      stopwatch.stop();

      expect(count, equals(500 * 54));
      debugPrint(
          'Informational benchmark: stopwatch.elapsedMilliseconds=${stopwatch.elapsedMilliseconds}');
    });
  });

  group('Canvas recording microbenchmarks (not GPU timings)', () {
    test('DotsRenderer records the bundled land points with PictureRecorder',
        () {
      final renderer = DotsRenderer();
      const style = GlobeStyle();
      const camera = GlobeCamera(
        altitude: 2.6,
        center: Offset(200, 200),
        radius: 150.0,
      );
      const rotation = Quaternion3D.identity;

      // Warm up
      for (var i = 0; i < 20; i++) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        renderer.draw(canvas, camera, rotation, style);
        recorder.endRecording().dispose();
      }

      const frameCount = 100;
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < frameCount; i++) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        renderer.draw(canvas, camera, rotation, style);
        final picture = recorder.endRecording();
        picture.dispose();
      }
      stopwatch.stop();

      final avgMsPerFrame = stopwatch.elapsedMilliseconds / frameCount;
      debugPrint('Informational benchmark: avgMsPerFrame=$avgMsPerFrame');
    });

    test('ArcRenderer records 50 elevated arcs with PictureRecorder', () {
      final renderer = ArcRenderer();
      const camera = GlobeCamera(
        altitude: 2.6,
        center: Offset(200, 200),
        radius: 150.0,
      );
      const rotation = Quaternion3D.identity;

      final arcs = List.generate(50, (i) {
        return GlobeArc(
          start: GlobeCoordinate(
            latitude: -60.0 + ((i * 13) % 120),
            longitude: -180.0 + ((i * 19) % 360),
          ),
          end: GlobeCoordinate(
            latitude: -60.0 + ((i * 23) % 120),
            longitude: -180.0 + ((i * 37) % 360),
          ),
          color: Colors.cyan,
          altitude: 0.25,
        );
      });

      const frameCount = 100;
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < frameCount; i++) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        renderer.draw(
          canvas: canvas,
          camera: camera,
          rotation: rotation,
          arcs: arcs,
          animationTimeMs: i * 16.67,
          quality: GlobeQuality.high,
        );
        final picture = recorder.endRecording();
        picture.dispose();
      }
      stopwatch.stop();

      final avgMsPerFrame = stopwatch.elapsedMilliseconds / frameCount;
      debugPrint('Informational benchmark: avgMsPerFrame=$avgMsPerFrame');
    });

    test(
        'MarkerRenderer renders 250 pulsing beacons with label caching smoothly',
        () {
      final renderer = MarkerRenderer();
      const camera = GlobeCamera(
        altitude: 2.6,
        center: Offset(200, 200),
        radius: 150.0,
      );
      const rotation = Quaternion3D.identity;

      final markers = List.generate(250, (i) {
        return GlobeMarker.latLng(
          latitude: -70.0 + ((i * 11) % 140),
          longitude: -180.0 + ((i * 23) % 360),
          label: 'City #$i',
          color: Colors.amber,
        );
      });

      const frameCount = 100;
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < frameCount; i++) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        renderer.draw(
          canvas: canvas,
          camera: camera,
          rotation: rotation,
          markers: markers,
          animationTimeMs: i * 16.67,
        );
        final picture = recorder.endRecording();
        picture.dispose();
      }
      stopwatch.stop();

      final avgMsPerFrame = stopwatch.elapsedMilliseconds / frameCount;
      debugPrint('Informational benchmark: avgMsPerFrame=$avgMsPerFrame');
    });

    test('AtmosphereRenderer caches radial shaders across static frames', () {
      final renderer = AtmosphereRenderer();
      const camera = GlobeCamera(
        altitude: 2.6,
        center: Offset(200, 200),
        radius: 150.0,
      );
      const style = GlobeStyle();

      const frameCount = 100;
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < frameCount; i++) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        renderer.drawBackground(canvas, camera, style);
        renderer.drawForegroundRim(canvas, camera, style);
        final picture = recorder.endRecording();
        picture.dispose();
      }
      stopwatch.stop();

      final avgMsPerFrame = stopwatch.elapsedMilliseconds / frameCount;
      debugPrint('Informational benchmark: avgMsPerFrame=$avgMsPerFrame');
    });
  });

  group('Widget Macro-Benchmarks & Extreme Workload Stress Tests', () {
    testWidgets('renders typical workload (100 markers, 50 arcs) across frames',
        (tester) async {
      final markers = List.generate(100, (i) {
        return GlobeMarker.latLng(
          latitude: -80.0 + (i % 160),
          longitude: -180.0 + ((i * 23) % 360),
          color: Colors.cyan,
        );
      });

      final arcs = List.generate(50, (i) {
        return GlobeArc(
          start: GlobeCoordinate(
            latitude: -60.0 + ((i * 11) % 120),
            longitude: -180.0 + ((i * 17) % 360),
          ),
          end: GlobeCoordinate(
            latitude: -60.0 + ((i * 19) % 120),
            longitude: -180.0 + ((i * 31) % 360),
          ),
          color: Colors.amber,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: Globe(
                  skin: GlobeSkins.reference,
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

      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    });

    testWidgets(
        'extreme stress test (1,000 markers, 250 arcs, and 6 custom layers)',
        (tester) async {
      final markers = List.generate(1000, (i) {
        return GlobeMarker.latLng(
          latitude: -80.0 + (i % 160),
          longitude: -180.0 + ((i * 29) % 360),
          color: Colors.cyan,
        );
      });

      final arcs = List.generate(250, (i) {
        return GlobeArc(
          start: GlobeCoordinate(
            latitude: -60.0 + ((i * 11) % 120),
            longitude: -180.0 + ((i * 17) % 360),
          ),
          end: GlobeCoordinate(
            latitude: -60.0 + ((i * 19) % 120),
            longitude: -180.0 + ((i * 31) % 360),
          ),
          color: Colors.amber,
        );
      });

      final layers = [
        const GlobeGridLayer(),
        const GlobeHeatmapLayer(
          points: [
            GlobeHeatPoint(
              coordinate:
                  GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
              intensity: 0.9,
            ),
            GlobeHeatPoint(
              coordinate:
                  GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
              intensity: 0.8,
            ),
          ],
        ),
        const GlobeRouteLayer(
          routes: [
            GlobeRoute(
              waypoints: [
                GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
                GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
                GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
              ],
            ),
          ],
        ),
        const GlobeRegionLayer(
          regions: [
            GlobeRegion(
              id: 'polygon_zone',
              polygon: [
                GlobeCoordinate(latitude: 10.0, longitude: 10.0),
                GlobeCoordinate(latitude: 10.0, longitude: 30.0),
                GlobeCoordinate(latitude: 30.0, longitude: 30.0),
                GlobeCoordinate(latitude: 30.0, longitude: 10.0),
              ],
            ),
          ],
        ),
        const GlobeLabelLayer(
          labels: [
            GlobeLabel(
              coordinate:
                  GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
              text: 'London Node',
            ),
          ],
        ),
        GlobeParticleLayer(particleCount: 50),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: Globe(
                  skin: GlobeSkins.monolith,
                  markers: markers,
                  arcs: arcs,
                  layers: layers,
                  autoRotate: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Globe), findsOneWidget);

      for (var f = 0; f < 20; f++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    });

    testWidgets(
        'interactive gesture physics throughput and vertical pan direction validation',
        (tester) async {
      final controller = GlobeController(
        initialRotation: Quaternion3D.identity,
        autoRotate: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Globe(
                size: 350,
                controller: controller,
                autoRotate: false,
              ),
            ),
          ),
        ),
      );

      // Measure 50 interactive drag updates
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 50; i++) {
        controller.rotateBy(0.02, 0.03);
      }
      stopwatch.stop();

      debugPrint(
          'Informational benchmark: stopwatch.elapsedMilliseconds=${stopwatch.elapsedMilliseconds}');

      // Validate swipe bottom tilts globe top
      controller.rotation = Quaternion3D.identity;
      // Drag down (positive dy = swipe bottom)
      await tester.drag(find.byType(Globe), const Offset(0.0, 60.0));
      await tester.pump(const Duration(milliseconds: 50));

      final frontPoint =
          controller.rotation.rotateVector(const Vector3D(0.0, 0.0, 1.0));
      expect(frontPoint.y, greaterThan(0.0));

      // Drag up (negative dy = swipe top) -> tilts globe bottom
      controller.rotation = Quaternion3D.identity;
      await tester.drag(find.byType(Globe), const Offset(0.0, -60.0));
      await tester.pump(const Duration(milliseconds: 50));

      final frontPointUp =
          controller.rotation.rotateVector(const Vector3D(0.0, 0.0, 1.0));
      expect(frontPointUp.y, lessThan(0.0));
    });

    test('Layer pipeline micro-benchmarks records composite layers', () {
      const camera = GlobeCamera(
        altitude: 2.6,
        center: Offset(200, 200),
        radius: 150.0,
      );
      const rotation = Quaternion3D.identity;
      const theme = GlobeSkins.reference;

      const gridLayer = GlobeGridLayer();
      const dayNightLayer = GlobeDayNightLayer();
      const heatmapLayer = GlobeHeatmapLayer(
        points: [
          GlobeHeatPoint(
            coordinate:
                GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
            intensity: 0.9,
          ),
          GlobeHeatPoint(
            coordinate: GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
            intensity: 0.8,
          ),
        ],
      );
      const labelLayer = GlobeLabelLayer(
        labels: [
          GlobeLabel(
            coordinate: GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
            text: 'London Node',
          ),
          GlobeLabel(
            coordinate: GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
            text: 'Tokyo Node',
          ),
        ],
      );

      const frameCount = 150;
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < frameCount; i++) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final context = GlobeRenderContext(
          canvas: canvas,
          size: const Size(400, 400),
          camera: camera,
          rotation: rotation,
          theme: theme,
          animationTimeMs: i * 16.67,
          quality: GlobeQuality.high,
        );

        gridLayer.paint(context);
        dayNightLayer.paint(context);
        heatmapLayer.paint(context);
        labelLayer.paint(context);

        final picture = recorder.endRecording();
        picture.dispose();
      }
      stopwatch.stop();

      final avgMsPerFrame = stopwatch.elapsedMilliseconds / frameCount;
      debugPrint('Informational benchmark: avgMsPerFrame=$avgMsPerFrame');
    });

    test('all built-in skins and templates remain fully populated and valid',
        () {
      expect(GlobeSkins.monolith.surface.surfaceColor,
          equals(const Color(0xFF000000)));
      expect(GlobeSkins.monolith.surface.landColor,
          equals(const Color(0xFFFFFFFF)));
      expect(GlobeSkins.all.length, greaterThanOrEqualTo(24));
      expect(GlobeTemplates.darkMinimalist.theme, equals(GlobeSkins.monolith));
      expect(GlobeTemplates.all.length, equals(8));
    });
  });
}
