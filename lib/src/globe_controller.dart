import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'controllers/globe_tour.dart';
import 'math/quaternion.dart';
import 'math/vector3.dart';
import 'models/globe_coordinate.dart';
import 'models/globe_marker.dart';

/// Controller for programmatic camera manipulation, orientation transitions,
/// zoom levels, and auto-rotation management.
class GlobeController extends ChangeNotifier {
  /// Creates a globe controller with optional initial rotation, zoom, and auto-rotation settings.
  GlobeController({
    Quaternion3D? initialRotation,
    bool autoRotate = true,
    double autoRotateSpeed = 0.85,
    double zoom = 1.0,
  })  : assert(autoRotateSpeed > -double.infinity &&
            autoRotateSpeed < double.infinity),
        assert(zoom >= 0.5 && zoom <= 3.5),
        _rotation = initialRotation ?? Quaternion3D.fromEuler(0.2, -0.6, 0.0),
        _autoRotate = autoRotate,
        _autoRotateSpeed = autoRotateSpeed,
        _zoom = zoom;

  Quaternion3D _rotation;
  bool _autoRotate;
  double _autoRotateSpeed;
  double _zoom;
  bool _isInteracting = false;
  GlobeMarker? _selectedMarker;

  AnimationController? _animationController;
  CurvedAnimation? _curvedAnimation;
  Quaternion3D? _animStartRotation;
  Quaternion3D? _animTargetRotation;
  double? _animStartZoom;
  double? _animTargetZoom;

  GlobeTour? _activeTour;
  int _tourCurrentStep = 0;
  Timer? _tourTimer;

  /// Current 3D rotation quaternion of the globe.
  Quaternion3D get rotation => _rotation;

  set rotation(Quaternion3D value) {
    if (_rotation == value) return;
    _rotation = value.normalized;
    notifyListeners();
  }

  /// Whether the globe is currently auto-rotating when idle.
  bool get autoRotate => _autoRotate;

  set autoRotate(bool value) {
    if (_autoRotate == value) return;
    _autoRotate = value;
    notifyListeners();
  }

  /// Starts automatic idle rotation.
  void startAutoRotation() => autoRotate = true;

  /// Stops automatic idle rotation.
  void stopAutoRotation() => autoRotate = false;

  /// Speed of auto-rotation in radians per second.
  double get autoRotateSpeed => _autoRotateSpeed;

  set autoRotateSpeed(double value) {
    if (!value.isFinite) throw ArgumentError.value(value, 'autoRotateSpeed');
    if (_autoRotateSpeed == value) return;
    _autoRotateSpeed = value;
    notifyListeners();
  }

  /// Current zoom multiplier (1.0 = standard view, 0.5 to 3.5).
  double get zoom => _zoom;

  set zoom(double value) {
    if (!value.isFinite) throw ArgumentError.value(value, 'zoom');
    final clamped = value.clamp(0.5, 3.5);
    if (_zoom == clamped) return;
    _zoom = clamped;
    notifyListeners();
  }

  /// Currently selected marker on the globe.
  GlobeMarker? get selectedMarker => _selectedMarker;

  /// Active tour stop index if a tour is running.
  int get tourCurrentStep => _tourCurrentStep;

  /// Whether a tour is currently running.
  bool get isTourPlaying => _activeTour != null;

  /// Whether a user touch or pointer drag is actively interacting with the globe.
  bool get isInteracting => _isInteracting;

  @internal
  void setInteracting(bool interacting) {
    if (_isInteracting == interacting) return;
    _isInteracting = interacting;
    notifyListeners();
  }

  /// Selects a marker and notifies listeners.
  void selectMarker(GlobeMarker? marker) {
    if (_selectedMarker == marker) return;
    _selectedMarker = marker;
    notifyListeners();
  }

  /// Clears the current marker selection.
  void clearSelection() => selectMarker(null);

  /// Rotates the globe by yaw (horizontal) and pitch (vertical) deltas in radians.
  void rotateBy(double deltaYaw, double deltaPitch) {
    final pitchQuat = Quaternion3D.fromAxisAngle(Vector3D.unitX, deltaPitch);
    final yawQuat = Quaternion3D.fromAxisAngle(Vector3D.unitY, deltaYaw);
    final deltaRotation = yawQuat * pitchQuat;

    _rotation = (deltaRotation * _rotation).normalized;
    notifyListeners();
  }

  /// Instantly looks at the given geographic [coordinate] without animation.
  void lookAt(GlobeCoordinate coordinate) {
    final targetVec = coordinate.toVector3D();
    _rotation = Quaternion3D.fromRotationBetween(targetVec, Vector3D.unitZ);
    notifyListeners();
  }

