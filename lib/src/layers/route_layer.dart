import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../math/great_circle.dart';
import '../math/matrix3d.dart';
import '../math/quaternion.dart';
import '../math/vector3.dart';
import '../models/globe_coordinate.dart';
import '../themes/globe_style_models.dart';
import 'globe_layer.dart';

/// Supported types of moving vehicles/objects along routes.
enum GlobeVehicleType {
  /// Realistic commercial passenger jet airliner oriented in flight direction.
  airplane,

  /// Luminous satellite beacon with solar panels.
  satellite,

  /// Glowing high-speed data packet / photon.
  packet,

  /// Maritime cargo or passenger ship.
  ship,
}

/// Represents a multi-stop geographic route connecting sequential waypoints.
@immutable
class GlobeRoute {
  /// Creates a multi-leg route. Fewer than two waypoints render nothing.
  const GlobeRoute({
    required this.waypoints,
    this.color = const Color(0xFF38BDF8),
    this.altitude = 0.28,
    this.strokeWidth = 2.0,
    this.duration = const Duration(milliseconds: 6000),
    this.delay = Duration.zero,
    this.repeat = true,
    this.showVehicle = true,
    this.vehicleType = GlobeVehicleType.airplane,
    this.vehicleColor,
    this.vehicleSize = 16.0,
  })  : assert(altitude >= 0 && altitude < double.infinity),
        assert(strokeWidth >= 0 && strokeWidth < double.infinity),
        assert(vehicleSize >= 0 && vehicleSize < double.infinity);

  /// Sequential geographic waypoints along the route.
  final List<GlobeCoordinate> waypoints;

  /// Route line color.
  final Color color;

  /// Peak altitude of the route above the globe surface.
  final double altitude;

  /// Stroke width of the route trajectory line.
  final double strokeWidth;

  /// Duration of one traverse; nonpositive values disable route motion.
  final Duration duration;

  /// Delay before movement animation begins.
  final Duration delay;

  /// Whether the moving animation loops.
  final bool repeat;

  /// Whether to automatically render a moving vehicle along this route.
  final bool showVehicle;

  /// The type of vehicle (airplane, satellite, packet, ship) traversing this route.
  final GlobeVehicleType vehicleType;

  /// Custom color for the moving vehicle. Defaults to [Colors.white].
  final Color? vehicleColor;

  /// Size of the moving vehicle in logical pixels.
  final double vehicleSize;
}

/// Represents an animated moving vehicle traveling along a [GlobeRoute].
@immutable
class GlobeMovingObject {
  /// Creates a vehicle bound to a route.
  const GlobeMovingObject({
    required this.route,
    this.type = GlobeVehicleType.airplane,
    this.color = Colors.white,
    this.size = 16.0,
    this.showTrail = true,
    this.trailLength = 0.15,
  })  : assert(size >= 0 && size < double.infinity),
        assert(trailLength >= 0.05 && trailLength <= 0.4);

  /// The route path this object travels along.
  final GlobeRoute route;

  /// The vehicle icon or mesh type.
  final GlobeVehicleType type;

  /// Color of the moving vehicle.
  final Color color;

  /// Screen size in logical pixels.
  final double size;

  /// Whether to render a glowing tail trail behind the vehicle.
  final bool showTrail;

  /// Length of the tail trail (fraction 0.05 to 0.4).
  final double trailLength;
}

/// Renders animated multi-waypoint flight corridors, logistics routes, and moving aircraft.
class GlobeRouteLayer extends GlobeLayer {
  /// Creates a route overlay with optional independently styled vehicles.
  const GlobeRouteLayer({
    super.enabled = true,
    super.zIndex = 25,
    this.routes = const <GlobeRoute>[],
    this.movingObjects = const <GlobeMovingObject>[],
  });

  /// Route trajectories and their attached vehicles.
  final List<GlobeRoute> routes;

  /// Additional vehicles with independent styling.
  final List<GlobeMovingObject> movingObjects;

