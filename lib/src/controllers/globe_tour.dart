import 'package:flutter/material.dart';
import '../models/globe_coordinate.dart';

/// Represents a single waypoint destination in an animated [GlobeTour].
@immutable
class GlobeTourStop {
  /// Creates a camera destination with a transition followed by a dwell.
  const GlobeTourStop({
    required this.coordinate,
    this.label,
    this.description,
    this.dwellDuration = const Duration(seconds: 3),
    this.transitionDuration = const Duration(milliseconds: 1400),
    this.zoom = 1.25,
    this.curve = Curves.easeInOutCubic,
    this.onArrival,
  });

  /// Geographic target coordinate of this tour stop.
  final GlobeCoordinate coordinate;

  /// Display title or city name of the stop.
  final String? label;

  /// Narrative story text or description.
  final String? description;

  /// Duration the camera lingers at this stop before advancing.
  final Duration dwellDuration;

  /// Camera flight transition duration to reach this stop.
  final Duration transitionDuration;

  /// Camera zoom level at this stop.
  final double zoom;

  /// Animation easing curve.
  final Curve curve;

  /// Callback executed when the camera arrives at this stop.
  final VoidCallback? onArrival;
}

/// Scripted cinematic camera tour across sequential geographic destinations.
@immutable
class GlobeTour {
  /// Creates a scripted camera sequence; empty sequences are ignored.
  const GlobeTour({
    required this.stops,
    this.loop = true,
    this.autoPlay = true,
    this.onStepChanged,
    this.onCompleted,
  });

  /// Sequence of stops. Empty tours are ignored; a single stop is supported.
  final List<GlobeTourStop> stops;

  /// Whether the tour restarts from stop 0 upon completion.
  final bool loop;

  /// Whether the tour starts playing immediately upon launch.
  final bool autoPlay;

  /// Callback fired when the active stop index changes.
  final ValueChanged<int>? onStepChanged;

  /// Callback fired when the tour completes.
  final VoidCallback? onCompleted;
}
