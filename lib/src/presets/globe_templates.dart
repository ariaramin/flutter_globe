import 'package:flutter/material.dart';
import '../layers/globe_layer.dart';
import '../layers/heatmap_layer.dart';
import '../layers/particle_layer.dart';
import '../layers/route_layer.dart';
import '../models/globe_arc.dart';
import '../models/globe_coordinate.dart';
import '../models/globe_marker.dart';
import '../themes/globe_skins.dart';
import '../themes/globe_theme.dart';

/// Predefined complete 3D globe scene templates with curated styles, markers, arcs, and layers.
class GlobeTemplate {
  /// Creates a reusable theme and geographic sample scene.
  const GlobeTemplate({
    required this.name,
    required this.description,
    required this.theme,
    this.markers = const <GlobeMarker>[],
    this.arcs = const <GlobeArc>[],
    this.layers = const <GlobeLayer>[],
    this.autoRotateSpeed = 0.85,
  });

  /// Name identifier of the template.
  final String name;

  /// Brief description of the template's use case.
  final String description;

  /// Theme and visual skin used in this template.
  final GlobeTheme theme;

  /// Preset markers.
  final List<GlobeMarker> markers;

  /// Preset arcs.
  final List<GlobeArc> arcs;

  /// Preset layers (particles, heatmaps, routes).
  final List<GlobeLayer> layers;

  /// Default auto-rotation speed.
  final double autoRotateSpeed;
}

/// Collection of ready-to-use scene templates.
class GlobeTemplates {
  const GlobeTemplates._();

  /// 1. Dark Minimalist (Monolith):
  /// Pure black globe with stark white dots, crisp silver connections, and minimalist typography.
  static final GlobeTemplate darkMinimalist = GlobeTemplate(
    name: 'Dark Minimalist',
    description:
        'High-contrast pure black globe with stark white continents and clean editorial lines.',
    theme: GlobeSkins.monolith,
    autoRotateSpeed: 0.65,
    markers: [
      GlobeMarker.latLng(
        latitude: 37.7749,
        longitude: -122.4194,
        label: 'San Francisco',
        color: const Color(0xFFFFFFFF),
      ),
      GlobeMarker.latLng(
        latitude: 51.5074,
        longitude: -0.1278,
        label: 'London',
        color: const Color(0xFFFFFFFF),
      ),
      GlobeMarker.latLng(
        latitude: 35.6762,
        longitude: 139.6503,
        label: 'Tokyo',
        color: const Color(0xFFFFFFFF),
      ),
      GlobeMarker.latLng(
        latitude: -33.8688,
        longitude: 151.2093,
        label: 'Sydney',
        color: const Color(0xFFFFFFFF),
      ),
    ],
    arcs: [
      const GlobeArc(
        start: GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
        end: GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
        color: Color(0xFFFFFFFF),
        altitude: 0.28,
        duration: Duration(milliseconds: 2400),
      ),
      const GlobeArc(
        start: GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
        end: GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
        color: Color(0xFFFFFFFF),
        altitude: 0.32,
        duration: Duration(milliseconds: 2600),
        delay: Duration(milliseconds: 400),
      ),
      const GlobeArc(
        start: GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
        end: GlobeCoordinate(latitude: -33.8688, longitude: 151.2093),
        color: Color(0xFFFFFFFF),
        altitude: 0.26,
        duration: Duration(milliseconds: 2200),
        delay: Duration(milliseconds: 800),
      ),
    ],
  );

  /// 2. Cyber Threat Map:
  /// Dark crimson skin, red/orange laser arcs with traveling comets, pulsating security beacons.
  static final GlobeTemplate cyberAttackMap = GlobeTemplate(
    name: 'Cyber Threat Map',
    description:
        'Real-time cybersecurity DDoS and intrusion monitoring with laser attack arcs.',
    theme: GlobeSkins.lava,
    autoRotateSpeed: 0.6,
    markers: [
      GlobeMarker.latLng(
        latitude: 37.7749,
        longitude: -122.4194,
        label: 'US-West SOC',
        color: const Color(0xFFEF4444),
      ),
      GlobeMarker.latLng(
        latitude: 51.5074,
        longitude: -0.1278,
        label: 'EU Hub',
        color: const Color(0xFFF97316),
      ),
      GlobeMarker.latLng(
        latitude: 35.6762,
        longitude: 139.6503,
        label: 'Tokyo Gateway',
        color: const Color(0xFFE11D48),
      ),
      GlobeMarker.latLng(
        latitude: 1.3521,
        longitude: 103.8198,
        label: 'APAC Node',
        color: const Color(0xFFFBBF24),
      ),
    ],
    arcs: [
      const GlobeArc(
        start: GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
        end: GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
        color: Color(0xFFEF4444),
        altitude: 0.38,
        duration: Duration(milliseconds: 1600),
      ),
      const GlobeArc(
        start: GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
        end: GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
        color: Color(0xFFF97316),
        altitude: 0.32,
        duration: Duration(milliseconds: 2000),
        delay: Duration(milliseconds: 400),
      ),
      const GlobeArc(
        start: GlobeCoordinate(latitude: 1.3521, longitude: 103.8198),
        end: GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
        color: Color(0xFFFBBF24),
        altitude: 0.35,
        duration: Duration(milliseconds: 2200),
        delay: Duration(milliseconds: 800),
      ),
    ],
  );

