import 'dart:math';

import 'package:flutter/material.dart';

import 'theme.dart';

/// Тал нутаг, Ойн зах, Мангасын агуйн дэвсгэр зураглал.
/// Dark Mode идэвхтэй үед од мичид, сартай шөнийн тал нутаг харагдана.
/// [horizon] — тэнгэр/газрын зааг (0..1, дээрээс).
/// [levelId] — 1: Тал нутаг, 2: Ойн зах, 3: Мангасын агуй.
class SteppeBackground extends StatelessWidget {
  const SteppeBackground({
    super.key,
    this.child,
    this.horizon = 0.62,
    this.showGer = true,
    this.showClouds = true,
    this.levelId = 1,
  });

  final Widget? child;
  final double horizon;
  final bool showGer;
  final bool showClouds;
  final int levelId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _SteppePainter(
        horizon: horizon,
        showGer: showGer,
        showClouds: showClouds,
        levelId: levelId,
        isDark: isDark,
      ),
      child: child ?? const SizedBox.expand(),
    );
  }
}

class _SteppePainter extends CustomPainter {
  _SteppePainter({
    required this.horizon,
    required this.showGer,
    required this.showClouds,
    required this.levelId,
    required this.isDark,
  });

  final double horizon;
  final bool showGer;
  final bool showClouds;
  final int levelId;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    switch (levelId) {
      case 2:
        _paintForest(canvas, size);
      case 3:
        _paintCave(canvas, size);
      default:
        _paintSteppe(canvas, size);
    }
    canvas.restore();
  }

  // ── 1. Тал нутаг (Өдөр ба Шөнө) ──────────────────────────────
  void _paintSteppe(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hy = h * horizon;

    _skyGradient(
      canvas,
      w,
      h,
      hy,
      isDark
          ? const [
              AppColors.nightSkyTop,
              AppColors.nightSkyMid,
              AppColors.nightSkyBottom,
            ]
          : const [AppColors.skyTop, AppColors.skyMid, AppColors.sky],
    );

    final body = Offset(w * 0.8, hy * 0.26);
    final r = max(1.0, min(w, h) * 0.068);
    if (isDark) {
      _stars(canvas, w, hy);
      _glowOrb(canvas, body, r, AppColors.moon);
    } else {
      _glowOrb(canvas, body, r, AppColors.sun);
    }

    if (showClouds) {
      _cloud(canvas, Offset(w * 0.20, hy * 0.18), w * 0.16);
      _cloud(canvas, Offset(w * 0.52, hy * 0.11), w * 0.12);
    }

    final mtnFar = isDark ? AppColors.nightMountainFar : AppColors.mountainFar;
    final mtnMid = isDark ? AppColors.nightMountainMid : AppColors.mountainMid;
    _mountain(canvas, Offset(w * 0.22, hy - h * 0.21), -w * 0.05, w * 0.52, hy, mtnFar);
    _mountain(canvas, Offset(w * 0.76, hy - h * 0.24), w * 0.42, w * 1.08, hy, mtnMid);
    _mountain(canvas, Offset(w * 0.50, hy - h * 0.16), w * 0.24, w * 0.78, hy, mtnFar);

    // Алс толгод
    final far = Path()
      ..moveTo(0, hy)
      ..quadraticBezierTo(w * 0.25, hy - h * 0.09, w * 0.52, hy - h * 0.02)
      ..quadraticBezierTo(w * 0.80, hy - h * 0.10, w, hy - h * 0.03)
      ..lineTo(w, hy + 4)
      ..lineTo(0, hy + 4)
      ..close();
    canvas.drawPath(
      far,
      Paint()..color = isDark ? AppColors.nightGrassLight : AppColors.hillFar,
    );

    // Наад талын тал
    _ground(
      canvas,
      w,
      h,
      hy,
      isDark
          ? const [AppColors.nightGrass, AppColors.nightGrassDark]
          : const [AppColors.grass, AppColors.grassDark],
    );

    if (showGer) {
      _ger(canvas, Offset(w * 0.82, hy - h * 0.02), min(w, h) * 0.052);
      _ger(canvas, Offset(w * 0.16, hy + h * 0.005), min(w, h) * 0.10);
    }
  }

  // ── 2. Ойн зах (Түвшин 2) ────────────────────────────────────
  void _paintForest(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hy = h * horizon;

    _skyGradient(
      canvas,
      w,
      h,
      hy,
      isDark
          ? const [Color(0xFF0B1924), Color(0xFF16323B), Color(0xFF234946)]
          : const [
              AppColors.forestSkyTop,
              Color(0xFF3E6B68),
              AppColors.forestSkyBottom,
            ],
    );
    if (isDark) _stars(canvas, w, hy);

    _glowOrb(
      canvas,
      Offset(w * 0.5, hy * 0.56),
      max(1.0, min(w, h) * 0.10),
      isDark ? AppColors.moon : const Color(0xFFFFCC66),
    );

    _mountain(
      canvas,
      Offset(w * 0.25, hy - h * 0.19),
      -w * 0.1,
      w * 0.6,
      hy,
      const Color(0xFF284947),
      snow: false,
    );
    _mountain(
      canvas,
      Offset(w * 0.78, hy - h * 0.21),
      w * 0.38,
      w * 1.1,
      hy,
      const Color(0xFF1F3B3A),
      snow: false,
    );

    for (var i = 0; i < 12; i++) {
      final tx = w * (i / 11.0);
      final th = h * (0.10 + (i % 3) * 0.025);
      _pine(canvas, Offset(tx, hy + 2), th, AppColors.forestTreeFar);
    }

    _ground(
      canvas,
      w,
      h,
      hy,
      const [Color(0xFF436F36), AppColors.forestGround, Color(0xFF1D3519)],
    );

    for (final x in const [0.07, 0.16, 0.85, 0.94]) {
      _pine(canvas, Offset(w * x, hy + h * 0.03), h * 0.17, AppColors.forestTreeNear);
    }
  }

  // ── 3. Мангасын агуй (Түвшин 3) ──────────────────────────────
  void _paintCave(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hy = h * horizon;

    _skyGradient(canvas, w, h, hy, const [
      AppColors.caveSkyTop,
      AppColors.caveSkyBottom,
      Color(0xFF7B2428),
    ]);

    _glowOrb(
      canvas,
      Offset(w * 0.5, hy * 0.36),
      max(1.0, min(w, h) * 0.085),
      const Color(0xFFFF6E40),
    );

    _mountain(
      canvas,
      Offset(w * 0.2, hy - h * 0.22),
      -w * 0.08,
      w * 0.52,
      hy,
      AppColors.caveRockFar,
      snow: false,
    );
    _mountain(
      canvas,
      Offset(w * 0.82, hy - h * 0.24),
      w * 0.48,
      w * 1.1,
      hy,
      AppColors.caveRockFar,
      snow: false,
    );

    // Сталактит унжлага хаднууд
    final spikes = Path()..moveTo(0, 0);
    for (final s in const [
      (0.10, 0.14),
      (0.22, 0.05),
      (0.36, 0.17),
      (0.50, 0.06),
      (0.66, 0.16),
      (0.82, 0.06),
      (0.92, 0.14),
      (1.00, 0.00),
    ]) {
      spikes.lineTo(w * s.$1, hy * s.$2);
    }
    spikes.close();
    canvas.drawPath(spikes, Paint()..color = AppColors.caveRockNear);

    _ground(canvas, w, h, hy, const [
      Color(0xFF341C42),
      AppColors.caveRockNear,
      Color(0xFF100718),
    ]);

    // Лаавын ан цав
    final crack = Path()
      ..moveTo(w * 0.36, hy + (h - hy) * 0.25)
      ..lineTo(w * 0.48, hy + (h - hy) * 0.48)
      ..lineTo(w * 0.42, hy + (h - hy) * 0.72)
      ..moveTo(w * 0.48, hy + (h - hy) * 0.48)
      ..lineTo(w * 0.64, hy + (h - hy) * 0.62);
    canvas.drawPath(
      crack,
      Paint()
        ..color = AppColors.caveLava
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Туслах функцүүд ──────────────────────────────────────────

  void _skyGradient(
    Canvas canvas,
    double w,
    double h,
    double hy,
    List<Color> colors,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(Rect.fromLTWH(0, 0, w, max(1.0, hy))),
    );
  }

  void _ground(
    Canvas canvas,
    double w,
    double h,
    double hy,
    List<Color> colors,
  ) {
    final field = Path()
      ..moveTo(0, hy)
      ..quadraticBezierTo(w * 0.3, hy - h * 0.03, w * 0.62, hy)
      ..quadraticBezierTo(w * 0.85, hy + h * 0.02, w, hy - h * 0.01)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      field,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(Rect.fromLTWH(0, hy, w, max(1.0, h - hy))),
    );
  }

  void _glowOrb(Canvas canvas, Offset center, double r, Color color) {
    canvas.drawCircle(
      center,
      r * 2.2,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.38), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: r * 2.2)),
    );
    canvas.drawCircle(center, r, Paint()..color = color);
  }

  void _stars(Canvas canvas, double w, double hy) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.8);
    for (final s in const [
      (0.10, 0.14),
      (0.24, 0.09),
      (0.36, 0.22),
      (0.48, 0.15),
      (0.62, 0.10),
      (0.70, 0.30),
      (0.90, 0.16),
    ]) {
      canvas.drawCircle(Offset(w * s.$1, hy * s.$2), 1.6, p);
    }
  }

  void _mountain(
    Canvas canvas,
    Offset peak,
    double leftX,
    double rightX,
    double baseY,
    Color color, {
    bool snow = true,
  }) {
    final mtn = Path()
      ..moveTo(leftX, baseY)
      ..lineTo(peak.dx, peak.dy)
      ..lineTo(rightX, baseY)
      ..close();
    canvas.drawPath(mtn, Paint()..color = color);

    if (snow) {
      final lx = peak.dx + (leftX - peak.dx) * 0.34;
      final rx = peak.dx + (rightX - peak.dx) * 0.34;
      final sy = peak.dy + (baseY - peak.dy) * 0.34;
      final cap = Path()
        ..moveTo(peak.dx, peak.dy)
        ..lineTo(lx, sy)
        ..lineTo(peak.dx, sy + 5)
        ..lineTo(rx, sy)
        ..close();
      canvas.drawPath(
        cap,
        Paint()
          ..color = isDark
              ? const Color(0xFFBBD4EC)
              : AppColors.mountainSnow,
      );
    }
  }

  void _pine(Canvas canvas, Offset base, double height, Color color) {
    final w = height * 0.45;
    final path = Path();
    for (var i = 0; i < 3; i++) {
      final topY = base.dy - height * (1.0 - i * 0.22);
      final botY = base.dy - height * (0.55 - i * 0.24);
      final lw = w * (0.65 + i * 0.22);
      path
        ..moveTo(base.dx, topY)
        ..lineTo(base.dx - lw / 2, botY)
        ..lineTo(base.dx + lw / 2, botY)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  void _cloud(Canvas canvas, Offset c, double width) {
    final p = Paint()
      ..color = (isDark ? const Color(0xFF324F76) : Colors.white).withValues(
        alpha: isDark ? 0.55 : 0.88,
      );
    final r = width * 0.28;
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c + Offset(r * 1.1, r * 0.18), r * 1.15, p);
    canvas.drawCircle(c + Offset(r * 2.3, r * 0.32), r * 0.85, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - r, c.dy + r * 0.2, r * 4, r * 0.9),
        Radius.circular(r * 0.45),
      ),
      p,
    );
  }

  void _ger(Canvas canvas, Offset base, double size) {
    if (size <= 0) return;
    final wallW = size * 2;
    final wallH = size * 0.88;
    final wall = Rect.fromLTWH(
      base.dx - wallW / 2,
      base.dy - wallH,
      wallW,
      wallH,
    );
    final roof = Path()
      ..moveTo(wall.left - size * 0.1, wall.top + 2)
      ..quadraticBezierTo(
        base.dx,
        wall.top - size * 1.05,
        wall.right + size * 0.1,
        wall.top + 2,
      )
      ..close();

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.tileBorder;

    canvas.drawRect(wall, Paint()..color = AppColors.cream);
    canvas.drawRect(wall, stroke);
    canvas.drawPath(roof, Paint()..color = Colors.white);
    canvas.drawPath(roof, stroke);

    // Улаан бүслүүр ба хаалга
    canvas.drawRect(
      Rect.fromLTWH(wall.left, wall.top, wallW, size * 0.13),
      Paint()..color = AppColors.red,
    );
    final door = Rect.fromCenter(
      center: Offset(base.dx, base.dy - wallH * 0.38),
      width: size * 0.52,
      height: wallH * 0.74,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, Radius.circular(size * 0.05)),
      Paint()..color = AppColors.red,
    );
    // Тооно (шөнө дулаан алтан гэрэлтэй)
    canvas.drawCircle(
      Offset(base.dx, wall.top - size * 0.44),
      size * 0.12,
      Paint()..color = isDark ? AppColors.accentLight : AppColors.tileBorder,
    );
  }

  @override
  bool shouldRepaint(_SteppePainter old) =>
      old.horizon != horizon ||
      old.showGer != showGer ||
      old.showClouds != showClouds ||
      old.levelId != levelId ||
      old.isDark != isDark;
}
