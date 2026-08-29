import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui' show FramePhase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_globe/flutter_globe.dart';

const benchmarkSeed = 1337;

/// Fixed workloads; every run uses the same seed and geographic coordinates.
enum BenchmarkScenario {
  baseline(25, 10, 0),
  typical(100, 75, 250),
  dense(500, 250, 1000),
  stress(1000, 500, 5000),
  developerExtreme(5000, 2000, 10000);

  const BenchmarkScenario(this.markers, this.arcs, this.particles);
  final int markers;
  final int arcs;
  final int particles;

  List<GlobeMarker> createMarkers() => List.generate(
      markers,
      (i) => GlobeMarker(
            coordinate: coordinate(i),
            pulse: true,
          ),
      growable: false);

  List<GlobeArc> createArcs() => List.generate(
      arcs,
      (i) => GlobeArc(
            start: coordinate(i),
            end: coordinate(i + 37),
          ),
      growable: false);

  List<GlobeLayer> createLayers() => particles == 0
      ? const <GlobeLayer>[]
      : <GlobeLayer>[
          GlobeParticleLayer(
            particleCount: particles,
            seed: benchmarkSeed,
          ),
        ];

  static GlobeCoordinate coordinate(int i) => GlobeCoordinate(
        latitude: -75.0 + (i * 17 % 150),
        longitude: -180.0 + (i * 29 % 360),
      );
}

/// Nearest-rank percentile. Empty input is unavailable, never a fabricated zero.
double? percentile(List<double> values, double fraction) {
  if (values.isEmpty) return null;
  final sorted = List<double>.of(values)..sort();
  return sorted[(fraction * sorted.length).ceil().clamp(1, sorted.length) - 1];
}

