import 'dart:math' as math;
import 'package:meta/meta.dart';

/// A high-performance 3D vector representing Cartesian coordinates (x, y, z)
/// and providing vector mathematics for spherical projections.
@immutable
class Vector3D {
  /// Creates an immutable 3D vector with the given [x], [y], and [z] components.
  const Vector3D(this.x, this.y, this.z);

  /// The x-component of the vector.
  final double x;

  /// The y-component of the vector.
  final double y;

  /// The z-component of the vector.
  final double z;

  /// A vector with all components set to zero.
  static const Vector3D zero = Vector3D(0.0, 0.0, 0.0);

  /// A unit vector pointing along the positive x-axis.
  static const Vector3D unitX = Vector3D(1.0, 0.0, 0.0);

  /// A unit vector pointing along the positive y-axis.
  static const Vector3D unitY = Vector3D(0.0, 1.0, 0.0);

  /// A unit vector pointing along the positive z-axis.
  static const Vector3D unitZ = Vector3D(0.0, 0.0, 1.0);

  /// Converts geographic latitude and longitude (in radians) into a 3D unit sphere vector.
  ///
  /// The conversion maps:
  /// - `x = cos(lat) * sin(lng)`
  /// - `y = -sin(lat)` (Flutter canvas Y-axis is downwards, so positive latitude is up / negative Y)
  /// - `z = cos(lat) * cos(lng)` (positive Z is towards the viewer)
  factory Vector3D.fromSpherical(double latRadians, double lngRadians,
      [double radius = 1.0]) {
    final cosLat = math.cos(latRadians);
    final sinLat = math.sin(latRadians);
    final cosLng = math.cos(lngRadians);
    final sinLng = math.sin(lngRadians);

    return Vector3D(
      radius * cosLat * sinLng,
      -radius * sinLat,
      radius * cosLat * cosLng,
    );
  }

  /// Converts geographic latitude and longitude (in degrees) into a 3D unit sphere vector.
  factory Vector3D.fromDegrees(double latDegrees, double lngDegrees,
      [double radius = 1.0]) {
    final latRad = latDegrees * (math.pi / 180.0);
    final lngRad = lngDegrees * (math.pi / 180.0);
    return Vector3D.fromSpherical(latRad, lngRad, radius);
  }

  /// Adds [other] to this vector.
  Vector3D operator +(Vector3D other) =>
      Vector3D(x + other.x, y + other.y, z + other.z);

  /// Subtracts [other] from this vector.
  Vector3D operator -(Vector3D other) =>
      Vector3D(x - other.x, y - other.y, z - other.z);

  /// Multiplies this vector by scalar [scalar].
  Vector3D operator *(double scalar) =>
      Vector3D(x * scalar, y * scalar, z * scalar);

  /// Divides this vector by scalar [scalar].
  Vector3D operator /(double scalar) =>
      Vector3D(x / scalar, y / scalar, z / scalar);

  /// Computes the dot product of this vector and [other].
  double dot(Vector3D other) => x * other.x + y * other.y + z * other.z;

  /// Computes the cross product of this vector and [other].
  Vector3D cross(Vector3D other) {
    return Vector3D(
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x,
    );
  }

  /// Returns the squared length (magnitude) of this vector.
  double get lengthSquared => x * x + y * y + z * z;

  /// Returns the length (magnitude) of this vector.
  double get length => math.sqrt(lengthSquared);

  /// Returns a normalized unit vector with the same direction, or [zero] if length is 0.
  Vector3D get normalized {
    final len = length;
    if (len == 0.0) return Vector3D.zero;
    return Vector3D(x / len, y / len, z / len);
  }

  /// Computes the Euclidean distance between this vector and [other].
  double distanceTo(Vector3D other) => (this - other).length;

  /// Computes the angular distance in radians between this unit vector and [other].
  double angleTo(Vector3D other) {
    final d = dot(other) / (length * other.length);
    final clamped = d.clamp(-1.0, 1.0);
    return math.acos(clamped);
  }

  /// Linearly interpolates between this vector and [other] by fraction [t].
  Vector3D lerp(Vector3D other, double t) {
    return Vector3D(
      x + (other.x - x) * t,
      y + (other.y - y) * t,
      z + (other.z - z) * t,
    );
  }

  /// Converts this 3D point back into latitude (in degrees).
  double toLatitudeDegrees() {
    final norm = normalized;
    // Since y = -sin(lat), lat = -asin(y)
    return -math.asin(norm.y.clamp(-1.0, 1.0)) * (180.0 / math.pi);
  }

  /// Converts this 3D point back into longitude (in degrees).
  double toLongitudeDegrees() {
    final norm = normalized;
    // x = cos(lat) * sin(lng), z = cos(lat) * cos(lng)
    return math.atan2(norm.x, norm.z) * (180.0 / math.pi);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vector3D &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() =>
      'Vector3D(${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)}, ${z.toStringAsFixed(3)})';
}
