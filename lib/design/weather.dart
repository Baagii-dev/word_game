import 'dart:math';

import 'package:flutter/material.dart';

import '../models/chapter.dart';

/// Үлгэрийн хуудас дээгүүрх цаг агаар: тал — бороо, говь — элс,
/// өвөл — цас, уул — салхи, агуй — гал оч. Хуудасны дэвсгэрийг амьд болгоно.
class WeatherOverlay extends StatefulWidget {
  const WeatherOverlay({super.key, required this.scene});

  final Scene scene;

  @override
  State<WeatherOverlay> createState() => _WeatherOverlayState();
}

class _WeatherOverlayState extends State<WeatherOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  late final List<_Particle> _particles = _make(widget.scene);

  static List<_Particle> _make(Scene scene) {
    final r = Random(scene.index + 11);
    final n = switch (scene) {
      Scene.steppe => 70,
      Scene.winter => 60,
      Scene.desert => 45,
      Scene.mountain => 30,
      Scene.cave => 35,
    };
    return List.generate(
      n,
      (_) => _Particle(
        x: r.nextDouble(),
        y: r.nextDouble(),
        speed: 0.6 + r.nextDouble() * 0.8,
        size: 0.5 + r.nextDouble(),
        phase: r.nextDouble() * pi * 2,
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _WeatherPainter(
            scene: widget.scene,
            particles: _particles,
            time: _c,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.phase,
  });

  final double x, y, speed, size, phase;
}

class _WeatherPainter extends CustomPainter {
  _WeatherPainter({
    required this.scene,
    required this.particles,
    required this.time,
  }) : super(repaint: time);

  final Scene scene;
  final List<_Particle> particles;
  final Animation<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final w = size.width, h = size.height;
    double wrap(double v) => v - v.floorToDouble();

    for (final p in particles) {
      switch (scene) {
        case Scene.steppe: // ташуу бороо
          final y = wrap(p.y + t * 3 * p.speed) * h;
          final x = wrap(p.x - t * 0.6 * p.speed) * w;
          canvas.drawLine(
            Offset(x, y),
            Offset(x - 5, y + 14 * p.size),
            Paint()
              ..color = const Color(0x55FFF8E1)
              ..strokeWidth = 1.2
              ..strokeCap = StrokeCap.round,
          );
        case Scene.winter: // ганхаж унах цас
          final y = wrap(p.y + t * 0.8 * p.speed) * h;
          final x = wrap(p.x + sin(t * pi * 4 + p.phase) * 0.02) * w;
          canvas.drawCircle(
            Offset(x, y),
            1.5 + p.size * 1.5,
            Paint()..color = const Color(0xCCFFFFFF),
          );
        case Scene.desert: // хажуу тийш нисэх элс
          final x = wrap(p.x + t * 1.5 * p.speed) * w;
          final y = (p.y + sin(t * pi * 6 + p.phase) * 0.01) * h;
          canvas.drawCircle(
            Offset(x, y),
            0.8 + p.size,
            Paint()..color = const Color(0x88C7863D),
          );
        case Scene.mountain: // салхины зураас
          final x = wrap(p.x + t * 2 * p.speed) * w;
          final y = p.y * h;
          canvas.drawLine(
            Offset(x, y),
            Offset(x + 22 * p.size, y),
            Paint()
              ..color = const Color(0x33FFFFFF)
              ..strokeWidth = 1.4
              ..strokeCap = StrokeCap.round,
          );
        case Scene.cave: // дээш хөөрөх гал оч
          final y = wrap(p.y - t * 0.9 * p.speed) * h;
          final x = wrap(p.x + sin(t * pi * 3 + p.phase) * 0.015) * w;
          canvas.drawCircle(
            Offset(x, y),
            1 + p.size,
            Paint()
              ..color = Color.lerp(
                const Color(0xCCFFB300),
                const Color(0x00FF5722),
                1 - y / h,
              )!,
          );
      }
    }
  }

  @override
  bool shouldRepaint(_WeatherPainter old) => old.scene != scene;
}
