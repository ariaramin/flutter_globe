import 'dart:math' as math;
import 'package:meta/meta.dart';
import 'vector3.dart';

/// A quaternion for smooth, gimbal-lock-free 3D rotations and spherical interpolation.
@immutable
class Quaternion3D {
  /// Creates an immutable quaternion with components (x, y, z, w).
  const Quaternion3D(this.x, this.y, this.z, this.w);

  /// The x-component of the imaginary vector part.
  final double x;

  /// The y-component of the imaginary vector part.
  final double y;

  /// The z-component of the imaginary vector part.
  final double z;

  /// The w-component (real scalar part).
  final double w;

  /// The identity quaternion representing zero rotation.
  static const Quaternion3D identity = Quaternion3D(0.0, 0.0, 0.0, 1.0);

  /// Creates a rotation quaternion from an axis and an angle in radians.
  factory Quaternion3D.fromAxisAngle(Vector3D axis, double angleRadians) {
    final halfAngle = angleRadians * 0.5;
    final sinHalf = math.sin(halfAngle);
    final cosHalf = math.cos(halfAngle);
    final normAxis = axis.normalized;

    return Quaternion3D(
      normAxis.x * sinHalf,
      normAxis.y * sinHalf,
      normAxis.z * sinHalf,
      cosHalf,
    );
  }

  /// Creates a rotation quaternion from Euler angles: [pitch] (X-axis), [yaw] (Y-axis), [roll] (Z-axis) in radians.
  factory Quaternion3D.fromEuler(double pitch, double yaw, double roll) {
    final halfPitch = pitch * 0.5;
    final halfYaw = yaw * 0.5;
    final halfRoll = roll * 0.5;

    final sinP = math.sin(halfPitch);
    final cosP = math.cos(halfPitch);
    final sinY = math.sin(halfYaw);
    final cosY = math.cos(halfYaw);
    final sinR = math.sin(halfRoll);
    final cosR = math.cos(halfRoll);

    return Quaternion3D(
      sinP * cosY * cosR - cosP * sinY * sinR,
      cosP * sinY * cosR + sinP * cosY * sinR,
      cosP * cosY * sinR - sinP * sinY * cosR,
      cosP * cosY * cosR + sinP * sinY * sinR,
    );
  }

  /// Creates a rotation quaternion that rotates from unit vector [from] to unit vector [to].
  factory Quaternion3D.fromRotationBetween(Vector3D from, Vector3D to) {
    final v1 = from.normalized;
    final v2 = to.normalized;
    final dot = v1.dot(v2);

    if (dot >= 0.999999) {
      return Quaternion3D.identity;
    } else if (dot <= -0.999999) {
      // Vectors are opposing: choose an orthogonal axis
      var axis = Vector3D.unitX.cross(v1);
      if (axis.lengthSquared < 0.0001) {
        axis = Vector3D.unitY.cross(v1);
      }
      return Quaternion3D.fromAxisAngle(axis.normalized, math.pi);
    }

    final cross = v1.cross(v2);
    final w = 1.0 + dot;
    return Quaternion3D(cross.x, cross.y, cross.z, w).normalized;
  }

  /// Multiplies this quaternion with [other] to combine rotations.
  Quaternion3D operator *(Quaternion3D other) {
    return Quaternion3D(
      w * other.x + x * other.w + y * other.z - z * other.y,
      w * other.y - x * other.z + y * other.w + z * other.x,
      w * other.z + x * other.y - y * other.x + z * other.w,
      w * other.w - x * other.x - y * other.y - z * other.z,
    );
  }

  /// Rotates 3D vector [v] by this quaternion with minimal allocation.
  Vector3D rotateVector(Vector3D v) {
    // Highly optimized inline quaternion-vector rotation:
    // Formula: v' = v + 2 * (q x v) * w + 2 * (q x (q x v))
    // Let t = 2 * (q x v), then v' = v + w * t + (q x t)
    final tx = 2.0 * (y * v.z - z * v.y);
    final ty = 2.0 * (z * v.x - x * v.z);
    final tz = 2.0 * (x * v.y - y * v.x);

    return Vector3D(
      v.x + w * tx + (y * tz - z * ty),
      v.y + w * ty + (z * tx - x * tz),
      v.z + w * tz + (x * ty - y * tx),
    );
  }

  /// Rotates raw Cartesian coordinates (vx, vy, vz) by this quaternion with zero heap allocations.
  /// Returns the rotated coordinates as a lightweight Dart record `(rx, ry, rz)`.
  (double rx, double ry, double rz) rotateCoordinates(
    double vx,
    double vy,
    double vz,
  ) {
    final tx = 2.0 * (y * vz - z * vy);
    final ty = 2.0 * (z * vx - x * vz);
    final tz = 2.0 * (x * vy - y * vx);

    return (
      vx + w * tx + (y * tz - z * ty),
      vy + w * ty + (z * tx - x * tz),
      vz + w * tz + (x * ty - y * tx),
    );
  }

  /// Returns the squared magnitude of this quaternion.
  double get lengthSquared => x * x + y * y + z * z + w * w;

  /// Returns the magnitude of this quaternion.
  double get length => math.sqrt(lengthSquared);

  /// Returns the normalized unit quaternion.
  Quaternion3D get normalized {
    final len = length;
    if (len == 0.0) return Quaternion3D.identity;
    return Quaternion3D(x / len, y / len, z / len, w / len);
  }

  /// Returns the conjugate (inverse for unit quaternions).
  Quaternion3D get conjugate => Quaternion3D(-x, -y, -z, w);

  /// Computes spherical linear interpolation (slerp) between this quaternion and [other] by fraction [t].
  Quaternion3D slerp(Quaternion3D other, double t) {
    var cosTheta = x * other.x + y * other.y + z * other.z + w * other.w;
    var target = other;

    // Use shortest arc path
    if (cosTheta < 0.0) {
      cosTheta = -cosTheta;
      target = Quaternion3D(-other.x, -other.y, -other.z, -other.w);
    }

    if (cosTheta > 0.9995) {
      // Linear interpolation if angles are very close to avoid division by zero
      return Quaternion3D(
        x + (target.x - x) * t,
        y + (target.y - y) * t,
        z + (target.z - z) * t,
        w + (target.w - w) * t,
      ).normalized;
    }

    final theta = math.acos(cosTheta);
    final sinTheta = math.sin(theta);
    final w1 = math.sin((1.0 - t) * theta) / sinTheta;
    final w2 = math.sin(t * theta) / sinTheta;

    return Quaternion3D(
      x * w1 + target.x * w2,
      y * w1 + target.y * w2,
      z * w1 + target.z * w2,
      w * w1 + target.w * w2,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quaternion3D &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z &&
          w == other.w;

  @override
  int get hashCode => Object.hash(x, y, z, w);

  @override
  String toString() =>
      'Quaternion3D(${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)}, ${z.toStringAsFixed(3)}, ${w.toStringAsFixed(3)})';
}