class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({super.key});
  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  BenchmarkScenario _scenario = BenchmarkScenario.typical;
  GlobeQuality _quality = GlobeQuality.medium;
  List<GlobeMarker> _markers = BenchmarkScenario.typical.createMarkers();
  List<GlobeArc> _arcs = BenchmarkScenario.typical.createArcs();
  List<GlobeLayer> _layers = BenchmarkScenario.typical.createLayers();
  final List<FrameTiming> _samples = [];
  Timer? _timer;
  int? _startUs;
  int? _endUs;
  String _phase = 'Ready';
  int _run = 0;
  double _refreshRate = 60;
  Size _viewport = Size.zero;
  bool get _running =>
      _phase == 'Warm-up' || _phase == 'Measuring' || _phase == 'Collecting';

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  void _onTimings(List<FrameTiming> timings) {
    if (_startUs == null || _endUs == null || kIsWeb) return;
    for (final timing in timings) {
      final timestamp = timing.timestampInMicroseconds(FramePhase.vsyncStart);
      if (timestamp >= _startUs! && timestamp < _endUs!) _samples.add(timing);
    }
  }

  void _start() {
    _timer?.cancel();
    setState(() {
      _samples.clear();
      _startUs = null;
      _endUs = null;
      _phase = 'Warm-up';
      _run++;
      _refreshRate = View.of(context).display.refreshRate;
    });
    _timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _startUs = Timeline.now;
        _endUs = _startUs! + 8000000;
        _phase = 'Measuring';
      });
      _timer = Timer(const Duration(seconds: 8), () {
        setState(() => _phase = 'Collecting');
        // Release builds batch timings; allow the final batch to arrive.
        _timer = Timer(const Duration(seconds: 2), () {
          setState(() => _phase = 'Complete');
        });
      });
    });
  }

  Map<String, Object?> get _result {
    final build =
        _samples.map((f) => f.buildDuration.inMicroseconds / 1000).toList();
    final raster =
        _samples.map((f) => f.rasterDuration.inMicroseconds / 1000).toList();
    final latency =
        _samples.map((f) => f.totalSpan.inMicroseconds / 1000).toList();
    final budget = 1000 / (_refreshRate > 0 ? _refreshRate : 60);
    double? mean(List<double> values) =>
        values.isEmpty ? null : values.reduce((a, b) => a + b) / values.length;
    return {
      'schemaVersion': 1,
      'packageVersion': '1.0.0',
      'seed': benchmarkSeed,
      'scenario': _scenario.name,
      'quality': _quality.name,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'buildMode':
          kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug'),
      'markers': _markers.length,
      'arcs': _arcs.length,
      'particles': _scenario.particles,
      'layers': _layers.length,
      'viewportWidth': _viewport.width,
      'viewportHeight': _viewport.height,
      'devicePixelRatio': View.of(context).devicePixelRatio,
      'refreshRateHz': _refreshRate,
      'warmupSeconds': 2,
      'measurementSeconds': 8,
      'samples': _samples.length,
      'buildMeanMs': mean(build),
      'rasterMeanMs': mean(raster),
      'latencyMeanMs': mean(latency),
      'latencyP90Ms': percentile(latency, 0.90),
      'latencyP95Ms': percentile(latency, 0.95),
      'latencyP99Ms': percentile(latency, 0.99),
      'frameBudgetMs': budget,
      'overBudgetFrames': _samples.isEmpty
          ? null
          : _samples
              .where((f) =>
                  f.buildDuration.inMicroseconds / 1000 > budget ||
                  f.rasterDuration.inMicroseconds / 1000 > budget)
              .length,
      'fps': null,
      'gpuTimeMs': null,
      'memoryBytes': null,
      'unavailableReason': kIsWeb
          ? 'Native FrameTiming metrics are not reported by this web benchmark.'
          : (_samples.isEmpty ? 'No engine timing samples received.' : null),
    };
  }

  Future<void> _copy() async {
    try {
      await Clipboard.setData(ClipboardData(
          text: const JsonEncoder.withIndent('  ').convert(_result)));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Benchmark JSON copied')));
      }
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Clipboard unavailable: ${error.code}')));
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return LayoutBuilder(builder: (context, constraints) {
      final extent = (constraints.maxWidth - 32).clamp(0.0, 480.0);
      _viewport = Size.square(extent);
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Measure your scene',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
              'Fixed coordinates · 2 s warm-up · 8 s measurement · 2 s timing collection. Keep this page visible during the run.'),
          if (kDebugMode)
            const Text(
                'Debug build: useful for checking the flow, not performance comparisons.',
                style: TextStyle(color: Colors.amber)),
          if (kIsWeb)
            const Text(
                'Web timing metrics: unavailable. Use a native profile build for engine timings.'),
          const SizedBox(height: 16),
          Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<BenchmarkScenario>(
                    value: _scenario,
                    items: BenchmarkScenario.values
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s.name)))
                        .toList(),
                    onChanged: _running
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _scenario = value;
                              _markers = value.createMarkers();
                              _arcs = value.createArcs();
                              _layers = value.createLayers();
                              _samples.clear();
                              _startUs = null;
                              _endUs = null;
                              _phase = 'Ready';
                            });
                          }),
                DropdownButton<GlobeQuality>(
                    value: _quality,
                    items: GlobeQuality.values
                        .map((q) =>
                            DropdownMenuItem(value: q, child: Text(q.name)))
                        .toList(),
                    onChanged: _running
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _quality = value;
                                _samples.clear();
                                _startUs = null;
                                _endUs = null;
                                _phase = 'Ready';
                              });
                            }
                          }),
                FilledButton.icon(
                    onPressed: _running ? null : _start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run benchmark')),
                OutlinedButton.icon(
                    onPressed: _phase == 'Complete' ? _copy : null,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy JSON')),
              ]),
          const SizedBox(height: 12),
          Text(
              '$_phase · ${_markers.length} markers · ${_arcs.length} arcs · ${_scenario.particles} particles',
              semanticsLabel: 'Benchmark phase: $_phase'),
          Center(
              child: Globe(
                  key: ValueKey((_scenario, _quality, _run)),
                  size: extent,
                  skin: GlobeSkins.reference,
                  markers: _markers,
                  arcs: _arcs,
                  layers: _layers,
                  quality: _quality,
                  interactive: false,
                  autoRotateSpeed: 0.3,
                  introAnimation: GlobeIntroAnimation.none,
                  semanticLabel: 'Deterministic benchmark globe')),
          if (_phase == 'Complete') ...[
            Text('Results · ${_samples.length} engine frames',
                style: Theme.of(context).textTheme.titleLarge),
            const Text(
                'Latency includes pipeline wait. Raster duration is not GPU execution time. Over-budget frames are not a dropped-frame count.'),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, children: [
              for (final key in [
                'buildMeanMs',
                'rasterMeanMs',
                'latencyMeanMs',
                'latencyP90Ms',
                'latencyP95Ms',
                'latencyP99Ms',
                'overBudgetFrames'
              ])
                Chip(
                    label: Text(
                        '$key: ${result[key] is double ? (result[key]! as double).toStringAsFixed(2) : result[key] ?? 'Unavailable'}')),
            ]),
            if (_samples.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Frame-time timeline',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: _FrameTimelinePainter(
                    samples: _samples,
                    budgetMs: 1000 / _refreshRate,
                  ),
                ),
              ),
            ],
          ],
        ]),
      );
    });
  }
}

class _FrameTimelinePainter extends CustomPainter {
  const _FrameTimelinePainter({required this.samples, required this.budgetMs});

  final List<FrameTiming> samples;
  final double budgetMs;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty || size.isEmpty) return;
    final values = samples
        .map((sample) => sample.totalSpan.inMicroseconds / 1000)
        .toList(growable: false);
    final maxMs = values.fold<double>(budgetMs * 2, (a, b) => a > b ? a : b);
    final thresholdPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final thresholdY = size.height * (1 - budgetMs / maxMs);
    canvas.drawLine(
        Offset(0, thresholdY), Offset(size.width, thresholdY), thresholdPaint);
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x =
          values.length == 1 ? 0.0 : size.width * index / (values.length - 1);
      final y = size.height * (1 - (values[index] / maxMs).clamp(0.0, 1.0));
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _FrameTimelinePainter oldDelegate) =>
      oldDelegate.samples != samples || oldDelegate.budgetMs != budgetMs;
}
