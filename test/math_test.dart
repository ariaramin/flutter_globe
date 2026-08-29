import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Vector3D Mathematics', () {
    test('basic arithmetic operations', () {
      const v1 = Vector3D(1.0, 2.0, 3.0);
      const v2 = Vector3D(4.0, 5.0, 6.0);

      expect(v1 + v2, equals(const Vector3D(5.0, 7.0, 9.0)));
      expect(v2 - v1, equals(const Vector3D(3.0, 3.0, 3.0)));
      expect(v1 * 2.0, equals(const Vector3D(2.0, 4.0, 6.0)));
      expect(v2 / 2.0, equals(const Vector3D(2.0, 2.5, 3.0)));
    });

    test('length and normalization', () {
      const v = Vector3D(0.0, 3.0, 4.0);
      expect(v.lengthSquared, closeTo(25.0, 1e-6));
      expect(v.length, closeTo(5.0, 1e-6));

      final norm = v.normalized;
      expect(norm.length, closeTo(1.0, 1e-6));
      expect(norm.x, closeTo(0.0, 1e-6));
      expect(norm.y, closeTo(0.6, 1e-6));
      expect(norm.z, closeTo(0.8, 1e-6));
    });

    test('dot product and cross product', () {
      const x = Vector3D.unitX;
      const y = Vector3D.unitY;
      const z = Vector3D.unitZ;

      expect(x.dot(y), closeTo(0.0, 1e-6));
      expect(x.dot(x), closeTo(1.0, 1e-6));

      expect(x.cross(y), equals(z));
      expect(y.cross(z), equals(x));
      expect(z.cross(x), equals(y));
    });

    test('spherical coordinate conversion for key geographic landmarks', () {
      // Equator & Prime Meridian (0° lat, 0° lng) -> (x=0, y=0, z=1)
      final pOrigin = Vector3D.fromDegrees(0.0, 0.0);
      expect(pOrigin.x, closeTo(0.0, 1e-5));
      expect(pOrigin.y, closeTo(0.0, 1e-5));
      expect(pOrigin.z, closeTo(1.0, 1e-5));

      // North Pole (+90° lat) -> (x=0, y=-1, z=0) in Flutter screen space
      final pNorth = Vector3D.fromDegrees(90.0, 0.0);
      expect(pNorth.x, closeTo(0.0, 1e-5));
      expect(pNorth.y, closeTo(-1.0, 1e-5));
      expect(pNorth.z, closeTo(0.0, 1e-5));

      // South Pole (-90° lat) -> (x=0, y=1, z=0)
      final pSouth = Vector3D.fromDegrees(-90.0, 0.0);
      expect(pSouth.x, closeTo(0.0, 1e-5));
      expect(pSouth.y, closeTo(1.0, 1e-5));
      expect(pSouth.z, closeTo(0.0, 1e-5));

      // 90° East Longitude (0° lat, 90° lng) -> (x=1, y=0, z=0)
      final pEast = Vector3D.fromDegrees(0.0, 90.0);
      expect(pEast.x, closeTo(1.0, 1e-5));
      expect(pEast.y, closeTo(0.0, 1e-5));
      expect(pEast.z, closeTo(0.0, 1e-5));
    });

    test('round-trip conversion between degrees and Vector3D', () {
      const testCases = [
        (37.7749, -122.4194), // San Francisco
        (51.5074, -0.1278), // London
        (35.6762, 139.6503), // Tokyo
        (-33.8688, 151.2093), // Sydney
      ];

      for (final (lat, lng) in testCases) {
        final vec = Vector3D.fromDegrees(lat, lng);
        expect(vec.toLatitudeDegrees(), closeTo(lat, 1e-3));
        expect(vec.toLongitudeDegrees(), closeTo(lng, 1e-3));
      }
    });
  });
}
