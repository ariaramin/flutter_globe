import 'dart:math' as math;
import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GreatCircle Geodesic Tests', () {
    test('slerp at t=0 returns start vector and at t=1 returns end vector', () {
      const v1 = Vector3D(1.0, 0.0, 0.0);
      const v2 = Vector3D(0.0, 1.0, 0.0);

      final start = GreatCircle.slerp(v1, v2, 0.0);
      expect(start.x, closeTo(1.0, 1e-5));
      expect(start.y, closeTo(0.0, 1e-5));
      expect(start.z, closeTo(0.0, 1e-5));

      final end = GreatCircle.slerp(v1, v2, 1.0);
      expect(end.x, closeTo(0.0, 1e-5));
      expect(end.y, closeTo(1.0, 1e-5));
      expect(end.z, closeTo(0.0, 1e-5));
    });

    test('slerp at t=0.5 bisects orthogonal vectors', () {
      const v1 = Vector3D(1.0, 0.0, 0.0);
      const v2 = Vector3D(0.0, 1.0, 0.0);

      final mid = GreatCircle.slerp(v1, v2, 0.5);
      final expected = 1.0 / math.sqrt(2.0);
      expect(mid.x, closeTo(expected, 1e-5));
      expect(mid.y, closeTo(expected, 1e-5));
      expect(mid.z, closeTo(0.0, 1e-5));
      expect(mid.length, closeTo(1.0, 1e-5));
    });

    test('arc point generation with altitude elevates mid-flight points', () {
      const v1 = Vector3D(1.0, 0.0, 0.0);
      const v2 = Vector3D(0.0, 0.0, 1.0);

      const maxAltitude = 0.35;
      final midPoint = GreatCircle.evaluateArcPoint(
        start: v1,
        end: v2,
        t: 0.5,
        maxAltitude: maxAltitude,
      );

      // Mid-flight radius should be 1.0 + maxAltitude
      expect(midPoint.length, closeTo(1.0 + maxAltitude, 1e-4));
    });

    test('generateArcPoints produces requested sample count', () {
      const v1 = Vector3D(0.0, 1.0, 0.0);
      const v2 = Vector3D(0.0, -1.0, 0.0);

      const count = 30;
      final points = GreatCircle.generateArcPoints(
        start: v1,
        end: v2,
        sampleCount: count,
        maxAltitude: 0.2,
      );

      expect(points.length, equals(count));
    });

    test('angularDistance calculates correct central angle', () {
      const v1 = Vector3D(1.0, 0.0, 0.0);
      const v2 = Vector3D(0.0, 1.0, 0.0);

      final angle = GreatCircle.angularDistance(v1, v2);
      expect(angle, closeTo(math.pi * 0.5, 1e-5));
    });
  });
}
