import 'dart:math';

import 'package:flutter/material.dart';

import '../models/chapter.dart';
import 'theme.dart';

/// Үлгэр бүрийн орчин: тал нутаг, говь, өвлийн ой, Алтай хангай, мангасын агуй.
/// Бүгд кодоор зурагдана (зураг файл шаардахгүй). Тал нутаг dark mode-д шөнө болно.
class SceneBackground extends StatelessWidget {
  const SceneBackground({
    super.key,
    this.scene = Scene.steppe,
    this.horizon = 0.62,
    this.child,
  });

  final Scene scene;

  /// Тэнгэрийн хаяа дэлгэцийн өндрийн хэдэн хувьд байх (0..1).
  final double horizon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final night =
        scene == Scene.steppe &&
        Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _ScenePainter(
              palette: _ScenePalette.of(scene, night: night),
              scene: scene,
              horizon: horizon.clamp(0.2, 0.92),
            ),
          ),
        ),
        ?child,
      ],
    );
  }
}

class _ScenePalette {
  const _ScenePalette({
    required this.sky,
    required this.orb,
    required this.far,
    required this.mid,
    required this.ground,
    this.stars = false,
  });

  final List<Color> sky;
  final Color orb;
  final Color far;
  final Color mid;
  final List<Color> ground;
  final bool stars;

