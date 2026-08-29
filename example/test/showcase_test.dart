import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_globe_example/main.dart';
import 'package:flutter_globe_example/benchmark.dart';

void main() {
  test('benchmark percentiles and deterministic workloads', () {
    expect(percentile([], 0.9), isNull);
    expect(percentile([4, 1, 3, 2], 0.5), 2);
    expect(percentile([4, 1, 3, 2], 0.99), 4);
    expect(BenchmarkScenario.stress.createMarkers().length, 1000);
    expect(BenchmarkScenario.dense.createArcs().length, 250);
    expect(BenchmarkScenario.typical.createLayers().single,
        isA<GlobeParticleLayer>());
    expect(BenchmarkScenario.typical.createMarkers(),
        BenchmarkScenario.typical.createMarkers());
  });

  testWidgets('showcase navigation and narrow layouts have no overflows',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const GlobeProShowcaseApp());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    for (final tab in ShowcaseTab.values) {
      final label = find.text(tab.label).first;
      await tester.ensureVisible(label);
      await tester.tap(label);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: tab.label);
    }
    expect(find.text('Run benchmark'), findsOneWidget);
    await tester.tap(find.text('Run benchmark'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Complete ·'), findsOneWidget);
    expect(find.textContaining('Unavailable'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
