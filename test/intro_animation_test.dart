import 'package:flutter/material.dart';
import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('short intro delays finish finitely and equality includes timing', () {
    const intro = GlobeIntroAnimation(duration: Duration(milliseconds: 200));
    expect(intro.computeAtmosphereProgress(1), 1);
    expect(intro.computeAutoRotateBlend(1), 1);
    expect(intro.copyWith(markerDelay: Duration.zero), isNot(intro));
    expect(
        intro.copyWith(autoRotateOnComplete: false).computeAutoRotateBlend(1),
        0);
  });

  group('GlobeIntroAnimation Tests', () {
    test('default configuration uses the reference-inspired timeline', () {
      const intro = GlobeIntroAnimations.reference;
      expect(intro.enabled, isTrue);
      expect(intro.duration, equals(const Duration(milliseconds: 1400)));
      expect(intro.scaleFrom, closeTo(0.72, 0.001));
      expect(intro.opacityFrom, closeTo(0.0, 0.001));
      expect(intro.atmosphereDelay, equals(const Duration(milliseconds: 200)));
      expect(intro.markerDelay, equals(const Duration(milliseconds: 400)));
      expect(intro.arcDelay, equals(const Duration(milliseconds: 600)));
      expect(intro.autoRotateDelay, equals(const Duration(milliseconds: 900)));
    });

    test('GlobeIntroAnimation.none has zero duration and starts at full scale',
        () {
      const none = GlobeIntroAnimation.none;
      expect(none.enabled, isFalse);
      expect(none.computeScale(0.0), equals(1.0));
      expect(none.computeOpacity(0.0), equals(1.0));
      expect(none.computeAtmosphereProgress(0.0), equals(1.0));
      expect(none.computeMarkerProgress(0.0), equals(1.0));
      expect(none.computeArcProgress(0.0), equals(1.0));
      expect(none.computeAutoRotateBlend(0.0), equals(1.0));
    });

    test('computeScale stages smoothly from scaleFrom through overshoot to 1.0',
        () {
      const intro = GlobeIntroAnimations.reference;
      final s0 = intro.computeScale(0.0);
      final sMid = intro.computeScale(0.5);
      final sPeak = intro.computeScale(0.75);
      final sEnd = intro.computeScale(1.0);

      expect(s0, closeTo(0.72, 0.01));
      expect(sMid, greaterThan(s0));
      expect(sPeak, greaterThanOrEqualTo(1.0)); // overshoot
      expect(sEnd, closeTo(1.0, 0.01));
    });

    test('computeOpacity reaches full opacity before final completion', () {
      const intro = GlobeIntroAnimations.reference;
      final op0 = intro.computeOpacity(0.0);
      final opMid = intro.computeOpacity(0.4);
      final opFull = intro.computeOpacity(0.7);

      expect(op0, closeTo(0.0, 0.01));
      expect(opMid, greaterThan(0.5));
      expect(opFull, closeTo(1.0, 0.01));
    });

    test('computeAtmosphereProgress respects atmosphereDelay', () {
      const intro = GlobeIntroAnimations.reference;
      // atmosphereDelay is 200ms of 1400ms = 0.1428
      expect(intro.computeAtmosphereProgress(0.1), equals(0.0));
      expect(intro.computeAtmosphereProgress(0.5), greaterThan(0.0));
      expect(intro.computeAtmosphereProgress(1.0), closeTo(1.0, 0.01));
    });

    test('computeMarkerProgress respects markerDelay and staggering', () {
      const intro = GlobeIntroAnimations.reference;
      // markerDelay is 400ms of 1400ms = ~0.285
      expect(intro.computeMarkerProgress(0.2, 0), equals(0.0));
      expect(intro.computeMarkerProgress(0.6, 0), greaterThan(0.0));
      // Staggered index 2 has higher delay than index 0
      final m0 = intro.computeMarkerProgress(0.4, 0);
      final m2 = intro.computeMarkerProgress(0.4, 2);
      expect(m0, greaterThanOrEqualTo(m2));
    });

    test('computeArcProgress respects arcDelay and staggering', () {
      const intro = GlobeIntroAnimations.reference;
      // arcDelay is 600ms of 1400ms = ~0.428
      expect(intro.computeArcProgress(0.3, 0), equals(0.0));
      expect(intro.computeArcProgress(0.8, 0), greaterThan(0.0));
      expect(intro.computeArcProgress(1.0, 0), closeTo(1.0, 0.01));
    });

    test('computeAutoRotateBlend engages after autoRotateDelay', () {
      const intro = GlobeIntroAnimations.reference;
      // autoRotateDelay is 900ms of 1400ms = ~0.642
      expect(intro.computeAutoRotateBlend(0.5), equals(0.0));
      expect(intro.computeAutoRotateBlend(0.85), greaterThan(0.0));
      expect(intro.computeAutoRotateBlend(1.0), closeTo(1.0, 0.01));
    });

    testWidgets('Globe widget mounts with intro animation without exceptions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Globe(
                  introAnimation: GlobeIntroAnimations.reference,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Globe), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(Globe), findsOneWidget);
    });
  });
}
