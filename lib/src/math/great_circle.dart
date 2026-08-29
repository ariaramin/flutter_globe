import 'dart:math' as math;
import 'vector3.dart';

/// Provides spherical trigonometry and great-circle geodesic curve generation for arcs.
class GreatCircle {
  const GreatCircle._();

  /// Computes the great-circle angular distance (in radians) between two unit vectors.
  static double angularDistance(Vector3D start, Vector3D end) {
    final dot = start.normalized.dot(end.normalized).clamp(-1.0, 1.0);
    return math.acos(dot);
  }

  /// Interpolates a unit vector along the great circle between [start] and [end] at fraction [t] (0.0 to 1.0)
  /// using spherical linear interpolation (slerp).
  static Vector3D slerp(Vector3D start, Vector3D end, double t) {
    final v1 = start.normalized;
    final v2 = end.normalized;
    final dot = v1.dot(v2).clamp(-1.0, 1.0);
    final omega = math.acos(dot);

    if (omega.abs() < 1e-6) {
      return v1;
    }

    final sinOmega = math.sin(omega);
    final scale1 = math.sin((1.0 - t) * omega) / sinOmega;
    final scale2 = math.sin(t * omega) / sinOmega;

    return (v1 * scale1 + v2 * scale2).normalized;
  }

  /// Evaluates a 3D point along an elevated great-circle arc at fraction [t] (0.0 to 1.0).
  ///
  /// The altitude follows a smooth sinusoidal arch profile:
  /// `radius(t) = 1.0 + maxAltitude * sin(pi * t)`.
  static Vector3D evaluateArcPoint({
    required Vector3D start,
    required Vector3D end,
    required double t,
    double maxAltitude = 0.25,
  }) {
    final unitPoint = slerp(start, end, t);
    final altitude = maxAltitude * math.sin(math.pi * t);
    final radius = 1.0 + altitude;
    return unitPoint * radius;
  }

  /// Generates a discrete sequence of [sampleCount] 3D points along an elevated great-circle arc.
  static List<Vector3D> generateArcPoints({
    required Vector3D start,
    required Vector3D end,
    int sampleCount = 48,
    double maxAltitude = 0.25,
  }) {
    final points = <Vector3D>[];
    for (var i = 0; i < sampleCount; i++) {
      final t = i / (sampleCount - 1);
      points.add(evaluateArcPoint(
        start: start,
        end: end,
        t: t,
        maxAltitude: maxAltitude,
      ));
    }
    return points;
  }
}
