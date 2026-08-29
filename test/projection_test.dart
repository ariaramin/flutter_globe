import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('project and unproject round trip in both projections and at zero size',
      () {
    const point = GlobeCoordinate(latitude: 10, longitude: 15);
    for (final projection in GlobeProjection.values) {
      final camera = GlobeCamera(radius: 150, projection: projection);
      final vector = point.toVector3D();
      final result = camera.unproject(
          camera.project(vector).offset, Quaternion3D.identity)!;
      expect(result.x, closeTo(vector.x, 1e-8));
      expect(result.y, closeTo(vector.y, 1e-8));
      expect(result.z, closeTo(vector.z, 1e-8));
    }
    expect(
        const GlobeCamera(radius: 0)
            .unproject(Offset.zero, Quaternion3D.identity),
        isNull);
  });

  group('Globe Projection Tests', () {
    test('perspective projection applies foreshortening based on depth', () {
      const camera = GlobeCamera(
        altitude: 2.5,
        center: Offset(100, 100),
        radius: 50.0,
        projection: GlobeProjection.perspective,
      );

      // Front point (z = 0.5)
      final frontPoint = camera.project(const Vector3D(0.5, 0.0, 0.5));
      // Rear point (z = -0.5)
      final rearPoint = camera.project(const Vector3D(0.5, 0.0, -0.5));

      expect(frontPoint.scale, greaterThan(rearPoint.scale));
      expect(frontPoint.isFrontFacing, isTrue);
      expect(rearPoint.isFrontFacing, isFalse);
    });

    test('orthographic projection maintains constant scale 1.0', () {
      const camera = GlobeCamera(
        altitude: 2.5,
        center: Offset(100, 100),
        radius: 50.0,
        projection: GlobeProjection.orthographic,
      );

      final frontPoint = camera.project(const Vector3D(0.5, 0.0, 0.5));
      final rearPoint = camera.project(const Vector3D(0.5, 0.0, -0.5));

      expect(frontPoint.scale, equals(1.0));
      expect(rearPoint.scale, equals(1.0));
      expect(frontPoint.x, equals(rearPoint.x));
    });

    test('unproject returns 3D vector for point inside sphere radius', () {
      const camera = GlobeCamera(
        altitude: 2.5,
        center: Offset(100, 100),
        radius: 50.0,
      );

      final touchCenter = camera.unproject(
        const Offset(100, 100),
        Quaternion3D.identity,
      );
      expect(touchCenter, isNotNull);
      expect(touchCenter!.x, closeTo(0.0, 0.001));
      expect(touchCenter.y, closeTo(0.0, 0.001));
      expect(touchCenter.z, closeTo(1.0, 0.001));

      // Point outside radius
      final touchOutside = camera.unproject(
        const Offset(200, 200),
        Quaternion3D.identity,
      );
      expect(touchOutside, isNull);
    });
  });
}
