import 'dart:math' as math;
import 'dart:ui';
import 'package:meta/meta.dart';
import 'globe_projection.dart';
import 'quaternion.dart';
import 'vector3.dart';

/// Represents a 3D point projected onto the 2D canvas with depth metadata.
@immutable
class ProjectedPoint3D {
  /// Creates a projected point with screen coordinates and depth metadata.
  const ProjectedPoint3D({
    required this.offset,
    required this.depth,
    required this.scale,
    required this.isFrontFacing,
  });

  /// The 2D screen position on the canvas.
  final Offset offset;

  /// The z-depth of the transformed point (-1.0 to 1.0 on unit sphere).
  /// Positive values are facing the camera; negative values are on the rear hemisphere.
  final double depth;

  /// The perspective scale factor at this depth.
  final double scale;

  /// Whether this point is on the front-facing hemisphere towards the camera.
  final bool isFrontFacing;

  /// The x-coordinate on the screen canvas.
  double get x => offset.dx;

  /// The y-coordinate on the screen canvas.
  double get y => offset.dy;
}

/// Camera and projection model for projecting 3D globe coordinates onto the 2D canvas.
@immutable
class GlobeCamera {
  /// Creates a globe camera with altitude, viewport center, screen radius, and projection mode.
  const GlobeCamera({
    this.altitude = 2.5,
    this.center = Offset.zero,
    this.radius = 100.0,
    this.projection = GlobeProjection.perspective,
  });

  /// Distance of camera from the globe center (higher = flatter/orthographic, lower = stronger perspective).
  final double altitude;

  /// Center offset of the globe on the canvas.
  final Offset center;

  /// Screen radius of the globe in logical pixels.
  final double radius;

  /// Projection mode (perspective vs orthographic).
  final GlobeProjection projection;

  /// Projects a 3D point (already rotated by the globe orientation) to 2D screen coordinates.
  ProjectedPoint3D project(Vector3D rotatedPoint) {
    final (screenX, screenY, scale, z) = projectRaw(rotatedPoint);

    return ProjectedPoint3D(
      offset: Offset(screenX, screenY),
      depth: z,
      scale: scale,
      isFrontFacing: z >= 0.0,
    );
  }

  /// High-performance record projection without allocating [ProjectedPoint3D] or [Offset].
  (double x, double y, double scale, double depth) projectRaw(
      Vector3D rotatedPoint) {
    final z = rotatedPoint.z;
    final double scale;
    if (projection == GlobeProjection.orthographic) {
      scale = 1.0;
    } else {
      final denom = math.max(0.1, altitude - z);
      scale = altitude / denom;
    }

    final screenX = center.dx + rotatedPoint.x * radius * scale;
    final screenY = center.dy + rotatedPoint.y * radius * scale;
    return (screenX, screenY, scale, z);
  }

  /// Zero-allocation record projection from raw 3D coordinates.
  (double x, double y, double scale, double depth) projectCoordinates(
    double rx,
    double ry,
    double rz,
  ) {
    final double scale;
    if (projection == GlobeProjection.orthographic) {
      scale = 1.0;
    } else {
      final denom = math.max(0.1, altitude - rz);
      scale = altitude / denom;
    }

    final screenX = center.dx + rx * radius * scale;
    final screenY = center.dy + ry * radius * scale;
    return (screenX, screenY, scale, rz);
  }

  /// Projects a geographic point (lat, lng in radians) rotated by [rotation] quaternion onto the screen.
  ProjectedPoint3D projectSpherical(
    double latRadians,
    double lngRadians,
    Quaternion3D rotation, [
    double elevation = 1.0,
  ]) {
    final v = Vector3D.fromSpherical(latRadians, lngRadians, elevation);
    final rotated = rotation.rotateVector(v);
    return project(rotated);
  }

  /// Inverse projects a 2D screen touch point to geographic coordinates (lat, lng in degrees) on the globe.
  /// Returns null if the screen point is outside the globe disc.
  Vector3D? unproject(Offset screenPoint, Quaternion3D rotation) {
    if (!radius.isFinite || radius <= 0) return null;
    final dx = (screenPoint.dx - center.dx) / radius;
    final dy = (screenPoint.dy - center.dy) / radius;
    final distSquared = dx * dx + dy * dy;

    if (distSquared > 1.0) {
      // Touch point is outside the sphere silhouette
      return null;
    }

    final Vector3D touch3D;
    if (projection == GlobeProjection.orthographic) {
      touch3D = Vector3D(dx, dy, math.sqrt(1.0 - distSquared));
    } else {
      // Intersect the ray from (0, 0, altitude) through the canvas with the unit sphere.
      final a = distSquared + altitude * altitude;
      final discriminant =
          altitude * altitude - distSquared * (altitude * altitude - 1);
      if (discriminant < 0) return null;
      final t = (altitude * altitude - math.sqrt(discriminant)) / a;
      touch3D = Vector3D(dx * t, dy * t, altitude * (1 - t));
    }

    // Un-rotate touch point by inverse (conjugate) rotation quaternion
    return rotation.conjugate.rotateVector(touch3D);
  }
}
