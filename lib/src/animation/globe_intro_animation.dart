import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import '../math/quaternion.dart';

/// Configuration for the globe entrance/reveal animation timeline.
///
/// Features staged sequencing for sphere scale-up, opacity ramp, atmospheric bloom,
/// marker pop-in, and geodesic arc growth for a staged, reference-inspired reveal.
@immutable
class GlobeIntroAnimation {
  /// Creates an entrance animation configuration.
  const GlobeIntroAnimation({
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1400),
    this.curve = Curves.easeOutCubic,
    this.scaleFrom = 0.72,
    this.opacityFrom = 0.0,
    this.fadeIn = true,
    this.revealMarkers = true,
    this.revealArcs = true,
    this.atmosphereDelay = const Duration(milliseconds: 200),
    this.markerDelay = const Duration(milliseconds: 400),
    this.arcDelay = const Duration(milliseconds: 600),
    this.autoRotateDelay = const Duration(milliseconds: 900),
    this.overshoot = 1.02,
    this.initialRotation,
    this.autoRotateOnComplete = true,
  })  : assert(scaleFrom > 0 && scaleFrom < double.infinity),
        assert(opacityFrom >= 0 && opacityFrom <= 1),
        assert(overshoot >= 1 && overshoot < double.infinity);

  /// Whether the entrance animation is active.
  final bool enabled;

  /// Total duration of the entrance animation sequence.
  final Duration duration;

  /// Primary easing curve for the sphere reveal and scaling.
  final Curve curve;

  /// Starting scale factor before expanding to full size (e.g. 0.72).
  final double scaleFrom;

  /// Starting opacity before fading in (e.g. 0.0).
  final double opacityFrom;

  /// Whether the sphere and atmosphere fade in during intro.
  final bool fadeIn;

  /// Whether location markers are revealed progressively with staggered delay.
  final bool revealMarkers;

  /// Whether connection arcs grow progressively across great circles.
  final bool revealArcs;

  /// Delay before atmospheric radial glow begins blooming.
  final Duration atmosphereDelay;

  /// Delay before surface markers pop into view.
  final Duration markerDelay;

  /// Delay before elevated great-circle arcs begin streaming.
  final Duration arcDelay;

  /// Delay before idle auto-rotation seamlessly engages.
  final Duration autoRotateDelay;

  /// Scale overshoot factor before settling to 1.0 (e.g. 1.02).
  final double overshoot;

  /// Optional initial 3D orientation quaternion during entrance.
  final Quaternion3D? initialRotation;

  /// Whether auto-rotation should automatically start upon intro completion.
  final bool autoRotateOnComplete;

  /// Disabled intro animation (instant render with no transition).
  static const GlobeIntroAnimation none = GlobeIntroAnimation(
    enabled: false,
    duration: Duration.zero,
    scaleFrom: 1.0,
    opacityFrom: 1.0,
  );

  /// Computes the current scale multiplier at normalized progress [t] (0.0 to 1.0).
  double computeScale(double t) {
    if (!enabled || duration <= Duration.zero) return 1.0;
    final clampedT = t.clamp(0.0, 1.0);
    final curved = curve.transform(clampedT);

    // Apply subtle overshoot ramp between 0.6 and 1.0
    if (overshoot > 1.0 && clampedT < 1.0) {
      const peakT = 0.75;
      if (clampedT < peakT) {
        final localT = clampedT / peakT;
        return scaleFrom + (overshoot - scaleFrom) * curve.transform(localT);
      } else {
        final localT = (clampedT - peakT) / (1.0 - peakT);
        return overshoot +
            (1.0 - overshoot) * Curves.easeInOut.transform(localT);
      }
    }

    return scaleFrom + (1.0 - scaleFrom) * curved;
  }

  /// Computes the overall opacity at normalized progress [t] (0.0 to 1.0).
  double computeOpacity(double t) {
    if (!enabled || !fadeIn || duration <= Duration.zero) return 1.0;
    final clampedT = t.clamp(0.0, 1.0);
    // Faster opacity ramp: full opacity reached by ~60% of total duration
    final opacityProgress = (clampedT / 0.6).clamp(0.0, 1.0);
    return opacityFrom +
        (1.0 - opacityFrom) * Curves.easeOut.transform(opacityProgress);
  }

  /// Computes the atmosphere bloom factor at normalized progress [t] (0.0 to 1.0).
  double computeAtmosphereProgress(double t) {
    if (!enabled || duration <= Duration.zero) return 1.0;
    final totalMs = duration.inMicroseconds / 1000.0;
    final delayFraction = (atmosphereDelay.inMicroseconds / 1000.0 / totalMs)
        .clamp(0.0, 0.999999);
    if (t < delayFraction) return 0.0;
    final localT =
        ((t - delayFraction) / (1.0 - delayFraction)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(localT);
  }

  /// Computes the marker reveal scale and opacity factor at progress [t].
  double computeMarkerProgress(double t, [int index = 0]) {
    if (!enabled || !revealMarkers || duration <= Duration.zero) return 1.0;
    final totalMs = duration.inMicroseconds / 1000.0;
    final baseDelayMs = markerDelay.inMilliseconds.toDouble();
    final staggeredDelayMs = baseDelayMs + (index * 60.0);
    final delayFraction = (staggeredDelayMs / totalMs).clamp(0.0, 0.95);

    if (t < delayFraction) return 0.0;
    final localT =
        ((t - delayFraction) / (1.0 - delayFraction)).clamp(0.0, 1.0);
    // Spring pop-in for markers
    return Curves.easeOutBack.transform(localT);
  }

  /// Computes the arc reveal progress factor at progress [t].
  double computeArcProgress(double t, [int index = 0]) {
    if (!enabled || !revealArcs || duration <= Duration.zero) return 1.0;
    final totalMs = duration.inMicroseconds / 1000.0;
    final baseDelayMs = arcDelay.inMilliseconds.toDouble();
    final staggeredDelayMs = baseDelayMs + (index * 80.0);
    final delayFraction = (staggeredDelayMs / totalMs).clamp(0.0, 0.95);

    if (t < delayFraction) return 0.0;
    final localT =
        ((t - delayFraction) / (1.0 - delayFraction)).clamp(0.0, 1.0);
    return Curves.easeInOutCubic.transform(localT);
  }

  /// Computes the blend factor (0.0 to 1.0) for starting auto-rotation.
  double computeAutoRotateBlend(double t) {
    if (!autoRotateOnComplete) return 0.0;
    if (!enabled || duration <= Duration.zero) return 1.0;
    final totalMs = duration.inMicroseconds / 1000.0;
    final delayFraction = (autoRotateDelay.inMicroseconds / 1000.0 / totalMs)
        .clamp(0.0, 0.999999);
    if (t < delayFraction) return 0.0;
    final localT =
        ((t - delayFraction) / (1.0 - delayFraction)).clamp(0.0, 1.0);
    return Curves.easeInOut.transform(localT);
  }

  /// Creates a copy with modified properties.
  GlobeIntroAnimation copyWith({
    bool? enabled,
    Duration? duration,
    Curve? curve,
    double? scaleFrom,
    double? opacityFrom,
    bool? fadeIn,
    bool? revealMarkers,
    bool? revealArcs,
    Duration? atmosphereDelay,
    Duration? markerDelay,
    Duration? arcDelay,
    Duration? autoRotateDelay,
    double? overshoot,
    Quaternion3D? initialRotation,
    bool? autoRotateOnComplete,
  }) {
    return GlobeIntroAnimation(
      enabled: enabled ?? this.enabled,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      scaleFrom: scaleFrom ?? this.scaleFrom,
      opacityFrom: opacityFrom ?? this.opacityFrom,
      fadeIn: fadeIn ?? this.fadeIn,
      revealMarkers: revealMarkers ?? this.revealMarkers,
      revealArcs: revealArcs ?? this.revealArcs,
      atmosphereDelay: atmosphereDelay ?? this.atmosphereDelay,
      markerDelay: markerDelay ?? this.markerDelay,
      arcDelay: arcDelay ?? this.arcDelay,
      autoRotateDelay: autoRotateDelay ?? this.autoRotateDelay,
      overshoot: overshoot ?? this.overshoot,
      initialRotation: initialRotation ?? this.initialRotation,
      autoRotateOnComplete: autoRotateOnComplete ?? this.autoRotateOnComplete,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobeIntroAnimation &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          duration == other.duration &&
          scaleFrom == other.scaleFrom &&
          opacityFrom == other.opacityFrom &&
          fadeIn == other.fadeIn &&
          revealMarkers == other.revealMarkers &&
          revealArcs == other.revealArcs &&
          overshoot == other.overshoot &&
          curve == other.curve &&
          atmosphereDelay == other.atmosphereDelay &&
          markerDelay == other.markerDelay &&
          arcDelay == other.arcDelay &&
          autoRotateDelay == other.autoRotateDelay &&
          initialRotation == other.initialRotation &&
          autoRotateOnComplete == other.autoRotateOnComplete;

  @override
  int get hashCode => Object.hash(
        enabled,
        duration,
        scaleFrom,
        opacityFrom,
        fadeIn,
        revealMarkers,
        revealArcs,
        overshoot,
        curve,
        atmosphereDelay,
        markerDelay,
        arcDelay,
        autoRotateDelay,
        initialRotation,
        autoRotateOnComplete,
      );
}

/// Built-in entrance animation presets for the globe.
class GlobeIntroAnimations {
  const GlobeIntroAnimations._();

  /// The reference-inspired entrance preset:
  /// - Staged scale-up from 0.72 with cubic ease-out
  /// - Atmosphere bloom at 200ms
  /// - Marker spring pop-in at 400ms
  /// - Arc stream reveal at 600ms
  /// - Smooth auto-rotation handoff at 900ms
  static const GlobeIntroAnimation reference = GlobeIntroAnimation(
    enabled: true,
    duration: Duration(milliseconds: 1400),
    curve: Curves.easeOutCubic,
    scaleFrom: 0.72,
    opacityFrom: 0.0,
    fadeIn: true,
    revealMarkers: true,
    revealArcs: true,
    atmosphereDelay: Duration(milliseconds: 200),
    markerDelay: Duration(milliseconds: 400),
    arcDelay: Duration(milliseconds: 600),
    autoRotateDelay: Duration(milliseconds: 900),
    overshoot: 1.02,
  );

  /// Compatibility alias for the reference entrance preset.
  static const GlobeIntroAnimation reactBits = reference;

  /// Gentle, smooth 1000ms fade-in without scale overshoot.
  static const GlobeIntroAnimation gentle = GlobeIntroAnimation(
    enabled: true,
    duration: Duration(milliseconds: 1000),
    curve: Curves.easeOut,
    scaleFrom: 0.88,
    opacityFrom: 0.0,
    overshoot: 1.0,
    atmosphereDelay: Duration(milliseconds: 100),
    markerDelay: Duration(milliseconds: 250),
    arcDelay: Duration(milliseconds: 400),
    autoRotateDelay: Duration(milliseconds: 600),
  );

  /// Dynamic spring entrance with prominent scale bounce.
  static const GlobeIntroAnimation spring = GlobeIntroAnimation(
    enabled: true,
    duration: Duration(milliseconds: 1600),
    curve: Curves.easeOutBack,
    scaleFrom: 0.60,
    opacityFrom: 0.0,
    overshoot: 1.08,
    atmosphereDelay: Duration(milliseconds: 250),
    markerDelay: Duration(milliseconds: 500),
    arcDelay: Duration(milliseconds: 750),
    autoRotateDelay: Duration(milliseconds: 1100),
  );

  /// Instant display with no entrance transition.
  static const GlobeIntroAnimation none = GlobeIntroAnimation.none;
}
