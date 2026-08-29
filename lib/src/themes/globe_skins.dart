import 'package:flutter/material.dart';
import '../math/vector3.dart';
import 'globe_style_models.dart';
import 'globe_theme.dart';

/// Predefined visual skins and color palettes for the 3D globe.
///
/// Contains 24 dotted-surface palettes with distinct color, atmosphere, and grid tokens.
class GlobeSkins {
  const GlobeSkins._();

  /// 1. Reference: Blue atmospheric halo and slate land dots.
  /// Features deep void sphere background, radiant sky-blue atmospheric halo,
  /// slate-gray land dots with directional lighting, and glowing cyan accents.
  static const GlobeTheme reference = GlobeTheme(
    accentColor: Color(0xFF38BDF8),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF030712),
      landColor: Color(0xFF94A3B8),
      pointSize: 1.65,
      pointOpacity: 0.95,
      rearPointOpacity: 0.0,
      globeOpacity: 1.0,
    ),
    atmosphere: GlobeAtmosphereStyle(
      visible: true,
      color: Color(0xFF0284C7),
      altitude: 0.22,
      glowIntensity: 0.75,
      innerShadowIntensity: 0.45,
    ),
    lighting: GlobeLightingStyle(
      ambientIntensity: 0.35,
      directionalIntensity: 0.65,
      lightDirection: Vector3D(-0.4, -0.4, 0.9),
    ),
  );

  /// 2. Classic: Clean blue atmosphere with muted slate continent dots.
  static const GlobeTheme classic = GlobeTheme(
    accentColor: Color(0xFF38BDF8),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF070B14),
      landColor: Color(0xFF9CA3AF),
      pointSize: 1.65,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF0284C7),
      altitude: 0.22,
      glowIntensity: 0.75,
    ),
  );

  /// 3. Minimal: Subtle slate aesthetic with muted atmosphere for clean minimal UIs.
  static const GlobeTheme minimal = GlobeTheme(
    accentColor: Color(0xFF94A3B8),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF090D16),
      landColor: Color(0xFF64748B),
      pointSize: 1.5,
      pointOpacity: 0.85,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF475569),
      altitude: 0.16,
      glowIntensity: 0.4,
    ),
    lighting: GlobeLightingStyle(
      ambientIntensity: 0.5,
      directionalIntensity: 0.5,
    ),
  );

  /// 4. Midnight: Deep midnight violet void with neon purple and lilac points.
  static const GlobeTheme midnight = GlobeTheme(
    accentColor: Color(0xFFA855F7),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF0C071E),
      landColor: Color(0xFFD8B4FE),
      pointSize: 1.65,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF7C3AED),
      altitude: 0.22,
      glowIntensity: 0.7,
    ),
  );

  /// 5. Cyberpunk: High-voltage neon cyan continents, hot pink arcs, and violet haze.
  static const GlobeTheme cyberpunk = GlobeTheme(
    accentColor: Color(0xFF06B6D4),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF050515),
      landColor: Color(0xFF22D3EE),
      pointSize: 1.75,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF8B5CF6),
      secondaryGlowColor: Color(0xFFEC4899),
      altitude: 0.25,
      glowIntensity: 0.85,
    ),
  );

  /// 6. Hologram: Translucent futuristic sci-fi hologram with cyan scanlines and graticule.
  static const GlobeTheme hologram = GlobeTheme(
    accentColor: Color(0xFF38BDF8),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0x1A0284C7),
      landColor: Color(0xFF7DD3FC),
      pointSize: 1.5,
      globeOpacity: 0.85,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF0EA5E9),
      altitude: 0.26,
      glowIntensity: 0.9,
    ),
    grid: GlobeGridStyle(
      visible: true,
      color: Color(0x3338BDF8),
      equatorColor: Color(0x6638BDF8),
    ),
  );

  /// 7. Neon: Pitch-black core with electric emerald green and luminous lime highlights.
  static const GlobeTheme neon = GlobeTheme(
    accentColor: Color(0xFF10B981),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF02130A),
      landColor: Color(0xFF34D399),
      pointSize: 1.7,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF059669),
      altitude: 0.22,
      glowIntensity: 0.8,
    ),
  );

  /// 8. Blueprint: Architectural CAD drafting aesthetic on cobalt blue canvas.
  static const GlobeTheme blueprint = GlobeTheme(
    accentColor: Color(0xFF60A5FA),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF1E3A8A),
      landColor: Color(0xFFDBEAFE),
      pointSize: 1.6,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF3B82F6),
      altitude: 0.16,
      glowIntensity: 0.5,
    ),
    grid: GlobeGridStyle(
      visible: true,
      color: Color(0x40FFFFFF),
      strokeWidth: 0.9,
    ),
  );

  /// 9. Glass: Frosted translucent glass sphere with subtle specular rim highlights.
  static const GlobeTheme glass = GlobeTheme(
    accentColor: Color(0xFFE2E8F0),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0x26FFFFFF),
      landColor: Color(0xCCFFFFFF),
      pointSize: 1.55,
      globeOpacity: 0.6,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0x66FFFFFF),
      altitude: 0.18,
      glowIntensity: 0.4,
    ),
  );

  /// 10. Terminal: CRT retro monochrome radar screen with phosphor green scan.
  static const GlobeTheme terminal = GlobeTheme(
    accentColor: Color(0xFF22C55E),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF031A0B),
      landColor: Color(0xFF4ADE80),
      pointSize: 1.8,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF16A34A),
      altitude: 0.2,
      glowIntensity: 0.75,
    ),
    grid: GlobeGridStyle(
      visible: true,
      color: Color(0x3322C55E),
    ),
  );

  /// 11. Space: Deep cosmic void with brilliant diamond star dots and cobalt aura.
  static const GlobeTheme space = GlobeTheme(
    accentColor: Color(0xFF818CF8),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF03071E),
      landColor: Color(0xFFA5B4FC),
      pointSize: 1.65,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF4F46E5),
      altitude: 0.24,
      glowIntensity: 0.7,
    ),
  );

  /// 12. Ocean: Deep sea teal and aquamarine reefs.
  static const GlobeTheme ocean = GlobeTheme(
    accentColor: Color(0xFF14B8A6),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF04202C),
      landColor: Color(0xFF5EEAD4),
      pointSize: 1.7,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF0D9488),
      altitude: 0.22,
      glowIntensity: 0.7,
    ),
  );

  /// 13. Aurora: Scandinavian northern lights with emerald and turquoise waves.
  static const GlobeTheme aurora = GlobeTheme(
    accentColor: Color(0xFF2DD4BF),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF031B1E),
      landColor: Color(0xFF67E8F9),
      pointSize: 1.7,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF06B6D4),
      secondaryGlowColor: Color(0xFF10B981),
      altitude: 0.25,
      glowIntensity: 0.85,
    ),
  );

  /// 14. Sunset: Warm twilight gold, amber, and fiery crimson.
  static const GlobeTheme sunset = GlobeTheme(
    accentColor: Color(0xFFF59E0B),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF1F0B0B),
      landColor: Color(0xFFFDBA74),
      pointSize: 1.75,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFFEA580C),
      altitude: 0.23,
      glowIntensity: 0.8,
    ),
  );

  /// 15. Ice: Glacial frost and crystalline blue polar ice cap appearance.
  static const GlobeTheme ice = GlobeTheme(
    accentColor: Color(0xFFBAE6FD),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF0B192C),
      landColor: Color(0xFFE0F2FE),
      pointSize: 1.6,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF7DD3FC),
      altitude: 0.22,
      glowIntensity: 0.65,
    ),
  );

  /// 16. Lava: Obsidian crust with glowing volcanic magma arcs.
  static const GlobeTheme lava = GlobeTheme(
    accentColor: Color(0xFFEF4444),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF160606),
      landColor: Color(0xFFF87171),
      pointSize: 1.8,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFFDC2626),
      altitude: 0.24,
      glowIntensity: 0.85,
    ),
  );

  /// 17. Monochrome: High-contrast minimalist black & white editorial style.
  static const GlobeTheme monochrome = GlobeTheme(
    accentColor: Color(0xFFFFFFFF),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF121212),
      landColor: Color(0xFFAAAAAA),
      pointSize: 1.6,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0x55FFFFFF),
      altitude: 0.15,
      glowIntensity: 0.4,
    ),
  );

  /// 18. Retro: 1980s synthwave sunset aesthetic with glowing wireframes.
  static const GlobeTheme retro = GlobeTheme(
    accentColor: Color(0xFFF43F5E),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF18052E),
      landColor: Color(0xFFFB7185),
      pointSize: 1.7,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFFD946EF),
      altitude: 0.25,
      glowIntensity: 0.85,
    ),
    grid: GlobeGridStyle(
      visible: true,
      color: Color(0x33F43F5E),
    ),
  );

  /// 19. Wireframe: Pure spherical coordinate wireframe mesh with graticule lines.
  static const GlobeTheme wireframe = GlobeTheme(
    accentColor: Color(0xFF38BDF8),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF030712),
      landColor: Color(0xFF0284C7),
      pointSize: 1.4,
      globeOpacity: 0.9,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF0EA5E9),
      altitude: 0.2,
      glowIntensity: 0.6,
    ),
    grid: GlobeGridStyle(
      visible: true,
      color: Color(0x4D38BDF8),
      strokeWidth: 1.0,
      latitudeInterval: 15.0,
      longitudeInterval: 15.0,
      equatorColor: Color(0x9938BDF8),
    ),
  );

  /// 20. Point Cloud: Dense volumetric 3D point cloud with depth fading.
  static const GlobeTheme pointCloud = GlobeTheme(
    accentColor: Color(0xFF00E5FF),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF020617),
      landColor: Color(0xFFE2E8F0),
      pointSize: 1.8,
      pointOpacity: 1.0,
      rearPointOpacity: 0.25,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF00B0FF),
      altitude: 0.24,
      glowIntensity: 0.8,
    ),
    lighting: GlobeLightingStyle(
      ambientIntensity: 0.5,
      directionalIntensity: 0.5,
    ),
  );

  /// 21. Monolith (Stark Dark): Pure pitch-black sphere with stark white land dots.
  static const GlobeTheme monolith = GlobeTheme(
    accentColor: Color(0xFFFFFFFF),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF000000),
      landColor: Color(0xFFFFFFFF),
      pointSize: 1.65,
      pointOpacity: 1.0,
      globeOpacity: 1.0,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0x33FFFFFF),
      altitude: 0.14,
      glowIntensity: 0.35,
    ),
    lighting: GlobeLightingStyle(
      ambientIntensity: 0.45,
      directionalIntensity: 0.55,
    ),
  );

  /// 22. Light: Clean daylight theme with slate continents for light-mode interfaces.
  static const GlobeTheme light = GlobeTheme(
    accentColor: Color(0xFF2563EB),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFFF8FAFC),
      landColor: Color(0xFF475569),
      pointSize: 1.6,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF93C5FD),
      altitude: 0.18,
      glowIntensity: 0.45,
    ),
  );

  /// 23. Realistic Earth: True natural satellite view with oceanic deep blue,
  /// lush continent vegetation green, and realistic daylight atmosphere.
  static const GlobeTheme realistic = GlobeTheme(
    accentColor: Color(0xFF38BDF8),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF0B2545),
      landColor: Color(0xFF40916C),
      pointSize: 1.7,
      pointOpacity: 0.98,
      globeOpacity: 1.0,
    ),
    atmosphere: GlobeAtmosphereStyle(
      visible: true,
      color: Color(0xFF60A5FA),
      altitude: 0.20,
      glowIntensity: 0.70,
      innerShadowIntensity: 0.40,
    ),
    lighting: GlobeLightingStyle(
      ambientIntensity: 0.38,
      directionalIntensity: 0.70,
      lightDirection: Vector3D(-0.5, -0.4, 0.85),
    ),
  );

  /// 24. Topographic: Natural terrestrial terrain with coastal blues and warm savannah tones.
  static const GlobeTheme topographic = GlobeTheme(
    accentColor: Color(0xFFF59E0B),
    surface: GlobeSurfaceStyle(
      surfaceColor: Color(0xFF0F3A5D),
      landColor: Color(0xFFD97706),
      pointSize: 1.65,
      pointOpacity: 0.95,
    ),
    atmosphere: GlobeAtmosphereStyle(
      color: Color(0xFF38BDF8),
      altitude: 0.18,
      glowIntensity: 0.60,
    ),
    lighting: GlobeLightingStyle(
      ambientIntensity: 0.40,
      directionalIntensity: 0.65,
    ),
  );

  /// Alias for realistic satellite Earth skin.
  static const GlobeTheme earth = realistic;
  static const GlobeTheme satellite = realistic;

  /// Alias for terminal radar phosphor green skin.
  static const GlobeTheme matrix = terminal;

  /// Alias for cosmic space skin.
  static const GlobeTheme deepSpace = space;

  /// List of all built-in skin themes.
  static const List<GlobeTheme> all = [
    reference,
    realistic,
    topographic,
    classic,
    minimal,
    midnight,
    cyberpunk,
    hologram,
    neon,
    blueprint,
    glass,
    terminal,
    space,
    ocean,
    aurora,
    sunset,
    ice,
    lava,
    monochrome,
    retro,
    wireframe,
    pointCloud,
    monolith,
    light,
  ];

  /// Map of skin identifiers to themes.
  static const Map<String, GlobeTheme> named = {
    'reference': reference,
    'realistic': realistic,
    'earth': earth,
    'satellite': satellite,
    'topographic': topographic,
    'classic': classic,
    'minimal': minimal,
    'midnight': midnight,
    'cyberpunk': cyberpunk,
    'hologram': hologram,
    'neon': neon,
    'blueprint': blueprint,
    'glass': glass,
    'terminal': terminal,
    'space': space,
    'ocean': ocean,
    'aurora': aurora,
    'sunset': sunset,
    'ice': ice,
    'lava': lava,
    'monochrome': monochrome,
    'retro': retro,
    'wireframe': wireframe,
    'pointCloud': pointCloud,
    'monolith': monolith,
    'light': light,
  };
}