  static _ScenePalette of(Scene scene, {required bool night}) {
    if (night) {
      return const _ScenePalette(
        sky: [
          AppColors.nightSkyTop,
          AppColors.nightSkyMid,
          AppColors.nightSkyBottom,
        ],
        orb: AppColors.moon,
        far: AppColors.nightMountainFar,
        mid: AppColors.nightMountainMid,
        ground: [
          AppColors.nightGrassLight,
          AppColors.nightGrass,
          AppColors.nightGrassDark,
        ],
        stars: true,
      );
    }
    return switch (scene) {
      Scene.steppe => const _ScenePalette(
        sky: [AppColors.skyTop, AppColors.skyMid, AppColors.sky],
        orb: AppColors.sun,
        far: AppColors.mountainFar,
        mid: AppColors.hillFar,
        ground: [AppColors.grassLight, AppColors.grass, AppColors.grassDark],
      ),
      Scene.desert => const _ScenePalette(
        sky: [Color(0xFFE2662C), Color(0xFFF4A04C), Color(0xFFFBD989)],
        orb: Color(0xFFFFF2B0),
        far: Color(0xFFD08A4C),
        mid: Color(0xFFE3A866),
        ground: [Color(0xFFF0C27A), Color(0xFFDDA05A), Color(0xFFB27236)],
      ),
      Scene.winter => const _ScenePalette(
        sky: [Color(0xFF203A5C), Color(0xFF52789E), Color(0xFFBCD3E6)],
        orb: Color(0xFFF2F6FF),
        far: Color(0xFF7D97B4),
        mid: Color(0xFF2F4E4A),
        ground: [Color(0xFFF2F7FB), Color(0xFFD6E4EE), Color(0xFFA9C1D3)],
        stars: true,
      ),
      Scene.mountain => const _ScenePalette(
        sky: [Color(0xFF14102E), Color(0xFF3B2F63), Color(0xFF9A6B8F)],
        orb: Color(0xFFFFE9B0),
        far: Color(0xFF473F6E),
        mid: Color(0xFF2B2648),
        ground: [Color(0xFF4F6B3A), Color(0xFF34502A), Color(0xFF1C2E17)],
        stars: true,
      ),
      Scene.cave => const _ScenePalette(
        sky: [Color(0xFF160B24), Color(0xFF4A182F), Color(0xFF7B2428)],
        orb: AppColors.red,
        far: Color(0xFF2B1738),
        mid: Color(0xFF1A0E24),
        ground: [Color(0xFF341C42), Color(0xFF1A0E24), Color(0xFF100718)],
      ),
    };
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.palette,
    required this.scene,
    required this.horizon,
  });

  final _ScenePalette palette;
  final Scene scene;
  final double horizon;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hy = h * horizon;
    final rnd = Random(scene.index * 31 + 7); // тогтмол (дүр зураг чичрэхгүй)

    // ---- Тэнгэр ----
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, hy + 2),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: palette.sky,
        ).createShader(Rect.fromLTWH(0, 0, w, hy)),
    );

    // ---- Од ----
    if (palette.stars) {
      final star = Paint()..color = Colors.white.withValues(alpha: 0.7);
      for (var i = 0; i < 40; i++) {
        canvas.drawCircle(
          Offset(rnd.nextDouble() * w, rnd.nextDouble() * hy * 0.7),
          rnd.nextDouble() * 1.3 + 0.3,
          star,
        );
      }
    }

    // ---- Нар / сар ----
    final orbC = Offset(w * 0.78, hy * 0.28);
    final orbR = min(w, h) * 0.065;
    canvas.drawCircle(
      orbC,
      orbR * 2.2,
      Paint()
        ..color = palette.orb.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(orbC, orbR, Paint()..color = palette.orb);

    // ---- Алс нуруу ----
    final farTop = hy - h * 0.16;
    switch (scene) {
      case Scene.mountain || Scene.winter:
        _peaks(canvas, w, hy, farTop, palette.far, snow: true);
      case Scene.cave:
        _peaks(canvas, w, hy, farTop + h * 0.04, palette.far, snow: false);
      default:
        _ridge(
          canvas,
          w,
          hy,
          farTop + h * 0.05,
          palette.far,
          waves: 3,
          amp: h * 0.035,
        );
    }

    // ---- Ойрын толгод / манхан / ой ----
    switch (scene) {
      case Scene.winter:
        _pines(canvas, w, hy, palette.mid, rnd);
      case Scene.desert:
        _ridge(
          canvas,
          w,
          hy,
          hy - h * 0.05,
          palette.mid,
          waves: 2,
          amp: h * 0.03,
        );
      default:
        _ridge(
          canvas,
          w,
          hy,
          hy - h * 0.045,
          palette.mid,
          waves: 4,
          amp: h * 0.02,
        );
    }

    // ---- Газар ----
    canvas.drawRect(
      Rect.fromLTWH(0, hy, w, h - hy),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: palette.ground,
        ).createShader(Rect.fromLTWH(0, hy, w, h - hy)),
    );
    canvas.drawLine(
      Offset(0, hy),
      Offset(w, hy),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 2,
    );

    // ---- Чимэглэл ----
    switch (scene) {
      case Scene.steppe:
        _ger(canvas, Offset(w * 0.16, hy), min(w, h) * 0.075);
      case Scene.winter:
        final flake = Paint()..color = Colors.white.withValues(alpha: 0.8);
        for (var i = 0; i < 50; i++) {
          canvas.drawCircle(
            Offset(rnd.nextDouble() * w, rnd.nextDouble() * h),
            rnd.nextDouble() * 1.8 + 0.6,
            flake,
          );
        }
      case Scene.cave:
        _stalactites(canvas, w, h * 0.12, palette.mid, rnd);
      case Scene.desert || Scene.mountain:
        break;
    }
  }

  /// Долгионтой зөөлөн нуруу.
  void _ridge(
    Canvas canvas,
    double w,
    double base,
    double top,
    Color color, {
    required int waves,
    required double amp,
  }) {
    final path = Path()..moveTo(0, base + 2);
    for (var x = 0.0; x <= w; x += w / 40) {
      final y = top + sin(x / w * pi * waves + 0.6) * amp;
      path.lineTo(x, y);
    }
    path
      ..lineTo(w, base + 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  /// Шовх оргилууд (цастай эсвэл цасгүй).
  void _peaks(
    Canvas canvas,
    double w,
    double base,
    double top,
    Color color, {
    required bool snow,
  }) {
    const xs = [0.0, 0.12, 0.27, 0.42, 0.58, 0.72, 0.88, 1.0];
    const ys = [0.6, 0.15, 0.55, 0.0, 0.5, 0.2, 0.65, 0.4];
    final span = base - top;
    final path = Path()..moveTo(0, base + 2);
    for (var i = 0; i < xs.length; i++) {
      path.lineTo(xs[i] * w, top + ys[i] * span);
    }
    path
      ..lineTo(w, base + 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    if (!snow) return;
    final cap = Paint()..color = AppColors.mountainSnow.withValues(alpha: 0.85);
    for (var i = 1; i < xs.length - 1; i++) {
      if (ys[i] > 0.25) continue; // зөвхөн өндөр оргилд цас
      final px = xs[i] * w;
      final py = top + ys[i] * span;
      final d = span * 0.18;
      canvas.drawPath(
        Path()
          ..moveTo(px, py)
          ..lineTo(px - d * 0.8, py + d)
          ..lineTo(px - d * 0.2, py + d * 0.8)
          ..lineTo(px + d * 0.3, py + d * 1.05)
          ..lineTo(px + d * 0.8, py + d)
          ..close(),
        cap,
      );
    }
  }

  /// Нарс модны эгнээ.
  void _pines(Canvas canvas, double w, double base, Color color, Random rnd) {
    final paint = Paint()..color = color;
    var x = -10.0;
    while (x < w + 20) {
      final th = 26 + rnd.nextDouble() * 26;
      final tw = th * 0.55;
      canvas.drawPath(
        Path()
          ..moveTo(x, base - th)
          ..lineTo(x - tw / 2, base + 1)
          ..lineTo(x + tw / 2, base + 1)
          ..close(),
        paint,
      );
      x += tw * (0.55 + rnd.nextDouble() * 0.5);
    }
  }

  /// Монгол гэр.
  void _ger(Canvas canvas, Offset foot, double s) {
    final body = Rect.fromLTWH(
      foot.dx - s,
      foot.dy - s * 0.75,
      s * 2,
      s * 0.75,
    );
    canvas.drawRect(body, Paint()..color = const Color(0xFFF7F1E3));
    canvas.drawPath(
      Path()
        ..moveTo(foot.dx - s * 1.1, foot.dy - s * 0.72)
        ..quadraticBezierTo(
          foot.dx,
          foot.dy - s * 1.45,
          foot.dx + s * 1.1,
          foot.dy - s * 0.72,
        )
        ..close(),
      Paint()..color = const Color(0xFFEDE3CC),
    );
    // Бүс, хаалга
    canvas.drawRect(
      Rect.fromLTWH(body.left, body.top + s * 0.2, body.width, s * 0.08),
      Paint()..color = const Color(0xFF2B4F8C),
    );
    canvas.drawRect(
      Rect.fromLTWH(foot.dx - s * 0.18, foot.dy - s * 0.48, s * 0.36, s * 0.48),
      Paint()..color = AppColors.red,
    );
    canvas.drawCircle(
      Offset(foot.dx, foot.dy - s * 1.1),
      s * 0.1,
      Paint()..color = const Color(0xFF8C6A3C),
    );
  }

  /// Агуйн таазнаас унжсан чулуу.
  void _stalactites(
    Canvas canvas,
    double w,
    double maxLen,
    Color color,
    Random rnd,
  ) {
    final paint = Paint()..color = color;
    var x = 0.0;
    while (x < w) {
      final sw = 14 + rnd.nextDouble() * 22;
      final len = maxLen * (0.35 + rnd.nextDouble() * 0.65);
      canvas.drawPath(
        Path()
          ..moveTo(x, 0)
          ..lineTo(x + sw, 0)
          ..lineTo(x + sw / 2, len)
          ..close(),
        paint,
      );
      x += sw * 0.9;
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.scene != scene || old.horizon != horizon || old.palette != palette;
}