  /// 3. Aviation Flight Tracker:
  /// Classic dark navy theme with moving aircraft icons traveling along intercontinental corridors.
  static final GlobeTemplate flightTracker = GlobeTemplate(
    name: 'Aviation Flight Tracker',
    description:
        'Live multi-leg flight path visualization with animated aircraft.',
    theme: GlobeSkins.classic,
    autoRotateSpeed: 0.75,
    markers: [
      GlobeMarker.latLng(
        latitude: 40.7128,
        longitude: -74.0060,
        label: 'JFK',
        color: const Color(0xFF38BDF8),
      ),
      GlobeMarker.latLng(
        latitude: 51.5074,
        longitude: -0.1278,
        label: 'LHR',
        color: const Color(0xFF34D399),
      ),
      GlobeMarker.latLng(
        latitude: 25.2048,
        longitude: 55.2708,
        label: 'DXB',
        color: const Color(0xFFFBBF24),
      ),
      GlobeMarker.latLng(
        latitude: 1.3521,
        longitude: 103.8198,
        label: 'SIN',
        color: const Color(0xFFA78BFA),
      ),
      GlobeMarker.latLng(
        latitude: -33.8688,
        longitude: 151.2093,
        label: 'SYD',
        color: const Color(0xFF2DD4BF),
      ),
    ],
    layers: const [
      GlobeRouteLayer(
        routes: [
          GlobeRoute(
            waypoints: [
              GlobeCoordinate(latitude: 40.7128, longitude: -74.0060),
              GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
              GlobeCoordinate(latitude: 25.2048, longitude: 55.2708),
              GlobeCoordinate(latitude: 1.3521, longitude: 103.8198),
              GlobeCoordinate(latitude: -33.8688, longitude: 151.2093),
            ],
            color: Color(0xFF38BDF8),
            altitude: 0.32,
            duration: Duration(milliseconds: 10000),
          ),
        ],
        movingObjects: [
          GlobeMovingObject(
            route: GlobeRoute(
              waypoints: [
                GlobeCoordinate(latitude: 40.7128, longitude: -74.0060),
                GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
                GlobeCoordinate(latitude: 25.2048, longitude: 55.2708),
                GlobeCoordinate(latitude: 1.3521, longitude: 103.8198),
                GlobeCoordinate(latitude: -33.8688, longitude: 151.2093),
              ],
              altitude: 0.32,
              duration: Duration(milliseconds: 10000),
            ),
            type: GlobeVehicleType.airplane,
            color: Colors.white,
            size: 16.0,
          ),
        ],
      ),
    ],
  );

  /// 4. Satellite Constellation Tracker:
  /// LEO satellite orbits, ground relay stations, and communications links.
  static final GlobeTemplate satelliteTracker = GlobeTemplate(
    name: 'Satellite Constellation',
    description:
        'Low Earth Orbit satellite network with active telemetry links.',
    theme: GlobeSkins.deepSpace,
    autoRotateSpeed: 0.5,
    markers: [
      GlobeMarker.latLng(
          latitude: 28.5729, longitude: -80.6490, label: 'KSC Ground Station'),
      GlobeMarker.latLng(
          latitude: -31.8688, longitude: 115.8605, label: 'Perth Downlink'),
      GlobeMarker.latLng(
          latitude: 78.2232,
          longitude: 15.6267,
          label: 'Svalbard Polar Station'),
    ],
    layers: [
      GlobeParticleLayer(particleCount: 50),
      const GlobeRouteLayer(
        routes: [
          GlobeRoute(
            waypoints: [
              GlobeCoordinate(latitude: 65.0, longitude: -170.0),
              GlobeCoordinate(latitude: 0.0, longitude: -100.0),
              GlobeCoordinate(latitude: -65.0, longitude: -30.0),
              GlobeCoordinate(latitude: 0.0, longitude: 40.0),
              GlobeCoordinate(latitude: 65.0, longitude: 110.0),
            ],
            color: Color(0xFF60A5FA),
            altitude: 0.45,
            duration: Duration(milliseconds: 8000),
          ),
        ],
        movingObjects: [
          GlobeMovingObject(
            route: GlobeRoute(
              waypoints: [
                GlobeCoordinate(latitude: 65.0, longitude: -170.0),
                GlobeCoordinate(latitude: 0.0, longitude: -100.0),
                GlobeCoordinate(latitude: -65.0, longitude: -30.0),
                GlobeCoordinate(latitude: 0.0, longitude: 40.0),
                GlobeCoordinate(latitude: 65.0, longitude: 110.0),
              ],
              altitude: 0.45,
              duration: Duration(milliseconds: 8000),
            ),
            type: GlobeVehicleType.satellite,
            color: Color(0xFF38BDF8),
            size: 18.0,
          ),
        ],
      ),
    ],
  );

