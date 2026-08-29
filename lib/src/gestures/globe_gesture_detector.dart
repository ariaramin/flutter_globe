import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../globe_controller.dart';
import '../math/matrix3d.dart';
import '../math/globe_projection.dart';
import '../models/globe_coordinate.dart';
import '../models/globe_marker.dart';

/// Callback type for taps on the 3D globe surface.
typedef GlobeTapCallback = void Function(GlobeCoordinate coordinate);

/// Callback type for taps on a location marker.
typedef MarkerTapCallback = void Function(GlobeMarker marker);

/// Gesture handler wrapping the globe with pan, momentum inertia, pinch-zoom, and hit-testing.
class GlobeGestureHandler extends StatefulWidget {
  const GlobeGestureHandler({
    super.key,
    required this.controller,
    required this.child,
    required this.markers,
    this.interactive = true,
    this.dragEnabled = true,
    this.enableZoom = false,
    this.inertiaEnabled = true,
    this.inertiaFriction = 0.93,
    this.rotationSensitivity = 0.005,
    this.invertVerticalPan = false,
    this.cameraAltitude = 2.6,
    this.projection = GlobeProjection.perspective,
    this.radiusMultiplier = 0.82,
    this.onGlobeTap,
    this.onMarkerTap,
    this.onInteractionStart,
    this.onInteractionEnd,
  });

  final GlobeController controller;
  final Widget child;
  final List<GlobeMarker> markers;
  final bool interactive;
  final bool dragEnabled;
  final bool enableZoom;
  final bool inertiaEnabled;
  final double inertiaFriction;
  final double rotationSensitivity;

  /// Whether vertical pan direction is inverted.
  /// By default (false): swiping bottom moves globe top, swiping top moves globe bottom.
  final bool invertVerticalPan;

  final double cameraAltitude;
  final GlobeProjection projection;
  final double radiusMultiplier;
  final GlobeTapCallback? onGlobeTap;
  final MarkerTapCallback? onMarkerTap;
  final VoidCallback? onInteractionStart;
  final VoidCallback? onInteractionEnd;

  @override
  State<GlobeGestureHandler> createState() => _GlobeGestureHandlerState();
}

class _GlobeGestureHandlerState extends State<GlobeGestureHandler>
    with SingleTickerProviderStateMixin {
  Offset? _lastFocalPoint;
  double _baseScale = 1.0;

  AnimationController? _momentumController;
  Offset _velocity = Offset.zero;

  @override
  void initState() {
    super.initState();
    _momentumController = AnimationController.unbounded(vsync: this)
      ..addListener(_onMomentumTick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.controller.setInteracting(false);
        }
      });
  }

  @override
  void dispose() {
    _momentumController?.dispose();
    super.dispose();
  }

  void _onMomentumTick() {
    if (_velocity.distanceSquared < 0.0001) {
      _momentumController?.stop();
      widget.controller.setInteracting(false);
      return;
    }

    final pitchMultiplier = widget.invertVerticalPan ? 1.0 : -1.0;
    final deltaYaw = _velocity.dx * widget.rotationSensitivity * 0.016;
    final deltaPitch =
        _velocity.dy * widget.rotationSensitivity * 0.016 * pitchMultiplier;
    widget.controller.rotateBy(deltaYaw, deltaPitch);

    // Friction damping (decay velocity by 7% per frame)
    _velocity = _velocity * widget.inertiaFriction;
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (!widget.interactive || (!widget.dragEnabled && !widget.enableZoom)) {
      return;
    }

    _momentumController?.stop();
    _velocity = Offset.zero;
    _lastFocalPoint = details.localFocalPoint;
    _baseScale = widget.controller.zoom;
    widget.controller.setInteracting(true);
    widget.onInteractionStart?.call();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!widget.interactive) return;

    if (widget.dragEnabled && _lastFocalPoint != null) {
      final delta = details.localFocalPoint - _lastFocalPoint!;
      final pitchMultiplier = widget.invertVerticalPan ? 1.0 : -1.0;
      final deltaYaw = delta.dx * widget.rotationSensitivity;
      final deltaPitch =
          delta.dy * widget.rotationSensitivity * pitchMultiplier;

      widget.controller.rotateBy(deltaYaw, deltaPitch);
    }
    _lastFocalPoint = details.localFocalPoint;

    if (widget.enableZoom && details.scale != 1.0) {
      widget.controller.zoom = _baseScale * details.scale;
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!widget.interactive) return;

    _lastFocalPoint = null;
    final velocity = details.velocity.pixelsPerSecond;

    if (widget.inertiaEnabled &&
        widget.dragEnabled &&
        velocity.distanceSquared > 10000.0 &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
      // Launch momentum physics
      _velocity = Offset(velocity.dx * 0.08, velocity.dy * 0.08);
      _momentumController?.reset();
      _momentumController?.animateTo(1.0,
          duration: const Duration(milliseconds: 900));
    } else {
      widget.controller.setInteracting(false);
    }

    widget.onInteractionEnd?.call();
  }

  void _onTapUp(TapUpDetails details, BoxConstraints constraints) {
    if (!widget.interactive ||
        !constraints.hasBoundedWidth ||
        !constraints.hasBoundedHeight ||
        constraints.biggest.isEmpty) {
      return;
    }
    final size = Size(constraints.maxWidth, constraints.maxHeight);
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final minDimension = math.min(size.width, size.height);
    final radius =
        (minDimension * 0.5) * widget.radiusMultiplier * widget.controller.zoom;

    final camera = GlobeCamera(
      altitude: widget.cameraAltitude,
      center: center,
      radius: radius,
      projection: widget.projection,
    );

    final localPos = details.localPosition;

    // 1. Check if any marker was tapped (hit-test in screen space)
    for (final marker in widget.markers) {
      final unitVec = marker.coordinate.toVector3D();
      final rotated = widget.controller.rotation.rotateVector(unitVec);
      if (rotated.z >= -0.05) {
        final projected = camera.project(rotated);
        final hitRadius = math.max(22.0, marker.size * projected.scale * 3.0);

        if ((projected.offset - localPos).distanceSquared <=
            hitRadius * hitRadius) {
          marker.onTap?.call();
          widget.onMarkerTap?.call(marker);
          return;
        }
      }
    }

    // 2. Check if the globe surface itself was tapped
    final unprojected = camera.unproject(localPos, widget.controller.rotation);
    if (unprojected != null) {
      final coord = GlobeCoordinate.fromVector3D(unprojected);
      widget.onGlobeTap?.call(coord);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          onTapUp: (details) => _onTapUp(details, constraints),
          child: widget.child,
        );
      },
    );
  }
}