  /// Programmatically animates the camera to center on [coordinate] with optional target [zoom].
  void flyTo({
    required GlobeCoordinate coordinate,
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1200),
    Curve curve = Curves.easeInOutCubic,
    double? zoom,
  }) {
    final targetVec = coordinate.toVector3D();
    final targetQuat =
        Quaternion3D.fromRotationBetween(targetVec, Vector3D.unitZ);

    _startAnimation(
      target: targetQuat,
      targetZoom: zoom,
      vsync: vsync,
      duration: duration,
      curve: curve,
    );
  }

  /// Programmatically animates the globe to center on the given [coordinate].
  void animateTo({
    required GlobeCoordinate coordinate,
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.easeInOutCubic,
    double? zoom,
  }) =>
      flyTo(
        coordinate: coordinate,
        vsync: vsync,
        duration: duration,
        curve: curve,
        zoom: zoom,
      );

  /// Focuses and zooms onto the given [marker].
  void focusMarker({
    required GlobeMarker marker,
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1200),
    Curve curve = Curves.easeInOutCubic,
    double zoom = 1.35,
  }) {
    selectMarker(marker);
    flyTo(
      coordinate: marker.coordinate,
      vsync: vsync,
      duration: duration,
      curve: curve,
      zoom: zoom,
    );
  }

  /// Zooms smoothly to the target [zoom] multiplier.
  void zoomTo({
    required double targetZoom,
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOutCubic,
  }) {
    _startAnimation(
      target: _rotation,
      targetZoom: targetZoom,
      vsync: vsync,
      duration: duration,
      curve: curve,
    );
  }

  /// Resets the globe rotation and zoom to default orientation.
  void resetView({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOutCubic,
  }) {
    _startAnimation(
      target: Quaternion3D.fromEuler(0.2, -0.6, 0.0),
      targetZoom: 1.0,
      vsync: vsync,
      duration: duration,
      curve: curve,
    );
  }

  /// Alias for [resetView].
  void reset({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOutCubic,
  }) =>
      resetView(vsync: vsync, duration: duration, curve: curve);

  /// Launches an automated cinematic [GlobeTour].
  void playTour({
    required GlobeTour tour,
    required TickerProvider vsync,
  }) {
    stopTour();
    if (tour.stops.isEmpty) return;
    _activeTour = tour;
    _tourCurrentStep = 0;
    _runTourStep(vsync);
  }

  void _runTourStep(TickerProvider vsync) {
    if (_activeTour == null) return;
    final activeTour = _activeTour!;
    final stop = activeTour.stops[_tourCurrentStep];
    activeTour.onStepChanged?.call(_tourCurrentStep);
    if (_activeTour != activeTour) return;

    flyTo(
      coordinate: stop.coordinate,
      vsync: vsync,
      duration: stop.transitionDuration,
      curve: stop.curve,
      zoom: stop.zoom,
    );

    _tourTimer = Timer(stop.transitionDuration, () {
      if (_activeTour != activeTour) return;
      stop.onArrival?.call();
      if (_activeTour != activeTour) return;
      _tourTimer = Timer(stop.dwellDuration, () {
        if (_activeTour != activeTour) return;
        if (_tourCurrentStep < activeTour.stops.length - 1) {
          _tourCurrentStep++;
          _runTourStep(vsync);
        } else if (activeTour.loop) {
          _tourCurrentStep = 0;
          _runTourStep(vsync);
        } else {
          stopTour();
          activeTour.onCompleted?.call();
        }
      });
    });
  }

  /// Stops any currently playing camera tour.
  void stopTour() {
    _tourTimer?.cancel();
    _tourTimer = null;
    _activeTour = null;
    _animationController?.stop();
    notifyListeners();
  }

  void _startAnimation({
    required Quaternion3D target,
    double? targetZoom,
    required TickerProvider vsync,
    required Duration duration,
    required Curve curve,
  }) {
    if (duration.isNegative) throw ArgumentError.value(duration, 'duration');
    if (targetZoom != null && !targetZoom.isFinite) {
      throw ArgumentError.value(targetZoom, 'targetZoom');
    }
    _curvedAnimation?.dispose();
    _animationController?.dispose();
    _animationController = AnimationController(
      vsync: vsync,
      duration: duration,
    );

    _curvedAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: curve,
    );

    _animStartRotation = _rotation;
    _animTargetRotation = target;
    _animStartZoom = _zoom;
    _animTargetZoom = targetZoom?.clamp(0.5, 3.5);

    _animationController!.addListener(() {
      final t = _curvedAnimation!.value;
      if (_animStartRotation != null && _animTargetRotation != null) {
        _rotation = _animStartRotation!.slerp(_animTargetRotation!, t);
      }
      if (_animStartZoom != null && _animTargetZoom != null) {
        _zoom = _animStartZoom! + (_animTargetZoom! - _animStartZoom!) * t;
      }
      notifyListeners();
    });

    _animationController!.forward();
  }

  /// Advances auto-rotation by [dtSeconds] seconds.
  @internal
  void tickAutoRotation(
    double dtSeconds, {
    double blend = 1.0,
    bool pauseWhileInteracting = true,
  }) {
    if (!_autoRotate ||
        (pauseWhileInteracting && _isInteracting) ||
        isTourPlaying ||
        (_animationController?.isAnimating ?? false) ||
        blend <= 0.0) {
      return;
    }

    final deltaYaw = _autoRotateSpeed * dtSeconds * blend;
    final yawQuat = Quaternion3D.fromAxisAngle(Vector3D.unitY, deltaYaw);
    _rotation = (yawQuat * _rotation).normalized;
    notifyListeners();
  }

  @override
  void dispose() {
    _tourTimer?.cancel();
    _activeTour = null;
    _curvedAnimation?.dispose();
    _animationController?.dispose();
    super.dispose();
  }
}
