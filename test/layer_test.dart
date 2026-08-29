import 'package:flutter/material.dart';
import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_test/flutter_test.dart';

class _CustomTestLayer extends GlobeLayer {
  _CustomTestLayer() : super(zIndex: 50);
  bool didPaint = false;

  @override
  void paint(GlobeRenderContext context) {
    didPaint = true;
  }
}

class _QualityTestLayer extends GlobeLayer {
  GlobeQuality? quality;

  @override
  void paint(GlobeRenderContext context) => quality = context.quality;
}

void main() {
  testWidgets('auto quality resolves from the rendered globe size',
      (tester) async {
    for (final entry in <(double, GlobeQuality)>[
      (200, GlobeQuality.low),
      (400, GlobeQuality.medium),
      (800, GlobeQuality.high),
    ]) {
      final layer = _QualityTestLayer();
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: Globe(
            size: entry.$1,
            autoRotate: false,
            introAnimation: GlobeIntroAnimation.none,
            layers: [layer],
          ),
        ),
      ));
      await tester.pump();
      expect(layer.quality, entry.$2);
    }
  });

  testWidgets('heatmaps accept any multi-stop gradient', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Globe(
      size: 200,
      introAnimation: GlobeIntroAnimation.none,
      layers: [
        GlobeHeatmapLayer(
          gradient: [Colors.blue, Colors.orange, Colors.red],
          points: [
            GlobeHeatPoint(
                coordinate: GlobeCoordinate(latitude: 0, longitude: 0))
          ],
        )
      ],
    )));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  group('Globe Layer Tests', () {
    testWidgets(
        'mounts globe with all standard and custom layers without throwing',
        (tester) async {
      final customLayer = _CustomTestLayer();

      final layers = [
        const GlobeGridLayer(),
        const GlobeHeatmapLayer(
          points: [
            GlobeHeatPoint(
              coordinate:
                  GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
              intensity: 0.9,
            ),
          ],
        ),
        const GlobeRouteLayer(
          routes: [
            GlobeRoute(
              waypoints: [
                GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
                GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
              ],
            ),
          ],
        ),
        const GlobeRegionLayer(
          regions: [
            GlobeRegion(
              id: 'sample_polygon',
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
              text: 'London',
            ),
          ],
        ),
        GlobeParticleLayer(),
        const GlobeDayNightLayer(),
        customLayer,
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Globe(
                  layers: layers,
                  introAnimation: GlobeIntroAnimation.none,
                  autoRotate: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(customLayer.didPaint, isTrue);
      expect(find.byType(Globe), findsOneWidget);
    });
  });
}
