import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../math/vector3.dart';
import '../themes/globe_style_models.dart';
import 'globe_layer.dart';

/// Renders deterministic procedural particles orbiting the globe.
class GlobeParticleLayer extends GlobeLayer {
  /// Creates deterministic particles using a fixed seed. Reuse this instance.
  GlobeParticleLayer({
    super.enabled = true,
    super.zIndex = 30,
    this.particleCount = 45,
    this.seed = 42,
    this.color = const Color(0xFF38BDF8),
    this.speed = 1.0,
  })  : assert(particleCount >= 0),
        assert(speed > -double.infinity && speed < double.infinity),
        _particles = _generateParticles(particleCount, seed);

  /// Number of seeded particles; keep small on constrained devices.
  final int particleCount;

  /// Seed used to reproduce the same particle field.
  final int seed;

  /// Primary color for this visual component.
  final Color color;

  /// Multiplier applied to the particle scene clock.
  final double speed;
  final List<_Particle> _particles;

  static List<_Particle> _generateParticles(int count, int seed) {
    final rand = math.Random(seed);
    final list = <_Particle>[];

    for (var i = 0; i < count; i++) {
      final theta = rand.nextDouble() * 2.0 * math.pi;
      final phi = (rand.nextDouble() - 0.5) * math.pi;
      final elevation = 1.05 + rand.nextDouble() * 0.35;
      final orbitSpeed =
          (0.2 + rand.nextDouble() * 0.8) * (rand.nextBool() ? 1.0 : -1.0);
      final size = 1.0 + rand.nextDouble() * 2.2;

      list.add(_Particle(
        basePosition: Vector3D.fromSpherical(phi, theta, elevation),
        orbitSpeed: orbitSpeed,
        size: size,
        phase: rand.nextDouble() * 2.0 * math.pi,
      ));
    }
    return list;
  }

  @override
  void paint(GlobeRenderContext context) {
    final Paint paint = Paint()..isAntiAlias = true;

    final canvas = context.canvas;
    final camera = context.camera;
    final rotation = context.rotation;
    final timeSec = (context.animationTimeMs * 0.001) * speed;

    final qx = rotation.x;
    final qy = rotation.y;
    final qz = rotation.z;
    final qw = rotation.w;

    final stride = switch (context.quality) {
      GlobeQuality.low => 4,
      GlobeQuality.medium => 2,
      GlobeQuality.high || GlobeQuality.ultra => 1,
      GlobeQuality.auto => 2,
    };
    for (var i = 0; i < _particles.length; i += stride) {
      final p = _particles[i];
      // Rotate particle around Y axis according to its orbit speed
      final currentAngle = timeSec * p.orbitSpeed;
      final cosA = math.cos(currentAngle);
      final sinA = math.sin(currentAngle);

      final pos = p.basePosition;
      final vx = pos.x * cosA + pos.z * sinA;
      final vy = pos.y;
      final vz = -pos.x * sinA + pos.z * cosA;

      // Inline quaternion rotation (0 allocations)
      final tx = 2.0 * (qy * vz - qz * vy);
      final ty = 2.0 * (qz * vx - qx * vz);
      final tz = 2.0 * (qx * vy - qy * vx);

      final rx = vx + qw * tx + (qy * tz - qz * ty);
      final ry = vy + qw * ty + (qz * tx - qx * tz);
      final rz = vz + qw * tz + (qx * ty - qy * tx);

      // Occlusion
      if (rz < -0.05) continue;

      final limbAlpha = ((rz + 0.05) / 0.2).clamp(0.0, 1.0);
      final twinkle = 0.6 + 0.4 * math.sin(timeSec * 3.0 + p.phase);
      final alpha = (limbAlpha * twinkle).clamp(0.0, 1.0);

      if (alpha <= 0.01) continue;

      final (px, py, scale, _) = camera.projectCoordinates(rx, ry, rz);
      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(px, py), p.size * scale, paint);
    }
  }
}

class _Particle {
  const _Particle({
    required this.basePosition,
    required this.orbitSpeed,
    required this.size,
    required this.phase,
  });

  final Vector3D basePosition;
  final double orbitSpeed;
  final double size;
  final double phase;
}
