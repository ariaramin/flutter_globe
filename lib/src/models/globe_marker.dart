import 'package:flutter/material.dart';
import 'globe_coordinate.dart';

/// Represents a point of interest or beacon on the 3D globe surface with optional pulse animations.
@immutable
class GlobeMarker {
  /// Creates a marker on the globe at [coordinate].
  const GlobeMarker({
    required this.coordinate,
    this.color = const Color(0xFF38BDF8),
    this.size = 5.0,
    this.pulse = true,
    this.pulseRadius = 18.0,
    this.pulseDuration = const Duration(milliseconds: 2200),
    this.pulseColor,
    this.label,
    this.data,
    this.onTap,
  })  : assert(size >= 0 && size < double.infinity),
        assert(pulseRadius >= 0 && pulseRadius < double.infinity);

  /// Convenience constructor creating a marker from [latitude] and [longitude] in degrees.
  GlobeMarker.latLng({
    required double latitude,
    required double longitude,
    Color color = const Color(0xFF38BDF8),
    double size = 5.0,
    bool pulse = true,
    double pulseRadius = 18.0,
    Duration pulseDuration = const Duration(milliseconds: 2200),
    Color? pulseColor,
    String? label,
    Object? data,
    VoidCallback? onTap,
  }) : this(
          coordinate: GlobeCoordinate(
            latitude: latitude,
            longitude: longitude,
          ),
          color: color,
          size: size,
          pulse: pulse,
          pulseRadius: pulseRadius,
          pulseDuration: pulseDuration,
          pulseColor: pulseColor,
          label: label,
          data: data,
          onTap: onTap,
        );

  /// Geographic coordinate of the marker.
  final GlobeCoordinate coordinate;

  /// Latitude in degrees.
  double get latitude => coordinate.latitude;

  /// Longitude in degrees.
  double get longitude => coordinate.longitude;

  /// Core color of the marker beacon.
  final Color color;

  /// Radius of the central marker dot in logical pixels.
  final double size;

  /// Whether to render expanding pulse wave rings around the marker.
  final bool pulse;

  /// Maximum radius reached by the pulse rings before fading out.
  final double pulseRadius;

  /// Duration of one complete pulse cycle; nonpositive values disable it.
  final Duration pulseDuration;

  /// Optional color for the pulse rings. Defaults to [color] with alpha fade.
  final Color? pulseColor;

  /// Optional text label shown near the marker or in tooltips.
  final String? label;

  /// Optional arbitrary payload object attached to this marker.
  final Object? data;

  /// Callback executed when this marker is tapped.
  final VoidCallback? onTap;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobeMarker &&
          coordinate == other.coordinate &&
          color == other.color &&
          size == other.size &&
          pulse == other.pulse &&
          pulseRadius == other.pulseRadius &&
          pulseDuration == other.pulseDuration &&
          pulseColor == other.pulseColor &&
          label == other.label &&
          data == other.data &&
          onTap == other.onTap;

  @override
  int get hashCode => Object.hashAll(<Object?>[
        coordinate,
        color,
        size,
        pulse,
        pulseRadius,
        pulseDuration,
        pulseColor,
        label,
        data,
        onTap
      ]);
}