  /// 5. Global Cloud Mesh & Network:
  /// Cyberpunk neon blue and purple data pipes connecting primary data center regions.
  static final GlobeTemplate globalNetwork = GlobeTemplate(
    name: 'Cloud Infrastructure',
    description:
        'High-speed data routes and multi-region cloud mesh visualization.',
    theme: GlobeSkins.cyberpunk,
    autoRotateSpeed: 0.85,
    markers: [
      GlobeMarker.latLng(
          latitude: 37.7749, longitude: -122.4194, label: 'us-west1'),
      GlobeMarker.latLng(
          latitude: 40.7128, longitude: -74.0060, label: 'us-east1'),
      GlobeMarker.latLng(
          latitude: 50.1109, longitude: 8.6821, label: 'europe-west3'),
      GlobeMarker.latLng(
          latitude: 35.6762, longitude: 139.6503, label: 'asia-northeast1'),
      GlobeMarker.latLng(
          latitude: 1.3521, longitude: 103.8198, label: 'asia-southeast1'),
      GlobeMarker.latLng(
          latitude: -33.8688,
          longitude: 151.2093,
          label: 'australia-southeast1'),
    ],
    arcs: [
      const GlobeArc(
        start: GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
        end: GlobeCoordinate(latitude: 40.7128, longitude: -74.0060),
        color: Color(0xFF06B6D4),
        altitude: 0.22,
        duration: Duration(milliseconds: 1800),
      ),
      const GlobeArc(
        start: GlobeCoordinate(latitude: 40.7128, longitude: -74.0060),
        end: GlobeCoordinate(latitude: 50.1109, longitude: 8.6821),
        color: Color(0xFF8B5CF6),
        altitude: 0.32,
        duration: Duration(milliseconds: 2200),
        delay: Duration(milliseconds: 300),
      ),
      const GlobeArc(
        start: GlobeCoordinate(latitude: 50.1109, longitude: 8.6821),
        end: GlobeCoordinate(latitude: 1.3521, longitude: 103.8198),
        color: Color(0xFFEC4899),
        altitude: 0.34,
        duration: Duration(milliseconds: 2400),
        delay: Duration(milliseconds: 600),
      ),
      const GlobeArc(
        start: GlobeCoordinate(latitude: 1.3521, longitude: 103.8198),
        end: GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
        color: Color(0xFF22D3EE),
        altitude: 0.25,
        duration: Duration(milliseconds: 1900),
        delay: Duration(milliseconds: 900),
      ),
    ],
    layers: [
      GlobeParticleLayer(particleCount: 30),
    ],
  );

  /// 6. Decentralized Crypto Nodes:
  /// Matrix terminal phosphor green and gold theme showing validator node syncs.
  static final GlobeTemplate cryptoNetwork = GlobeTemplate(
    name: 'Blockchain Nodes',
    description:
        'Decentralized P2P validator network and transaction propagation.',
    theme: GlobeSkins.matrix,
    autoRotateSpeed: 0.9,
    markers: [
      GlobeMarker.latLng(
          latitude: 47.3769, longitude: 8.5417, label: 'Zurich Validator'),
      GlobeMarker.latLng(
          latitude: 37.7749, longitude: -122.4194, label: 'SF Node'),
      GlobeMarker.latLng(
          latitude: 1.3521, longitude: 103.8198, label: 'Singapore Validator'),
      GlobeMarker.latLng(
          latitude: 35.6762, longitude: 139.6503, label: 'Tokyo Node'),
    ],
    arcs: [
      const GlobeArc(
        start: GlobeCoordinate(latitude: 47.3769, longitude: 8.5417),
        end: GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
        color: Color(0xFF00FF66),
        altitude: 0.34,
        duration: Duration(milliseconds: 1500),
      ),
      const GlobeArc(
        start: GlobeCoordinate(latitude: 47.3769, longitude: 8.5417),
        end: GlobeCoordinate(latitude: 1.3521, longitude: 103.8198),
        color: Color(0xFF34D399),
        altitude: 0.30,
        duration: Duration(milliseconds: 1700),
        delay: Duration(milliseconds: 250),
      ),
    ],
  );

