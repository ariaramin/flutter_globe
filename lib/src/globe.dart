import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'animation/globe_intro_animation.dart';
import 'controllers/globe_tour.dart';
import 'gestures/globe_gesture_detector.dart';
import 'globe_controller.dart';
import 'layers/globe_layer.dart';
import 'math/globe_projection.dart';
import 'models/globe_arc.dart';
import 'models/globe_marker.dart';
import 'models/globe_style.dart';
import 'presets/globe_templates.dart';
import 'rendering/arc_renderer.dart';
import 'rendering/atmosphere_renderer.dart';
import 'rendering/dots_renderer.dart';
import 'rendering/globe_painter.dart';
import 'rendering/marker_renderer.dart';
import 'themes/globe_style_models.dart';
import 'themes/globe_theme.dart';

/// A high-performance, interactive 3D Globe widget for Flutter featuring animated great-circle arcs,
/// pulsing location beacons, land dots, atmospheric glow, customizable layers, and quaternion-driven touch interaction.
class Globe extends StatefulWidget {
  /// Creates an interactive 3D globe with optional themes, markers, arcs, layers, and intro animation.
  const Globe({
    super.key,
    this.controller,
    this.markers = const <GlobeMarker>[],
    this.arcs = const <GlobeArc>[],
    this.layers = const <GlobeLayer>[],
    this.theme,
    this.skin,
    this.tour,
    this.introAnimation = GlobeIntroAnimations.reference,
    this.projection = GlobeProjection.perspective,
    this.autoRotate,
    this.autoRotateSpeed,
    this.cameraAltitude = 2.6,
    this.interaction,
    this.interactive = true,
    this.enableZoom,
    this.rotationSensitivity,
    this.invertVerticalPan,
    this.radiusMultiplier = 0.82,
    this.quality,
    this.size,
    this.width,
    this.height,
    this.onGlobeTap,
    this.onMarkerTap,
    this.onInteractionStart,
    this.onInteractionEnd,
    this.onReady,
    this.semanticLabel,
  })  : assert(cameraAltitude > 1 && cameraAltitude < double.infinity),
        assert(radiusMultiplier > 0 && radiusMultiplier < double.infinity),
        assert(rotationSensitivity == null ||
            (rotationSensitivity >= 0 &&
                rotationSensitivity < double.infinity)),
        assert(autoRotateSpeed == null ||
            (autoRotateSpeed > -double.infinity &&
                autoRotateSpeed < double.infinity)),
        assert(size == null || (size >= 0 && size < double.infinity)),
        assert(width == null || (width >= 0 && width < double.infinity)),
        assert(height == null || (height >= 0 && height < double.infinity));

  /// Factory constructor to construct a Globe pre-configured from a complete [GlobeTemplate].
  factory Globe.template(
    GlobeTemplate template, {
    Key? key,
    GlobeController? controller,
    List<GlobeMarker>? markers,
    List<GlobeArc>? arcs,
    List<GlobeLayer>? layers,
    GlobeTheme? themeOverride,
    GlobeIntroAnimation introAnimation = GlobeIntroAnimations.reference,
    GlobeProjection projection = GlobeProjection.perspective,
    bool? autoRotate,
    double? autoRotateSpeed,
    GlobeInteractionConfig? interaction,
    bool interactive = true,
    bool? enableZoom,
    bool? invertVerticalPan,
    GlobeQuality? quality,
    double? size,
    double? width,
    double? height,
    GlobeTapCallback? onGlobeTap,
    MarkerTapCallback? onMarkerTap,
    VoidCallback? onReady,
  }) {
    return Globe(
      key: key,
      controller: controller,
      theme: themeOverride ?? template.theme,
      markers: markers ?? template.markers,
      arcs: arcs ?? template.arcs,
      layers: layers ?? template.layers,
      introAnimation: introAnimation,
      projection: projection,
      autoRotate: autoRotate,
      autoRotateSpeed: autoRotateSpeed ?? template.autoRotateSpeed,
      interaction: interaction,
      interactive: interactive,
      enableZoom: enableZoom,
      invertVerticalPan: invertVerticalPan,
      quality: quality,
      size: size,
      width: width,
      height: height,
      onGlobeTap: onGlobeTap,
      onMarkerTap: onMarkerTap,
      onReady: onReady,
    );
  }

  /// Optional programmatic controller for the globe. If omitted, an internal controller is managed.
  final GlobeController? controller;

  /// List of geographic location markers / beacons rendered on the globe surface.
  final List<GlobeMarker> markers;

  /// List of elevated, animated great-circle connection arcs.
  final List<GlobeArc> arcs;

  /// Extensible render layers (heatmaps, routes, particles, graticule lines, custom layers).
  final List<GlobeLayer> layers;

  /// Complete theme configuration.
  final GlobeTheme? theme;

  /// Built-in skin preset shortcut.
  final GlobeTheme? skin;

  /// Optional scripted camera tour to automatically execute.
  final GlobeTour? tour;

