import 'dart:ui' as ui;
import 'dart:math' as math;
import 'benchmark.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_globe/flutter_globe.dart';

void main() {
  runApp(const GlobeProShowcaseApp());
}

/// The main entry point for the Flutter Globe open-source showcase application.
class GlobeProShowcaseApp extends StatelessWidget {
  const GlobeProShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 3D Globe Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          surface: Color(0xFF0F172A),
          secondary: Color(0xFF06B6D4),
        ),
      ),
      home: const GlobeShowcaseScreen(),
    );
  }
}

/// Main destination tabs in the showcase application (strictly no tour tab).
enum ShowcaseTab {
  showcase('Showcase', Icons.public_rounded),
  skins('Skins', Icons.palette_outlined),
  arcs('Arcs', Icons.all_inclusive_rounded),
  markers('Markers', Icons.place_outlined),
  layers('Data Layers', Icons.layers_outlined),
  playground('Playground', Icons.tune_rounded),
  benchmarks('Benchmarks', Icons.speed_rounded);

  const ShowcaseTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

class GlobeShowcaseScreen extends StatefulWidget {
  const GlobeShowcaseScreen({super.key});

  @override
  State<GlobeShowcaseScreen> createState() => _GlobeShowcaseScreenState();
}

class _GlobeShowcaseScreenState extends State<GlobeShowcaseScreen>
    with TickerProviderStateMixin {
  late GlobeController _controller;
  ShowcaseTab _activeTab = ShowcaseTab.showcase;

  // Active theme and skin selection
  int _selectedSkinIndex = 0;
  GlobeTheme _activeTheme = GlobeSkins.reference;
  bool _isFullscreen = false;
  Key _globeKey = UniqueKey();

  // Intro animation settings
  final GlobeIntroAnimation _introConfig = GlobeIntroAnimations.reference;

  // Interactive & visual state
  bool _autoRotate = true;
  double _autoRotateSpeed = 0.22;
  GlobeProjection _projection = GlobeProjection.perspective;
  GlobeQuality _quality = GlobeQuality.auto;
  double _radiusMultiplier = 0.82;
  double _pointSize = 1.65;
  double _pointOpacity = 0.95;
  double _globeOpacity = 1.0;
  bool _showAtmosphere = true;
  double _atmosphereAltitude = 0.22;
  double _atmosphereGlow = 0.75;
  double _ambientLight = 0.35;
  double _directionalLight = 0.65;
  bool _enableZoom = true;
  bool _inertiaEnabled = true;
  double _rotationSensitivity = 0.005;
  bool _showGrid = false;
  bool _showDayNight = false;
  bool _showHeatmap = false;
  bool _showRoutes = true;
  bool _showParticles = false;

  // Arc Showcase settings
  double _arcAltitude = 0.28;
  double _arcStrokeWidth = 2.0;
  double _arcSpeedMs = 2400.0;
  final bool _arcShowBaseLine = true;
  double _markerSize = 5.0;
  bool _markerPulse = true;

  // Inspection HUD
  GlobeMarker? _inspectedMarker;
  GlobeCoordinate? _inspectedCoordinate;

  @override
  void initState() {
    super.initState();
    _controller = GlobeController(
      autoRotate: _autoRotate,
      autoRotateSpeed: _autoRotateSpeed,
    );
    _controller.addListener(() {
      if (mounted && _autoRotate != _controller.autoRotate) {
        setState(() {
          _autoRotate = _controller.autoRotate;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replayIntroAnimation() {
    setState(() {
      _globeKey = UniqueKey();
    });
  }

  void _selectSkin(int index) {
    setState(() {
      _selectedSkinIndex = index;
      _activeTheme = GlobeSkins.all[index];
      _pointSize = _activeTheme.surface.pointSize;
      _pointOpacity = _activeTheme.surface.pointOpacity;
      _globeOpacity = _activeTheme.surface.globeOpacity;
      _showAtmosphere = _activeTheme.atmosphere.visible;
      _atmosphereAltitude = _activeTheme.atmosphere.altitude;
      _atmosphereGlow = _activeTheme.atmosphere.glowIntensity;
      _ambientLight = _activeTheme.lighting.ambientIntensity;
      _directionalLight = _activeTheme.lighting.directionalIntensity;
    });
  }

  GlobeTheme get _configuredTheme => _activeTheme.copyWith(
        surface: _activeTheme.surface.copyWith(
          pointSize: _pointSize,
          pointOpacity: _pointOpacity,
          globeOpacity: _globeOpacity,
        ),
        atmosphere: _activeTheme.atmosphere.copyWith(
          visible: _showAtmosphere,
          altitude: _atmosphereAltitude,
          glowIntensity: _atmosphereGlow,
        ),
        lighting: _activeTheme.lighting.copyWith(
          ambientIntensity: _ambientLight,
          directionalIntensity: _directionalLight,
        ),
        interaction: _activeTheme.interaction.copyWith(
          zoomEnabled: _enableZoom,
          inertiaEnabled: _inertiaEnabled,
          rotationSensitivity: _rotationSensitivity,
          autoRotate: _autoRotate,
          autoRotateSpeed: _autoRotateSpeed,
        ),
        quality: _quality,
      );

  List<GlobeMarker> _getStandardMarkers() {
    final color = _activeTheme.accentColor;
    return [
      GlobeMarker.latLng(
        latitude: 37.7749,
        longitude: -122.4194,
        label: 'San Francisco',
        color: color,
        size: _markerSize,
        pulse: _markerPulse,
      ),
      GlobeMarker.latLng(
        latitude: 51.5074,
        longitude: -0.1278,
        label: 'London',
        color: color,
        size: _markerSize,
        pulse: _markerPulse,
      ),
      GlobeMarker.latLng(
        latitude: 35.6762,
        longitude: 139.6503,
        label: 'Tokyo',
        color: color,
        size: _markerSize,
        pulse: _markerPulse,
      ),
      GlobeMarker.latLng(
        latitude: 25.2048,
        longitude: 55.2708,
        label: 'Dubai',
        color: color,
        size: _markerSize,
        pulse: _markerPulse,
      ),
      GlobeMarker.latLng(
        latitude: -33.8688,
        longitude: 151.2093,
        label: 'Sydney',
        color: color,
        size: _markerSize,
        pulse: _markerPulse,
      ),
      GlobeMarker.latLng(
        latitude: -22.9068,
        longitude: -43.1729,
        label: 'Rio de Janeiro',
        color: color,
        size: _markerSize,
        pulse: _markerPulse,
      ),
      GlobeMarker.latLng(
        latitude: 1.3521,
        longitude: 103.8198,
        label: 'Singapore',
        color: color,
        size: _markerSize,
        pulse: _markerPulse,
      ),
    ];
  }

  List<GlobeArc> _getStandardArcs() {
    final color = _activeTheme.accentColor;
    return [
      GlobeArc(
        start: const GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
        end: const GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
        color: color,
        altitude: _arcAltitude,
        strokeWidth: _arcStrokeWidth,
        duration: Duration(milliseconds: _arcSpeedMs.round()),
        showBaseLine: _arcShowBaseLine,
      ),
      GlobeArc(
        start: const GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
        end: const GlobeCoordinate(latitude: 25.2048, longitude: 55.2708),
        color: color,
        altitude: _arcAltitude + 0.04,
        strokeWidth: _arcStrokeWidth,
        duration: Duration(milliseconds: (_arcSpeedMs * 0.9).round()),
        delay: const Duration(milliseconds: 300),
        showBaseLine: _arcShowBaseLine,
      ),
      GlobeArc(
        start: const GlobeCoordinate(latitude: 25.2048, longitude: 55.2708),
        end: const GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
        color: color,
        altitude: _arcAltitude + 0.08,
        strokeWidth: _arcStrokeWidth,
        duration: Duration(milliseconds: (_arcSpeedMs * 1.1).round()),
        delay: const Duration(milliseconds: 600),
        showBaseLine: _arcShowBaseLine,
      ),
      GlobeArc(
        start: const GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
        end: const GlobeCoordinate(latitude: -33.8688, longitude: 151.2093),
        color: color,
        altitude: _arcAltitude + 0.02,
        strokeWidth: _arcStrokeWidth,
        duration: Duration(milliseconds: (_arcSpeedMs * 0.85).round()),
        delay: const Duration(milliseconds: 900),
        showBaseLine: _arcShowBaseLine,
      ),
      GlobeArc(
        start: const GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
        end: const GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
        color: color,
        altitude: _arcAltitude + 0.12,
        strokeWidth: _arcStrokeWidth,
        duration: Duration(milliseconds: (_arcSpeedMs * 1.25).round()),
        delay: const Duration(milliseconds: 400),
        showBaseLine: _arcShowBaseLine,
      ),
    ];
  }

  String _generateDartCode({bool fullConfig = false}) {
    final skinName =
        GlobeSkins.named.entries.firstWhere((e) => e.value == _activeTheme).key;
    String color(Color value) =>
        'const Color(0x${value.toARGB32().toRadixString(16).padLeft(8, '0')})';
    String coordinate(GlobeCoordinate c) =>
        'GlobeCoordinate(latitude: ${c.latitude}, longitude: ${c.longitude})';
    final markers = _getStandardMarkers()
        .map((m) =>
            "GlobeMarker(coordinate: ${coordinate(m.coordinate)}, label: '${m.label}', color: ${color(m.color)}, size: $_markerSize, pulse: $_markerPulse)")
        .join(',\n    ');
    final arcs = (_activeTab == ShowcaseTab.markers
            ? <GlobeArc>[]
            : _getStandardArcs())
        .map((a) =>
            'GlobeArc(start: ${coordinate(a.start)}, end: ${coordinate(a.end)}, color: ${color(a.color)}, altitude: ${a.altitude}, strokeWidth: ${a.strokeWidth}, duration: Duration(microseconds: ${a.duration.inMicroseconds}), delay: Duration(microseconds: ${a.delay.inMicroseconds}))')
        .join(',\n    ');
    final globe = """Globe(
  theme: GlobeSkins.$skinName.copyWith(
    surface: GlobeSkins.$skinName.surface.copyWith(pointSize: $_pointSize, pointOpacity: $_pointOpacity, globeOpacity: $_globeOpacity),
    atmosphere: GlobeSkins.$skinName.atmosphere.copyWith(visible: $_showAtmosphere, altitude: $_atmosphereAltitude, glowIntensity: $_atmosphereGlow),
    lighting: GlobeSkins.$skinName.lighting.copyWith(ambientIntensity: $_ambientLight, directionalIntensity: $_directionalLight),
    interaction: GlobeSkins.$skinName.interaction.copyWith(zoomEnabled: $_enableZoom, inertiaEnabled: $_inertiaEnabled, rotationSensitivity: $_rotationSensitivity, autoRotate: $_autoRotate, autoRotateSpeed: $_autoRotateSpeed),
    quality: GlobeQuality.${_quality.name},
  ),
  projection: GlobeProjection.${_projection.name},
  radiusMultiplier: $_radiusMultiplier,
  markers: [$markers],
  arcs: [$arcs],
)""";
    if (!fullConfig) return globe;
    return """import 'package:flutter/material.dart';
import 'package:flutter_globe/flutter_globe.dart';

void main() => runApp(MaterialApp(home: Scaffold(
  backgroundColor: const Color(0xFF020617),
  body: Center(child: SizedBox.square(dimension: 400, child: $globe)),
)));
""";
  }

  void _showCodeExportDialog() {
    var isFullConfig = false;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final code = _generateDartCode(fullConfig: isFullConfig);
            return DraggableScrollableSheet(
              initialChildSize: 0.70,
              minChildSize: 0.45,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Scene code',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isFullConfig
                                    ? 'Runnable app with current scene'
                                    : 'Current globe configuration',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          )),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: const Text('Copy Code'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38BDF8),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              try {
                                await Clipboard.setData(
                                    ClipboardData(text: code));
                              } on PlatformException {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Clipboard unavailable')));
                                }
                                return;
                              }
                              if (!context.mounted || !ctx.mounted) return;
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Copied generated Dart code to clipboard!'),
                                  backgroundColor: Color(0xFF0284C7),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Minimal Config'),
                            selected: !isFullConfig,
                            onSelected: (val) {
                              if (val) {
                                setSheetState(() => isFullConfig = false);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Runnable app'),
                            selected: isFullConfig,
                            onSelected: (val) {
                              if (val) {
                                setSheetState(() => isFullConfig = true);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF020617),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF1E293B)),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: SelectableText(
                              code,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12.5,
                                height: 1.5,
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient with atmospheric depth
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.35,
                  colors: [
                    Color(0xFF0B132B),
                    Color(0xFF020617),
                  ],
                ),
              ),
            ),
          ),

          // Central 3D Globe Render View
          Positioned.fill(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: _buildActiveGlobe(),
              ),
            ),
          ),

          if (_activeTab == ShowcaseTab.benchmarks)
            const Positioned.fill(
                top: 130,
                child: ColoredBox(
                    color: Color(0xFF020617), child: BenchmarkPage())),

          // Top Header & Performance Monitor HUD
          if (!_isFullscreen)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: _buildTopHeader(),
              ),
            ),

