import 'dart:math' as math;
import 'package:meta/meta.dart';
import '../math/great_circle.dart';
import '../math/vector3.dart';

/// Represents a geographic coordinate with latitude and longitude in degrees.
@immutable
class GlobeCoordinate {
  /// Creates a geographic coordinate.
  ///
  /// [latitude] must be between -90.0 and 90.0 degrees.
  /// [longitude] must be between -180.0 and 180.0 degrees.
  /// Use [GlobeCoordinate.normalized] to validate external data and wrap longitude.
  const GlobeCoordinate({
    required this.latitude,
    required this.longitude,
  })  : assert(
          latitude >= -90.0 && latitude <= 90.0,
          'Latitude must be between -90 and 90 degrees.',
        ),
        assert(longitude >= -180 && longitude <= 180,
            'Longitude must be between -180 and 180 degrees.');

  /// Validates external coordinates in release builds and wraps longitude.
  /// Throws [ArgumentError] for nonfinite values or latitude outside `[-90, 90]`.
  factory GlobeCoordinate.normalized(
      {required double latitude, required double longitude}) {
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      throw ArgumentError.value(
          latitude, 'latitude', 'Expected a finite value in [-90, 90]');
    }
    if (!longitude.isFinite) {
      throw ArgumentError.value(
          longitude, 'longitude', 'Expected a finite value');
    }
    return GlobeCoordinate(
        latitude: latitude, longitude: (longitude + 180) % 360 - 180);
  }

  /// Geographic latitude in degrees (-90.0 to +90.0).
  final double latitude;

  /// Geographic longitude in degrees (-180.0 to +180.0).
  final double longitude;

  /// Geographic latitude in radians.
  double get latitudeRadians => latitude * (math.pi / 180.0);

  /// Geographic longitude in radians.
  double get longitudeRadians => longitude * (math.pi / 180.0);

  /// Converts this geographic coordinate into a 3D unit vector.
  Vector3D toVector3D([double radius = 1.0]) =>
      Vector3D.fromSpherical(latitudeRadians, longitudeRadians, radius);

  /// Creates a [GlobeCoordinate] from a 3D Cartesian vector.
  factory GlobeCoordinate.fromVector3D(Vector3D v) {
    return GlobeCoordinate(
      latitude: v.toLatitudeDegrees(),
      longitude: v.toLongitudeDegrees(),
    );
  }

  /// Computes the great-circle angular distance (in radians) to [other].
  double angularDistanceTo(GlobeCoordinate other) {
    return GreatCircle.angularDistance(toVector3D(), other.toVector3D());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobeCoordinate &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() =>
      'GlobeCoordinate(lat: ${latitude.toStringAsFixed(4)}, lng: ${longitude.toStringAsFixed(4)})';
}