  @override
  void paint(GlobeRenderContext context) {
    if (routes.isEmpty && movingObjects.isEmpty) return;

    final canvas = context.canvas;
    final camera = context.camera;
    final rotation = context.rotation;
    final timeMs = context.animationTimeMs;

    // 1. Draw static and animated route trajectory lines
    for (final route in routes) {
      if (route.waypoints.length < 2) continue;
      _drawRouteTrajectory(canvas, camera, rotation, route, context.quality);
    }

    // 2. Draw vehicles attached directly to routes
    for (final route in routes) {
      if (!route.showVehicle || route.waypoints.length < 2) continue;
      final obj = GlobeMovingObject(
        route: route,
        type: route.vehicleType,
        color: route.vehicleColor ?? Colors.white,
        size: route.vehicleSize,
      );
      _drawMovingObject(canvas, camera, rotation, obj, timeMs);
    }

    // 3. Draw standalone moving objects
    for (final obj in movingObjects) {
      if (obj.route.waypoints.length < 2) continue;
      _drawMovingObject(canvas, camera, rotation, obj, timeMs);
    }
  }

  void _drawRouteTrajectory(
    Canvas canvas,
    GlobeCamera camera,
    Quaternion3D rotation,
    GlobeRoute route,
    GlobeQuality quality,
  ) {
    final path = Path();
    final linePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
    linePaint
      ..strokeWidth = route.strokeWidth
      ..color = route.color.withValues(alpha: 0.35);

    final segments = <List<Vector3D>>[];
    {
      for (var i = 0; i < route.waypoints.length - 1; i++) {
        final startVec = route.waypoints[i].toVector3D();
        final endVec = route.waypoints[i + 1].toVector3D();
        segments.add(GreatCircle.generateArcPoints(
          start: startVec,
          end: endVec,
          sampleCount: switch (quality) {
            GlobeQuality.low => 18,
            GlobeQuality.medium => 28,
            GlobeQuality.high => 36,
            GlobeQuality.ultra => 54,
            GlobeQuality.auto => 28,
          },
          maxAltitude: route.altitude,
        ));
      }
    }

    for (final points in segments) {
      path.reset();
      var hasStarted = false;

      for (final pt in points) {
        final rotated = rotation.rotateVector(pt);
        if (rotated.z < -0.1) {
          hasStarted = false;
          continue;
        }

        final (px, py, _, _) = camera.projectRaw(rotated);
        if (!hasStarted) {
          path.moveTo(px, py);
          hasStarted = true;
        } else {
          path.lineTo(px, py);
        }
      }

      if (hasStarted) {
        canvas.drawPath(path, linePaint);
      }
    }
  }

  void _drawMovingObject(
    Canvas canvas,
    GlobeCamera camera,
    Quaternion3D rotation,
    GlobeMovingObject obj,
    double timeMs,
  ) {
    final route = obj.route;
    final durationMs = route.duration.inMilliseconds.toDouble();
    final delayMs = route.delay.inMilliseconds.toDouble();

    if (timeMs < delayMs || durationMs <= 0.0) return;

    final elapsed = timeMs - delayMs;
    final progress =
        (route.repeat ? elapsed % durationMs : elapsed.clamp(0.0, durationMs)) /
            durationMs;
    final legs = route.waypoints.length - 1;
    final globalProgress = progress * legs;
    final currentLeg = math.min(legs - 1, globalProgress.floor());
    final legT = globalProgress - currentLeg;

    final startVec = route.waypoints[currentLeg].toVector3D();
    final endVec = route.waypoints[currentLeg + 1].toVector3D();

    final currentPos3D = GreatCircle.evaluateArcPoint(
      start: startVec,
      end: endVec,
      t: legT,
      maxAltitude: route.altitude,
    );

    final nextPos3D = GreatCircle.evaluateArcPoint(
      start: startVec,
      end: endVec,
      t: math.min(1.0, legT + 0.015),
      maxAltitude: route.altitude,
    );

    final rotated = rotation.rotateVector(currentPos3D);
    final rotatedNext = rotation.rotateVector(nextPos3D);

    if (rotated.z < -0.05) return;

    final limbAlpha = ((rotated.z + 0.05) / 0.15).clamp(0.0, 1.0);
    final (px, py, scale, _) = camera.projectRaw(rotated);
    final (nx, ny, _, _) = camera.projectRaw(rotatedNext);

    // Compute 2D heading angle from projected trajectory
    final deltaX = nx - px;
    final deltaY = ny - py;
    final headingAngle = math.atan2(deltaY, deltaX);

    final size = obj.size * scale;

    canvas.save();
    canvas.translate(px, py);
    canvas.rotate(headingAngle);

    _drawVehicleIcon(canvas, obj, size, limbAlpha);
    canvas.restore();
  }