  /// 7. Global Sales & Activity Heatmap:
  /// Emerald aurora theme featuring geographic density heat points.
  static final GlobeTemplate globalSales = GlobeTemplate(
    name: 'Global Sales Activity',
    description: 'Data-driven revenue density heatmaps and activity beacons.',
    theme: GlobeSkins.aurora,
    autoRotateSpeed: 0.7,
    markers: [
      GlobeMarker.latLng(
          latitude: 37.7749, longitude: -122.4194, label: r'$4.2M SF'),
      GlobeMarker.latLng(
          latitude: 51.5074, longitude: -0.1278, label: r'$3.8M London'),
      GlobeMarker.latLng(
          latitude: 35.6762, longitude: 139.6503, label: r'$5.1M Tokyo'),
    ],
    layers: const [
      GlobeHeatmapLayer(
        points: [
          GlobeHeatPoint(
            coordinate:
                GlobeCoordinate(latitude: 37.7749, longitude: -122.4194),
            intensity: 0.95,
            radius: 36.0,
          ),
          GlobeHeatPoint(
            coordinate: GlobeCoordinate(latitude: 40.7128, longitude: -74.0060),
            intensity: 0.9,
            radius: 32.0,
          ),
          GlobeHeatPoint(
            coordinate: GlobeCoordinate(latitude: 51.5074, longitude: -0.1278),
            intensity: 0.85,
            radius: 34.0,
          ),
          GlobeHeatPoint(
            coordinate: GlobeCoordinate(latitude: 35.6762, longitude: 139.6503),
            intensity: 1.0,
            radius: 40.0,
          ),
        ],
      ),
    ],
  );

  /// 8. Maritime Shipping Corridors:
  /// Deep oceanic trade lanes across Malacca, Suez, Panama, and Gibraltar.
  static final GlobeTemplate maritimeFleet = GlobeTemplate(
    name: 'Maritime Corridors',
    description:
        'Commercial shipping lanes and vessel tracking across global maritime straits.',
    theme: GlobeSkins.ocean,
    autoRotateSpeed: 0.7,
    markers: [
      GlobeMarker.latLng(
          latitude: 1.290270,
          longitude: 103.851959,
          label: 'Strait of Malacca'),
      GlobeMarker.latLng(
          latitude: 29.9753, longitude: 32.5599, label: 'Suez Canal'),
      GlobeMarker.latLng(
          latitude: 9.1012, longitude: -79.6955, label: 'Panama Canal'),
      GlobeMarker.latLng(
          latitude: 35.9620, longitude: -5.6037, label: 'Strait of Gibraltar'),
    ],
    arcs: [
      const GlobeArc(
        start: GlobeCoordinate(latitude: 1.290270, longitude: 103.851959),
        end: GlobeCoordinate(latitude: 29.9753, longitude: 32.5599),
        color: Color(0xFF14B8A6),
        altitude: 0.26,
        duration: Duration(milliseconds: 3200),
      ),
      const GlobeArc(
        start: GlobeCoordinate(latitude: 29.9753, longitude: 32.5599),
        end: GlobeCoordinate(latitude: 35.9620, longitude: -5.6037),
        color: Color(0xFF2DD4BF),
        altitude: 0.22,
        duration: Duration(milliseconds: 2400),
        delay: Duration(milliseconds: 400),
      ),
      const GlobeArc(
        start: GlobeCoordinate(latitude: 35.9620, longitude: -5.6037),
        end: GlobeCoordinate(latitude: 9.1012, longitude: -79.6955),
        color: Color(0xFF5EEAD4),
        altitude: 0.35,
        duration: Duration(milliseconds: 3600),
        delay: Duration(milliseconds: 800),
      ),
    ],
  );

  /// List of all built-in templates.
  static final List<GlobeTemplate> all = [
    darkMinimalist,
    cyberAttackMap,
    flightTracker,
    satelliteTracker,
    globalNetwork,
    cryptoNetwork,
    globalSales,
    maritimeFleet,
  ];
}
