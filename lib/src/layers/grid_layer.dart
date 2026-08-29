import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../math/globe_projection.dart';
import '../math/matrix3d.dart';
import '../math/quaternion.dart';
import '../themes/globe_style_models.dart';
import 'globe_layer.dart';

/// Renders geographic graticule lines (latitudes, longitudes, equator, tropics) on the globe.
class GlobeGridLayer extends GlobeLayer {
  /// Creates a graticule overlay using the theme grid or a custom override.
  const GlobeGridLayer({
    super.enabled = true,
    super.zIndex = 5,
    this.customStyle,
  });

  /// Grid override; null uses the active theme grid.
  final GlobeGridStyle? customStyle;

  @override
  void paint(GlobeRenderContext context) {
    final Paint basePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
    final Paint equatorPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    final style = customStyle ?? context.theme.grid;
    if (!style.visible) return;

    final canvas = context.canvas;
    final camera = context.camera;
    final rotation = context.rotation;

    basePaint
      ..strokeWidth = style.strokeWidth
      ..color = style.color;

    equatorPaint
      ..strokeWidth = style.strokeWidth * 1.5
      ..color = style.equatorColor;

    // 1. Latitude parallels
    final latStep = style.latitudeInterval.clamp(10.0, 90.0);
    for (var lat = -90.0 + latStep; lat < 90.0; lat += latStep) {
      final isEquator = lat.abs() < 1e-4;
      if (isEquator && !style.highlightEquator) continue;

      _drawLatitudeParallel(
        canvas: canvas,
        camera: camera,
        latDegrees: lat,
        rotation: rotation,
        paint: isEquator ? equatorPaint : basePaint,
      );
    }

    // 2. Longitude meridians
    final lngStep = style.longitudeInterval.clamp(10.0, 180.0);
    for (var lng = -180.0; lng < 180.0; lng += lngStep) {
      final isPrime = lng.abs() < 1e-4;
      if (isPrime && !style.highlightPrimeMeridian) continue;

      _drawLongitudeMeridian(
        canvas: canvas,
        camera: camera,
        lngDegrees: lng,
        rotation: rotation,
        paint: isPrime ? equatorPaint : basePaint,
      );
    }
  }

  void _drawLatitudeParallel({
    required Canvas canvas,
    required GlobeCamera camera,
    required double latDegrees,
    required Quaternion3D rotation,
    required Paint paint,
  }) {
    const segments = 48;
    final path = Path();
    final cached = Float32List((segments + 1) * 3);
    {
      final latRad = latDegrees * (math.pi / 180.0);
      final cosLat = math.cos(latRad);
      final sinLat = math.sin(latRad);
      for (var i = 0; i <= segments; i++) {
        final lngRad = (i / segments) * 2.0 * math.pi;
        final ptr = i * 3;
        cached[ptr] = cosLat * math.sin(lngRad);
        cached[ptr + 1] = -sinLat;
        cached[ptr + 2] = cosLat * math.cos(lngRad);
      }
    }

    path.reset();
    var hasStarted = false;

    final qx = rotation.x;
    final qy = rotation.y;
    final qz = rotation.z;
    final qw = rotation.w;

    final cx = camera.center.dx;
    final cy = camera.center.dy;
    final radius = camera.radius;
    final altitude = camera.altitude;
    final isOrthographic = camera.projection == GlobeProjection.orthographic;
    final radiusAltitude = radius * altitude;

    for (var i = 0; i <= segments; i++) {
      final ptr = i * 3;
      final vx = cached[ptr];
      final vy = cached[ptr + 1];
      final vz = cached[ptr + 2];

      final tx = 2.0 * (qy * vz - qz * vy);
      final ty = 2.0 * (qz * vx - qx * vz);
      final tz = 2.0 * (qx * vy - qy * vx);

      final rx = vx + qw * tx + (qy * tz - qz * ty);
      final ry = vy + qw * ty + (qz * tx - qx * tz);
      final rz = vz + qw * tz + (qx * ty - qy * tx);

      if (rz < -0.05) {
        hasStarted = false;
        continue;
      }

      final double px;
      final double py;
      if (isOrthographic) {
        px = cx + rx * radius;
        py = cy + ry * radius;
      } else {
        final denom = math.max(0.1, altitude - rz);
        final rScale = radiusAltitude / denom;
        px = cx + rx * rScale;
        py = cy + ry * rScale;
      }

      if (!hasStarted) {
        path.moveTo(px, py);
        hasStarted = true;
      } else {
        path.lineTo(px, py);
      }
    }

    if (hasStarted) {
      canvas.drawPath(path, paint);
    }
  }

  void _drawLongitudeMeridian({
    required Canvas canvas,
    required GlobeCamera camera,
    required double lngDegrees,
    required Quaternion3D rotation,
    required Paint paint,
  }) {
    const segments = 48;
    final path = Path();
    final cached = Float32List((segments + 1) * 3);
    {
      final lngRad = lngDegrees * (math.pi / 180.0);
      final cosLng = math.cos(lngRad);
      final sinLng = math.sin(lngRad);
      for (var i = 0; i <= segments; i++) {
        final latRad = -math.pi * 0.5 + (i / segments) * math.pi;
        final cosLat = math.cos(latRad);
        final sinLat = math.sin(latRad);
        final ptr = i * 3;
        cached[ptr] = cosLat * sinLng;
        cached[ptr + 1] = -sinLat;
        cached[ptr + 2] = cosLat * cosLng;
      }
    }

    path.reset();
    var hasStarted = false;

    final qx = rotation.x;
    final qy = rotation.y;
    final qz = rotation.z;
    final qw = rotation.w;

    final cx = camera.center.dx;
    final cy = camera.center.dy;
    final radius = camera.radius;
    final altitude = camera.altitude;
    final isOrthographic = camera.projection == GlobeProjection.orthographic;
    final radiusAltitude = radius * altitude;

    for (var i = 0; i <= segments; i++) {
      final ptr = i * 3;
      final vx = cached[ptr];
      final vy = cached[ptr + 1];
      final vz = cached[ptr + 2];

      final tx = 2.0 * (qy * vz - qz * vy);
      final ty = 2.0 * (qz * vx - qx * vz);
      final tz = 2.0 * (qx * vy - qy * vx);

      final rx = vx + qw * tx + (qy * tz - qz * ty);
      final ry = vy + qw * ty + (qz * tx - qx * tz);
      final rz = vz + qw * tz + (qx * ty - qy * tx);

      if (rz < -0.05) {
        hasStarted = false;
        continue;
      }

      final double px;
      final double py;
      if (isOrthographic) {
        px = cx + rx * radius;
        py = cy + ry * radius;
      } else {
        final denom = math.max(0.1, altitude - rz);
        final rScale = radiusAltitude / denom;
        px = cx + rx * rScale;
        py = cy + ry * rScale;
      }

      if (!hasStarted) {
        path.moveTo(px, py);
        hasStarted = true;
      } else {
        path.lineTo(px, py);
      }
    }

    if (hasStarted) {
      canvas.drawPath(path, paint);
    }
  }
}