  /// Configuration for the entrance/reveal animation. Defaults to [GlobeIntroAnimations.reference].
  final GlobeIntroAnimation introAnimation;

  /// 3D camera projection mode (perspective vs orthographic).
  final GlobeProjection projection;

  /// Whether the globe rotates automatically when idle.
  final bool? autoRotate;

  /// Speed of automatic idle rotation in radians per second.
  final double? autoRotateSpeed;

  /// Camera altitude view distance (higher = orthographic-like, lower = strong perspective).
  final double cameraAltitude;

  /// Optional grouped interaction settings. When supplied, these settings take
  /// precedence over the corresponding primitive gesture and rotation options.
  final GlobeInteractionConfig? interaction;

  /// Whether user drag/pan gestures rotate the globe.
  final bool interactive;

  /// Whether pinch/scroll zoom is enabled.
  final bool? enableZoom;

  /// Sensitivity factor for touch/pointer drag rotation.
  final double? rotationSensitivity;

  /// Whether vertical pan gestures are inverted (swipe bottom rotates globe top, swipe top rotates globe bottom).
  final bool? invertVerticalPan;

  /// Fraction of viewport size occupied by the globe radius (0.5 to 0.95).
  final double radiusMultiplier;

  /// Detail and performance quality level.
  final GlobeQuality? quality;

  /// Optional square size constraint (sets both width and height in logical pixels).
  final double? size;

  /// Optional explicit width constraint in logical pixels.
  final double? width;

  /// Optional explicit height constraint in logical pixels.
  final double? height;

  /// Callback fired when the globe surface is tapped.
  final GlobeTapCallback? onGlobeTap;

  /// Callback fired when a marker is tapped.
  final MarkerTapCallback? onMarkerTap;

  /// Callback fired when user begins dragging or interacting.
  final VoidCallback? onInteractionStart;

  /// Callback fired when user interaction ends.
  final VoidCallback? onInteractionEnd;

  /// Callback fired when the globe has finished initial layout and is ready.
  final VoidCallback? onReady;

  /// Localized description for assistive technologies. Provide accessible controls
  /// and a text list alongside the canvas when markers convey important data.
  final String? semanticLabel;

  @override
  State<Globe> createState() => _GlobeState();
}

class _GlobeState extends State<Globe> with TickerProviderStateMixin {
  late GlobeController _controller;
  bool _ownsController = false;
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  double _elapsedTimeMs = 0.0;
  double _introElapsedMs = 0.0;
  double _introProgress = 0.0;
  bool _isReadyFired = false;
  bool _startedTour = false;
  final ValueNotifier<int> _frame = ValueNotifier(0);

  final AtmosphereRenderer _atmosphereRenderer = AtmosphereRenderer();
  final DotsRenderer _dotsRenderer = DotsRenderer();
  final ArcRenderer _arcRenderer = ArcRenderer();
  final MarkerRenderer _markerRenderer = MarkerRenderer();

  @override
  void initState() {
    super.initState();
    _initController();
    if (!widget.introAnimation.enabled ||
        widget.introAnimation.duration == Duration.zero) {
      _introProgress = 1.0;
    }
    _startTicker();
  }

  void _initController() {
    final interaction = _resolveInteraction();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = GlobeController(
        initialRotation: widget.introAnimation.initialRotation,
        autoRotate: interaction.autoRotate,
        autoRotateSpeed: interaction.autoRotateSpeed,
      );
      _ownsController = true;
    }