          // Inspected Marker / Telemetry HUD Card
          if (_inspectedMarker != null || _inspectedCoordinate != null)
            Positioned(
              top: 140,
              right: 20,
              child: _buildInspectionHUDCard(),
            ),

          // Bottom Control Panel / Navigation Dock
          if (!_isFullscreen)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.4),
                    child: SingleChildScrollView(child: _buildBottomPanel())),
              ),
            ),

          // Exit Fullscreen Floating Button
          if (_isFullscreen)
            Positioned(
              top: 24,
              right: 24,
              child: FloatingActionButton.small(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                tooltip: 'Exit fullscreen preview',
                child: const Icon(Icons.fullscreen_exit_rounded),
                onPressed: () => setState(() => _isFullscreen = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveGlobe() {
    switch (_activeTab) {
      case ShowcaseTab.benchmarks:
        return const SizedBox.shrink();
      case ShowcaseTab.playground:
      case ShowcaseTab.showcase:
        return Globe(
          key: _globeKey,
          controller: _controller,
          theme: _configuredTheme,
          introAnimation: _introConfig,
          projection: _projection,
          radiusMultiplier: _radiusMultiplier,
          markers: _getStandardMarkers(),
          arcs: _getStandardArcs(),
          onMarkerTap: (m) => setState(() => _inspectedMarker = m),
          onGlobeTap: (c) => setState(() => _inspectedCoordinate = c),
        );

      case ShowcaseTab.skins:
        return GlobeThemeTransition(
          theme: _activeTheme,
          builder: (context, interpolatedTheme) {
            return Globe(
              key: _globeKey,
              controller: _controller,
              theme: interpolatedTheme,
              projection: _projection,
              radiusMultiplier: _radiusMultiplier,
              markers: _getStandardMarkers(),
              arcs: _getStandardArcs(),
              onMarkerTap: (m) => setState(() => _inspectedMarker = m),
              onGlobeTap: (c) => setState(() => _inspectedCoordinate = c),
            );
          },
        );

      case ShowcaseTab.arcs:
        return Globe(
          key: _globeKey,
          controller: _controller,
          theme: _configuredTheme,
          projection: _projection,
          radiusMultiplier: _radiusMultiplier,
          markers: _getStandardMarkers(),
          arcs: _getStandardArcs(),
          onMarkerTap: (m) => setState(() => _inspectedMarker = m),
          onGlobeTap: (c) => setState(() => _inspectedCoordinate = c),
        );

      case ShowcaseTab.markers:
        return Globe(
          key: _globeKey,
          controller: _controller,
          theme: _configuredTheme,
          projection: _projection,
          radiusMultiplier: _radiusMultiplier,
          markers: _getStandardMarkers(),
          onMarkerTap: (m) => setState(() => _inspectedMarker = m),
          onGlobeTap: (c) => setState(() => _inspectedCoordinate = c),
        );

      case ShowcaseTab.layers:
        return Globe(
          key: _globeKey,
          controller: _controller,
          theme: _configuredTheme,
          projection: _projection,
          radiusMultiplier: _radiusMultiplier,
          markers: _getStandardMarkers(),
          arcs: _getStandardArcs(),
          layers: [
            if (_showGrid) const GlobeGridLayer(),
            if (_showDayNight) const GlobeDayNightLayer(),
            if (_showHeatmap)
              const GlobeHeatmapLayer(
                points: [
                  GlobeHeatPoint(
                    coordinate: GlobeCoordinate(
                        latitude: 37.7749, longitude: -122.4194),
                    intensity: 0.9,
                    radius: 28,
                  ),
                  GlobeHeatPoint(
                    coordinate:
                        GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
                    intensity: 0.85,
                    radius: 26,
                  ),
                  GlobeHeatPoint(
                    coordinate:
                        GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
                    intensity: 0.95,
                    radius: 30,
                  ),
                ],
              ),
            if (_showRoutes)
              const GlobeRouteLayer(
                routes: [
                  // Transatlantic corridor (SFO -> London -> Dubai)
                  GlobeRoute(
                    waypoints: [
                      GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
                      GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
                      GlobeCoordinate(latitude: 25.2048, longitude: 55.2708),
                    ],
                    color: Color(0xFF38BDF8),
                    altitude: 0.28,
                    strokeWidth: 2.0,
                    duration: Duration(seconds: 7),
                    showVehicle: true,
                    vehicleType: GlobeVehicleType.airplane,
                    vehicleColor: Colors.white,
                    vehicleSize: 18.0,
                  ),
                  // Asia-Pacific corridor (Tokyo -> Singapore -> Sydney)
                  GlobeRoute(
                    waypoints: [
                      GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
                      GlobeCoordinate(latitude: 1.3521, longitude: 103.8198),
                      GlobeCoordinate(latitude: -33.8688, longitude: 151.2093),
                    ],
                    color: Color(0xFFFBBF24),
                    altitude: 0.24,
                    strokeWidth: 2.0,
                    duration: Duration(seconds: 6),
                    delay: Duration(milliseconds: 1500),
                    showVehicle: true,
                    vehicleType: GlobeVehicleType.airplane,
                    vehicleColor: Color(0xFFFEF08A),
                    vehicleSize: 18.0,
                  ),
                  // Americas to Europe corridor (Rio -> London -> Tokyo)
                  GlobeRoute(
                    waypoints: [
                      GlobeCoordinate(latitude: -22.9068, longitude: -43.1729),
                      GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
                      GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
                    ],
                    color: Color(0xFF34D399),
                    altitude: 0.32,
                    strokeWidth: 2.0,
                    duration: Duration(seconds: 8),
                    delay: Duration(milliseconds: 3000),
                    showVehicle: true,
                    vehicleType: GlobeVehicleType.airplane,
                    vehicleColor: Color(0xFFA7F3D0),
                    vehicleSize: 18.0,
                  ),
                ],
              ),
            if (_showParticles)
              GlobeParticleLayer(
                particleCount: 40,
                color: _activeTheme.accentColor,
              ),
          ],
          onMarkerTap: (m) => setState(() => _inspectedMarker = m),
          onGlobeTap: (c) => setState(() => _inspectedCoordinate = c),
        );
    }
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          const Icon(Icons.public, color: Color(0xFF38BDF8)),
          const SizedBox(width: 8),
          const Expanded(
              child: Text('Flutter Globe',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          IconButton(
              tooltip: 'Replay intro',
              onPressed: _replayIntroAnimation,
              icon: const Icon(Icons.replay)),
          IconButton(
              tooltip: 'Copy code',
              onPressed: _activeTab == ShowcaseTab.layers ||
                      _activeTab == ShowcaseTab.benchmarks
                  ? null
                  : _showCodeExportDialog,
              icon: const Icon(Icons.code)),
          IconButton(
              tooltip: 'Fullscreen preview',
              onPressed: () => setState(() => _isFullscreen = true),
              icon: const Icon(Icons.fullscreen)),
        ]),
        const SizedBox(height: 12),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ShowcaseTab.values
                  .map((tab) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: _activeTab == tab
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF0F172A),
                            foregroundColor: _activeTab == tab
                                ? Colors.black
                                : Colors.white70,
                          ),
                          onPressed: () => setState(() {
                            _activeTab = tab;
                            _inspectedMarker = null;
                            _inspectedCoordinate = null;
                          }),
                          icon: Icon(tab.icon, size: 18),
                          label: Text(tab.label),
                        ),
                      ))
                  .toList(),
            )),
      ]),
    );
  }

  Widget _buildInspectionHUDCard() {
    final label = _inspectedMarker?.label ?? 'Surface Coordinate';
    final coord = _inspectedMarker?.coordinate ?? _inspectedCoordinate!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 16),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.gps_fixed_rounded,
                          size: 12, color: Color(0xFF38BDF8)),
                      SizedBox(width: 4),
                      Text(
                        'COORDINATE HUD',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _inspectedMarker = null;
                      _inspectedCoordinate = null;
                    }),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                '${coord.latitude.toStringAsFixed(4)}°, ${coord.longitude.toStringAsFixed(4)}°',
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    switch (_activeTab) {
      case ShowcaseTab.benchmarks:
        return const SizedBox.shrink();
      case ShowcaseTab.playground:
        return _buildPlaygroundControls();
      case ShowcaseTab.showcase:
        return _buildShowcaseQuickControls();
      case ShowcaseTab.skins:
        return _buildSkinsGallerySheet();
      case ShowcaseTab.arcs:
        return _buildArcsControlSheet();
      case ShowcaseTab.markers:
        return _buildMarkersControlSheet();
      case ShowcaseTab.layers:
        return _buildLayersControlSheet();
    }
  }

  Widget _buildShowcaseQuickControls() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _autoRotate
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: const Color(0xFF38BDF8),
                      size: 24,
                    ),
                    tooltip: _autoRotate ? 'Pause Rotation' : 'Resume Rotation',
                    onPressed: () {
                      setState(() {
                        _autoRotate = !_autoRotate;
                        _controller.autoRotate = _autoRotate;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 22),
                    tooltip: 'Reset Camera View',
                    onPressed: () => _controller.resetView(vsync: this),
                  ),
                ],
              ),
              // Skin Quick Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickSkinChip(
                        0, 'Reference', const Color(0xFF38BDF8)),
                    _buildQuickSkinChip(
                        1, 'Realistic Earth', const Color(0xFF40916C)),
                    _buildQuickSkinChip(
                        2, 'Topographic', const Color(0xFFD97706)),
                    _buildQuickSkinChip(
                        6, 'Cyberpunk', const Color(0xFF06B6D4)),
                    _buildQuickSkinChip(7, 'Hologram', const Color(0xFF38BDF8)),
                    _buildQuickSkinChip(5, 'Midnight', const Color(0xFFA855F7)),
                    _buildQuickSkinChip(8, 'Neon', const Color(0xFF10B981)),
                    _buildQuickSkinChip(4, 'Minimal', Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSkinChip(int index, String label, Color dotColor) {
    final isSelected = _selectedSkinIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        avatar: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
          ),
        ),
        label: Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white)),
        selected: isSelected,
        selectedColor: const Color(0xFF38BDF8).withValues(alpha: 0.25),
        checkmarkColor: const Color(0xFF38BDF8),
        onSelected: (val) {
          if (val) _selectSkin(index);
        },
      ),
    );
  }

  Widget _buildSkinsGallerySheet() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: GlobeSkins.all.length,
            itemBuilder: (context, index) {
              final skin = GlobeSkins.all[index];
              final skinKey = GlobeSkins.named.entries
                  .firstWhere(
                    (e) => e.value == skin,
                    orElse: () => MapEntry('Skin $index', skin),
                  )
                  .key;
              final isSelected = _selectedSkinIndex == index;

              return TextButton(
                onPressed: () => _selectSkin(index),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF020617).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF1E293B),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: skin.surface.surfaceColor,
                          border: Border.all(color: skin.accentColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: skin.accentColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        skinKey.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF38BDF8)
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildArcsControlSheet() {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Arc controls',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Altitude: ${_arcAltitude.toStringAsFixed(2)}'),
                Slider(
                    value: _arcAltitude,
                    min: 0.1,
                    max: 0.55,
                    label: _arcAltitude.toStringAsFixed(2),
                    onChanged: (v) => setState(() => _arcAltitude = v)),
                Text(
                    'Duration: ${(_arcSpeedMs / 1000).toStringAsFixed(1)} seconds'),
                Slider(
                    value: _arcSpeedMs,
                    min: 1000,
                    max: 6000,
                    label: '${(_arcSpeedMs / 1000).toStringAsFixed(1)} seconds',
                    onChanged: (v) => setState(() => _arcSpeedMs = v)),
              ],
            )));
  }

  Widget _buildMarkersControlSheet() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 16, color: Color(0xFF38BDF8)),
                      SizedBox(width: 6),
                      Text('Location markers',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text('Tap a marker to inspect its coordinates',
                      style: TextStyle(fontSize: 11, color: Colors.white54)),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.gps_fixed_rounded, size: 16),
                label: const Text('Focus London'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _controller.flyTo(
                    coordinate: const GlobeCoordinate(
                        latitude: 51.5074, longitude: -0.1278),
                    vsync: this,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayersControlSheet() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                avatar: const Icon(Icons.grid_4x4_rounded, size: 14),
                label: const Text('Graticule Grid'),
                selected: _showGrid,
                onSelected: (v) => setState(() => _showGrid = v),
              ),
              FilterChip(
                avatar: const Icon(Icons.wb_sunny_outlined, size: 14),
                label: const Text('Day/Night Terminator'),
                selected: _showDayNight,
                onSelected: (v) => setState(() => _showDayNight = v),
              ),
              FilterChip(
                avatar: const Icon(Icons.whatshot_rounded, size: 14),
                label: const Text('Thermal Heatmap'),
                selected: _showHeatmap,
                onSelected: (v) => setState(() => _showHeatmap = v),
              ),
              FilterChip(
                avatar: const Icon(Icons.flight_takeoff_rounded, size: 14),
                label: const Text('Flight Routes & Airplanes'),
                selected: _showRoutes,
                onSelected: (v) => setState(() => _showRoutes = v),
              ),
              FilterChip(
                avatar: const Icon(Icons.auto_awesome_rounded, size: 14),
                label: const Text('Orbital Particles'),
                selected: _showParticles,
                onSelected: (v) => setState(() => _showParticles = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaygroundControls() {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Make it yours',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  ActionChip(
                      label: const Text('Reset'), onPressed: _resetPlayground),
                  ActionChip(
                      label: const Text('Randomize'),
                      onPressed: () => _selectSkin(
                          math.Random().nextInt(GlobeSkins.all.length))),
                  ActionChip(
                      label: const Text('Copy code'),
                      onPressed: _showCodeExportDialog),
                  ActionChip(
                      label: const Text('Fullscreen'),
                      onPressed: () => setState(() => _isFullscreen = true)),
                  ...[0, 6, 7].map((index) => ChoiceChip(
                      label: Text(GlobeSkins.named.entries
                          .firstWhere(
                              (entry) => entry.value == GlobeSkins.all[index])
                          .key),
                      selected: _selectedSkinIndex == index,
                      onSelected: (_) => _selectSkin(index))),
                ]),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Globe and interaction'),
                  initiallyExpanded: true,
                  children: [
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final projection in GlobeProjection.values)
                        ChoiceChip(
                          label: Text(projection.name),
                          selected: _projection == projection,
                          onSelected: (_) =>
                              setState(() => _projection = projection),
                        ),
                      for (final quality in GlobeQuality.values)
                        ChoiceChip(
                          label: Text(quality.name),
                          selected: _quality == quality,
                          onSelected: (_) => setState(() => _quality = quality),
                        ),
                    ]),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto rotation'),
                      value: _autoRotate,
                      onChanged: (value) => setState(() => _autoRotate = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Pinch zoom'),
                      value: _enableZoom,
                      onChanged: (value) => setState(() => _enableZoom = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Drag inertia'),
                      value: _inertiaEnabled,
                      onChanged: (value) =>
                          setState(() => _inertiaEnabled = value),
                    ),
                    _playgroundSlider('Globe scale', _radiusMultiplier, 0.55,
                        0.95, (value) => _radiusMultiplier = value),
                    _playgroundSlider('Zoom', _controller.zoom, 0.5, 2.0,
                        (value) => _controller.zoom = value),
                    _playgroundSlider('Rotation speed', _autoRotateSpeed, 0,
                        1.5, (value) => _autoRotateSpeed = value),
                    _playgroundSlider('Drag sensitivity', _rotationSensitivity,
                        0.001, 0.012, (value) => _rotationSensitivity = value),
                  ],
                ),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Surface and lighting'),
                  children: [
                    _playgroundSlider('Point size', _pointSize, 0.5, 4,
                        (value) => _pointSize = value),
                    _playgroundSlider('Land opacity', _pointOpacity, 0, 1,
                        (value) => _pointOpacity = value),
                    _playgroundSlider('Globe opacity', _globeOpacity, 0.2, 1,
                        (value) => _globeOpacity = value),
                    _playgroundSlider('Ambient light', _ambientLight, 0, 1,
                        (value) => _ambientLight = value),
                    _playgroundSlider('Directional light', _directionalLight, 0,
                        1, (value) => _directionalLight = value),
                  ],
                ),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Atmosphere'),
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enabled'),
                      value: _showAtmosphere,
                      onChanged: (value) =>
                          setState(() => _showAtmosphere = value),
                    ),
                    _playgroundSlider('Altitude', _atmosphereAltitude, 0, 0.5,
                        (value) => _atmosphereAltitude = value),
                    _playgroundSlider('Glow', _atmosphereGlow, 0, 1,
                        (value) => _atmosphereGlow = value),
                  ],
                ),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Arcs and markers'),
                  children: [
                    _playgroundSlider('Arc altitude', _arcAltitude, 0, 0.7,
                        (value) => _arcAltitude = value),
                    _playgroundSlider('Arc width', _arcStrokeWidth, 0.5, 6,
                        (value) => _arcStrokeWidth = value),
                    _playgroundSlider('Arc duration', _arcSpeedMs, 500, 6000,
                        (value) => _arcSpeedMs = value,
                        digits: 0),
                    _playgroundSlider('Marker size', _markerSize, 2, 12,
                        (value) => _markerSize = value),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Marker pulse'),
                      value: _markerPulse,
                      onChanged: (value) =>
                          setState(() => _markerPulse = value),
                    ),
                  ],
                ),
              ],
            )));
  }

  Widget _playgroundSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> update, {
    int digits = 2,
  }) {
    return Row(children: [
      SizedBox(width: 120, child: Text(label)),
      Expanded(
          child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        label: value.toStringAsFixed(digits),
        onChanged: (next) => setState(() => update(next)),
      )),
    ]);
  }

  void _resetPlayground() {
    _controller.zoom = 1;
    setState(() {
      _selectedSkinIndex = 0;
      _activeTheme = GlobeSkins.reference;
      _autoRotate = true;
      _autoRotateSpeed = 0.22;
      _projection = GlobeProjection.perspective;
      _quality = GlobeQuality.auto;
      _radiusMultiplier = 0.82;
      _pointSize = _activeTheme.surface.pointSize;
      _pointOpacity = _activeTheme.surface.pointOpacity;
      _globeOpacity = _activeTheme.surface.globeOpacity;
      _showAtmosphere = _activeTheme.atmosphere.visible;
      _atmosphereAltitude = _activeTheme.atmosphere.altitude;
      _atmosphereGlow = _activeTheme.atmosphere.glowIntensity;
      _ambientLight = _activeTheme.lighting.ambientIntensity;
      _directionalLight = _activeTheme.lighting.directionalIntensity;
      _enableZoom = true;
      _inertiaEnabled = true;
      _rotationSensitivity = 0.005;
      _arcAltitude = 0.28;
      _arcStrokeWidth = 2;
      _arcSpeedMs = 2400;
      _markerSize = 5;
      _markerPulse = true;
    });
  }
}
