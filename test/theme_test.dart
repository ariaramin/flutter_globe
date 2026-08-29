import 'package:flutter/material.dart';
import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Globe Skins & Theming Tests', () {
    test('all built-in skins are valid and distinct', () {
      expect(GlobeSkins.all.length, greaterThanOrEqualTo(24));
      expect(GlobeSkins.named.containsKey('realistic'), isTrue);
      expect(GlobeSkins.named.containsKey('earth'), isTrue);
      expect(GlobeSkins.named.containsKey('topographic'), isTrue);

      for (final skin in GlobeSkins.all) {
        expect(skin.surface.pointSize, greaterThan(0.0));
        expect(skin.atmosphere.altitude, greaterThan(0.0));
        expect(skin.accentColor, isNotNull);
      }
    });

    test('GlobeTheme copyWith maintains immutability and overrides properties',
        () {
      const base = GlobeSkins.cyberpunk;
      final modified = base.copyWith(
        accentColor: Colors.amber,
        atmosphere: base.atmosphere.copyWith(
          glowIntensity: 0.99,
        ),
      );

      expect(modified.accentColor, equals(Colors.amber));
      expect(modified.atmosphere.glowIntensity, closeTo(0.99, 1e-5));
      expect(modified.surface, equals(base.surface));
      expect(base.accentColor, isNot(equals(Colors.amber)));
    });

    test('GlobeSurfaceStyle copyWith overrides properties', () {
      const surface = GlobeSurfaceStyle(
        pointSize: 1.5,
      );

      final modified = surface.copyWith(
        pointSize: 2.0,
      );

      expect(modified.pointSize, equals(2.0));
      expect(surface.pointSize, equals(1.5));
    });

    test('GlobeAtmosphereStyle copyWith overrides properties', () {
      const atmosphere = GlobeAtmosphereStyle(
        altitude: 0.2,
      );

      final modified = atmosphere.copyWith(
        altitude: 0.35,
        visible: false,
      );

      expect(modified.altitude, equals(0.35));
      expect(modified.visible, isFalse);
    });
  });
}