  void _drawVehicleIcon(
    Canvas canvas,
    GlobeMovingObject obj,
    double size,
    double alpha,
  ) {
    final vehiclePath = Path();
    final fillPaint = Paint()..isAntiAlias = true;
    final glowPaint = Paint()..isAntiAlias = true;
    final trailPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
    final portPaint = Paint()..isAntiAlias = true;
    final stbdPaint = Paint()..isAntiAlias = true;
    fillPaint.color = obj.color.withValues(alpha: alpha);
    glowPaint.color = obj.color.withValues(alpha: 0.35 * alpha);

    // Soft aura glow
    canvas.drawCircle(Offset.zero, size * 0.8, glowPaint);

    switch (obj.type) {
      case GlobeVehicleType.airplane:
        // 1. Draw jet engine contrails (twin exhaust vapor trails)
        if (obj.showTrail) {
          final trailScale = obj.trailLength / 0.15;
          trailPaint
            ..strokeWidth = math.max(1.0, size * 0.08)
            ..color = obj.color.withValues(alpha: 0.55 * alpha);

          canvas.drawLine(
            Offset(-size * 0.2, -size * 0.28),
            Offset(-size * 1.5 * trailScale, -size * 0.28),
            trailPaint,
          );
          canvas.drawLine(
            Offset(-size * 0.2, size * 0.28),
            Offset(-size * 1.5 * trailScale, size * 0.28),
            trailPaint,
          );
        }

        // 2. High-fidelity jet airliner silhouette (fuselage, swept wings, tail)
        vehiclePath
          ..reset()
          ..moveTo(size * 0.75, 0)
          ..lineTo(size * 0.2, size * 0.12)
          ..lineTo(-size * 0.05, size * 0.82)
          ..lineTo(-size * 0.18, size * 0.82)
          ..lineTo(-size * 0.15, size * 0.14)
          ..lineTo(-size * 0.55, size * 0.12)
          ..lineTo(-size * 0.78, size * 0.38)
          ..lineTo(-size * 0.86, size * 0.38)
          ..lineTo(-size * 0.80, 0)
          ..lineTo(-size * 0.86, -size * 0.38)
          ..lineTo(-size * 0.78, -size * 0.38)
          ..lineTo(-size * 0.55, -size * 0.12)
          ..lineTo(-size * 0.15, -size * 0.14)
          ..lineTo(-size * 0.18, -size * 0.82)
          ..lineTo(-size * 0.05, -size * 0.82)
          ..lineTo(size * 0.2, -size * 0.12)
          ..close();

        canvas.drawPath(vehiclePath, fillPaint);

        // Wingtip navigation lights (red on left port, green on right starboard)
        portPaint.color = const Color(0xFFEF4444).withValues(alpha: alpha);
        stbdPaint.color = const Color(0xFF10B981).withValues(alpha: alpha);

        canvas.drawCircle(
            Offset(-size * 0.12, -size * 0.82), size * 0.09, portPaint);
        canvas.drawCircle(
            Offset(-size * 0.12, size * 0.82), size * 0.09, stbdPaint);
        break;

      case GlobeVehicleType.satellite:
        // Central bus / body
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: size * 0.45, height: size * 0.45),
          fillPaint,
        );
        // Solar panel array
        trailPaint
          ..strokeWidth = math.max(1.2, size * 0.12)
          ..color = obj.color.withValues(alpha: alpha);
        canvas.drawLine(
            Offset(0, -size * 0.75), Offset(0, size * 0.75), trailPaint);
        // Dish antenna
        canvas.drawCircle(Offset(size * 0.3, 0), size * 0.15, fillPaint);
        break;

      case GlobeVehicleType.packet:
        canvas.drawCircle(Offset.zero, size * 0.45, fillPaint);
        break;

      case GlobeVehicleType.ship:
        vehiclePath
          ..reset()
          ..moveTo(size * 0.55, 0)
          ..lineTo(-size * 0.35, size * 0.25)
          ..lineTo(-size * 0.5, 0)
          ..lineTo(-size * 0.35, -size * 0.25)
          ..close();
        canvas.drawPath(vehiclePath, fillPaint);
        break;
    }
  }
}
