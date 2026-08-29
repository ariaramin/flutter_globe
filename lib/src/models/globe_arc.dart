import 'package:flutter/material.dart';
import 'globe_coordinate.dart';

/// Represents an elevated, animated great-circle connection arc between two geographic coordinates.
@immutable
class GlobeArc {
  /// Creates a great-circle connection arc between [start] and [end] coordinates.
  const GlobeArc({
    required this.start,
    required this.end,
    this.color = const Color(0xFF60A5FA),
    this.startColor,
    this.endColor,
    this.altitude = 0.25,
    this.strokeWidth = 2.0,
    this.dashLength = 0.35,
    this.glowRadius = 3.0,
    this.duration = const Duration(milliseconds: 2400),
    this.delay = Duration.zero,
    this.repeat = true,
    this.showBaseLine = true,
    this.baseLineOpacity = 0.25,
    this.data,
  })  : assert(altitude >= 0 && altitude < double.infinity),
        assert(strokeWidth >= 0 && strokeWidth < double.infinity),
        assert(dashLength >= 0 && dashLength <= 1),
        assert(glowRadius >= 0 && glowRadius < double.infinity),
        assert(baseLineOpacity >= 0 && baseLineOpacity <= 1);

  /// Starting geographic coordinate of the arc.
  final GlobeCoordinate start;

  /// Ending geographic coordinate of the arc.
  final GlobeCoordinate end;

  /// Primary color for the arc and traveling highlight.
  final Color color;

  /// Optional start color for a multi-color gradient along the arc.
  final Color? startColor;

  /// Optional end color for a multi-color gradient along the arc.
  final Color? endColor;

  /// Peak altitude of the arc above the globe surface (0.1 to 0.6).
  final double altitude;

  /// Stroke width of the arc in logical pixels.
  final double strokeWidth;

  /// Length of the traveling animated highlight (fraction from 0.05 to 0.8).
  final double dashLength;

  /// Outer glow blur radius for the traveling pulse highlight.
  final double glowRadius;

  /// Duration of one complete travel animation; nonpositive values disable it.
  final Duration duration;

  /// Initial delay before the arc animation starts.
  final Duration delay;

  /// Whether the travel animation loops continuously.
  final bool repeat;

  /// Whether to render a faint static trajectory line along the full arc path.
  final bool showBaseLine;

  /// Opacity of the faint static base trajectory line (0.0 to 1.0).
  final double baseLineOpacity;

  /// Optional custom payload object.
  final Object? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobeArc &&
          start == other.start &&
          end == other.end &&
          color == other.color &&
          startColor == other.startColor &&
          endColor == other.endColor &&
          altitude == other.altitude &&
          strokeWidth == other.strokeWidth &&
          dashLength == other.dashLength &&
          glowRadius == other.glowRadius &&
          duration == other.duration &&
          delay == other.delay &&
          repeat == other.repeat &&
          showBaseLine == other.showBaseLine &&
          baseLineOpacity == other.baseLineOpacity &&
          data == other.data;

  @override
  int get hashCode => Object.hashAll(<Object?>[
        start,
        end,
        color,
        startColor,
        endColor,
        altitude,
        strokeWidth,
        dashLength,
        glowRadius,
        duration,
        delay,
        repeat,
        showBaseLine,
        baseLineOpacity,
        data
      ]);
}
