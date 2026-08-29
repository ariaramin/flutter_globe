import 'dart:math' as math;
import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Quaternion3D Rotations', () {
    test('identity quaternion preserves vectors', () {
      const q = Quaternion3D.identity;
      const v = Vector3D(1.0, 2.0, 3.0);
      final rotated = q.rotateVector(v);

      expect(rotated.x, closeTo(1.0, 1e-6));
      expect(rotated.y, closeTo(2.0, 1e-6));
      expect(rotated.z, closeTo(3.0, 1e-6));
    });

    test('90 degree rotation around Y axis', () {
      // Rotating (0, 0, 1) by +90° around Y-axis should map to (1, 0, 0)
      final q = Quaternion3D.fromAxisAngle(Vector3D.unitY, math.pi / 2.0);
      const v = Vector3D(0.0, 0.0, 1.0);
      final rotated = q.rotateVector(v);

      expect(rotated.x, closeTo(1.0, 1e-5));
      expect(rotated.y, closeTo(0.0, 1e-5));
      expect(rotated.z, closeTo(0.0, 1e-5));
    });

    test('180 degree rotation around Y axis', () {
      // Rotating (0, 0, 1) by 180° around Y-axis should map to (0, 0, -1)
      final q = Quaternion3D.fromAxisAngle(Vector3D.unitY, math.pi);
      const v = Vector3D(0.0, 0.0, 1.0);
      final rotated = q.rotateVector(v);

      expect(rotated.x, closeTo(0.0, 1e-5));
      expect(rotated.y, closeTo(0.0, 1e-5));
      expect(rotated.z, closeTo(-1.0, 1e-5));
    });

    test('quaternion multiplication combines successive rotations', () {
      final q1 = Quaternion3D.fromAxisAngle(Vector3D.unitY, math.pi / 4.0);
      final q2 = Quaternion3D.fromAxisAngle(Vector3D.unitY, math.pi / 4.0);
      final combined = (q2 * q1).normalized;

      final expected =
          Quaternion3D.fromAxisAngle(Vector3D.unitY, math.pi / 2.0);
      const v = Vector3D(0.0, 0.0, 1.0);

      final r1 = combined.rotateVector(v);
      final r2 = expected.rotateVector(v);

      expect(r1.x, closeTo(r2.x, 1e-5));
      expect(r1.y, closeTo(r2.y, 1e-5));
      expect(r1.z, closeTo(r2.z, 1e-5));
    });

    test('slerp smoothly interpolates between orientations', () {
      const qStart = Quaternion3D.identity;
      final qEnd = Quaternion3D.fromAxisAngle(Vector3D.unitY, math.pi / 2.0);

      final qMid = qStart.slerp(qEnd, 0.5);
      const v = Vector3D(0.0, 0.0, 1.0);
      final rotated = qMid.rotateVector(v);

      // At 45 degrees: x = sin(45) = ~0.7071, z = cos(45) = ~0.7071
      expect(rotated.x, closeTo(math.sqrt(0.5), 1e-4));
      expect(rotated.y, closeTo(0.0, 1e-4));
      expect(rotated.z, closeTo(math.sqrt(0.5), 1e-4));
    });
  });
}
