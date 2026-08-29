import 'package:flutter/material.dart';
import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Globe Theme Lerp & Transition Tests', () {
    test('GlobeTheme.lerp smoothly interpolates between two distinct themes',
        () {
      const a = GlobeSkins.reference;
      const b = GlobeSkins.cyberpunk;

      final mid = GlobeTheme.lerp(a, b, 0.5);

      expect(mid.surface.pointSize,
          closeTo((a.surface.pointSize + b.surface.pointSize) / 2, 0.01));
      expect(mid.atmosphere.altitude,
          closeTo((a.atmosphere.altitude + b.atmosphere.altitude) / 2, 0.01));
      expect(
          mid.atmosphere.glowIntensity,
          closeTo((a.atmosphere.glowIntensity + b.atmosphere.glowIntensity) / 2,
              0.01));
    });

    test('GlobeTheme.lerp handles boundary t values (0.0 and 1.0)', () {
      const a = GlobeSkins.hologram;
      const b = GlobeSkins.terminal;

      final start = GlobeTheme.lerp(a, b, 0.0);
      final end = GlobeTheme.lerp(a, b, 1.0);

      expect(start.surface.pointSize, closeTo(a.surface.pointSize, 0.01));
      expect(end.surface.pointSize, closeTo(b.surface.pointSize, 0.01));
    });

    testWidgets('GlobeThemeTransition animates theme change smoothly',
        (tester) async {
      const current = GlobeSkins.classic;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return GlobeThemeTransition(
                  theme: current,
                  duration: const Duration(milliseconds: 300),
                  builder: (context, interpolated) {
                    return SizedBox(
                      width: 200,
                      height: 200,
                      child: Globe(
                        theme: interpolated,
                        introAnimation: GlobeIntroAnimation.none,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(Globe), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(Globe), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(Globe), findsOneWidget);
    });
  });
}