    final tour = widget.tour;
    if (tour != null && tour.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            widget.tour == tour &&
            !(MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
          _startedTour = true;
          _controller.playTour(tour: tour, vsync: this);
        }
      });
    }
  }

  void _startTicker() {
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    if (!_isReadyFired) {
      _isReadyFired = true;
      widget.onReady?.call();
    }

    final deltaDuration = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    final dtSeconds = deltaDuration.inMicroseconds / 1000000.0;
    final deltaMs = deltaDuration.inMicroseconds / 1000.0;

    // Check reduced motion accessibility
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final previousIntro = _introProgress;
    if (disableAnimations || !widget.introAnimation.enabled) {
      _introProgress = 1.0;
    } else if (_introProgress < 1.0) {
      _introElapsedMs += deltaMs;
      final totalDurationMs =
          widget.introAnimation.duration.inMilliseconds.toDouble();
      if (totalDurationMs > 0) {
        _introProgress = (_introElapsedMs / totalDurationMs).clamp(0.0, 1.0);
      } else {
        _introProgress = 1.0;
      }
    }

    // Advance auto-rotation with intro auto-rotate blend
    if (!disableAnimations) {
      _elapsedTimeMs += deltaMs;
      final blend =
          widget.introAnimation.computeAutoRotateBlend(_introProgress);
      _controller.tickAutoRotation(
        dtSeconds.clamp(0.0, 0.1),
        blend: blend,
        pauseWhileInteracting: _resolveInteraction().pauseOnTouch,
      );
    }
    if (!disableAnimations || previousIntro != _introProgress) _frame.value++;
  }

  @override
  void didUpdateWidget(covariant Globe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_startedTour) {
        _controller.stopTour();
        _startedTour = false;
      }
      if (_ownsController) {
        _controller.dispose();
      }
      _initController();
    } else {
      final interaction = _resolveInteraction();
      final oldInteraction = _resolveInteraction(oldWidget);
      if (interaction.autoRotate != oldInteraction.autoRotate) {
        _controller.autoRotate = interaction.autoRotate;
      }
      if (interaction.autoRotateSpeed != oldInteraction.autoRotateSpeed) {
        _controller.autoRotateSpeed = interaction.autoRotateSpeed;
      }
    }

    if (widget.introAnimation != oldWidget.introAnimation) {
      if (!widget.introAnimation.enabled ||
          widget.introAnimation.duration == Duration.zero) {
        _introProgress = 1.0;
      }
    }
  }

  @override
  void dispose() {
    if (_startedTour) _controller.stopTour();
    _ticker?.dispose();
    _frame.dispose();
    _markerRenderer.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  GlobeStyle _styleFromTheme(GlobeTheme theme) => GlobeStyle(
        primaryColor: theme.accentColor,
        neutralColor: theme.surface.landColor,
        surfaceColor: theme.surface.surfaceColor,
        atmosphereColor: theme.atmosphere.color,
        pointSize: theme.surface.pointSize,
        pointOpacity: theme.surface.pointOpacity,
        rearPointOpacity: theme.surface.rearPointOpacity,
        globeOpacity: theme.surface.globeOpacity,
        showAtmosphere: theme.atmosphere.visible,
        atmosphereAltitude: theme.atmosphere.altitude,
        ambientLight: theme.lighting.ambientIntensity,
        diffuseLight: theme.lighting.directionalIntensity,
        lightDirection: theme.lighting.lightDirection,
      );

  GlobeInteractionConfig _resolveInteraction([Globe? target]) {
    final globe = target ?? widget;
    final base = globe.interaction ??
        globe.theme?.interaction ??
        globe.skin?.interaction ??
        const GlobeInteractionConfig();
    return base.copyWith(
      zoomEnabled: globe.enableZoom,
      rotationSensitivity: globe.rotationSensitivity,
      invertVerticalPan: globe.invertVerticalPan,
      autoRotate: globe.autoRotate,
      autoRotateSpeed: globe.autoRotateSpeed,
    );
  }

  GlobeQuality _resolveQuality() =>
      widget.quality ??
      widget.theme?.quality ??
      widget.skin?.quality ??
      GlobeQuality.auto;

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.theme ?? widget.skin ?? const GlobeTheme();
    final effectiveStyle = _styleFromTheme(effectiveTheme);
    final effectiveInteraction = _resolveInteraction();
    final effectiveQuality = _resolveQuality();
    final effectiveWidth = widget.width ?? widget.size;
    final effectiveHeight = widget.height ?? widget.size;

    Widget result = RepaintBoundary(
      child: GlobeGestureHandler(
        controller: _controller,
        markers: widget.markers,
        interactive: widget.interactive,
        dragEnabled: effectiveInteraction.dragEnabled,
        enableZoom: effectiveInteraction.zoomEnabled,
        inertiaEnabled: effectiveInteraction.inertiaEnabled,
        inertiaFriction: effectiveInteraction.inertiaFriction,
        rotationSensitivity: effectiveInteraction.rotationSensitivity,
        invertVerticalPan: effectiveInteraction.invertVerticalPan,
        cameraAltitude: widget.cameraAltitude,
        projection: widget.projection,
        radiusMultiplier: widget.radiusMultiplier,
        onGlobeTap: widget.onGlobeTap,
        onMarkerTap: widget.onMarkerTap,
        onInteractionStart: widget.onInteractionStart,
        onInteractionEnd: widget.onInteractionEnd,
        child: AnimatedBuilder(
          animation: Listenable.merge([_controller, _frame]),
          builder: (context, child) {
            return CustomPaint(
              painter: GlobePainter(
                rotation: _controller.rotation,
                style: effectiveStyle,
                theme: effectiveTheme,
                markers: widget.markers,
                arcs: widget.arcs,
                layers: widget.layers,
                animationTimeMs: _elapsedTimeMs,
                cameraAltitude: widget.cameraAltitude,
                radiusMultiplier: widget.radiusMultiplier * _controller.zoom,
                quality: effectiveQuality,
                projection: widget.projection,
                introAnimation: widget.introAnimation,
                introProgress: _introProgress,
                atmosphereRenderer: _atmosphereRenderer,
                dotsRenderer: _dotsRenderer,
                arcRenderer: _arcRenderer,
                markerRenderer: _markerRenderer,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );

    if (effectiveWidth != null || effectiveHeight != null) {
      result = SizedBox(
        width: effectiveWidth,
        height: effectiveHeight,
        child: result,
      );
    }

    return Semantics(
      label: widget.semanticLabel,
      image: true,
      child: result,
    );
  }
}
