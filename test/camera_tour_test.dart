import 'package:flutter/material.dart';
import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Camera Tour & Controller Tests', () {
    test('controller lookAt instantly updates rotation', () {
      final controller = GlobeController();
      const sf = GlobeCoordinate(latitude: 37.7749, longitude: -122.4194);

      controller.lookAt(sf);

      final rotatedSf = controller.rotation.rotateVector(sf.toVector3D());
      expect(rotatedSf.x, closeTo(0.0, 1e-4));
      expect(rotatedSf.y, closeTo(0.0, 1e-4));
      expect(rotatedSf.z, closeTo(1.0, 1e-4));
    });

    test('controller selectMarker and clearSelection', () {
      final controller = GlobeController();
      final marker = GlobeMarker.latLng(latitude: 0.0, longitude: 0.0);

      expect(controller.selectedMarker, isNull);
      controller.selectMarker(marker);
      expect(controller.selectedMarker, equals(marker));
      controller.clearSelection();
      expect(controller.selectedMarker, isNull);
    });

    test('GlobeTemplates contains complete presets', () {
      expect(GlobeTemplates.all.length, greaterThanOrEqualTo(5));

      for (final template in GlobeTemplates.all) {
        expect(template.name.isNotEmpty, isTrue);
        expect(template.description.isNotEmpty, isTrue);
        expect(template.theme, isNotNull);
      }
    });

    testWidgets('Globe.template builds and renders template', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Globe.template(
                  GlobeTemplates.cyberAttackMap,
                  autoRotate: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Globe), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
