import 'dart:math';

import 'package:flutter/material.dart';

import 'theme.dart';

/// Тал нутаг, Ойн зах, Мангасын агуйн баялаг дэвсгэр зураглал.
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
    return CustomPaint(
      painter: _SteppePainter(
        horizon: horizon,
        showGer: showGer,
        showClouds: showClouds,
        levelId: levelId,
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
  });

  final double horizon;
  final bool showGer;
  final bool showClouds;
  final int levelId;

  @override
  void paint(Canvas canvas, Size size) {
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

  // ══════════════════════════════════════════════════════════════
  //  1. ТАЛ НУТАГ (Default / Түвшин 1)
  // ══════════════════════════════════════════════════════════════
  void _paintSteppe(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hy = h * horizon;

    // 1. Тэнгэрийн олон давхаргат градиент
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.skyTop,
            AppColors.skyMid,
            AppColors.sky,
            Color(0xFFE8F6FF),
          ],
          stops: [0.0, 0.45, 0.85, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, hy)),
    );

    // 2. Нар ба цацраг
    final sun = Offset(w * 0.8, hy * 0.26);
    final sunR = min(w, h) * 0.068;
    for (final factor in [3.2, 2.1, 1.4]) {
      canvas.drawCircle(
        sun,
        sunR * factor,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.sun.withValues(alpha: 0.35 / factor),
              AppColors.accent.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: sun, radius: sunR * factor)),
      );
    }
    canvas.drawCircle(sun, sunR, Paint()..color = AppColors.sun);
    canvas.drawCircle(
      sun - Offset(sunR * 0.2, sunR * 0.2),
      sunR * 0.65,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );

    // 3. Үүлс ба шувууд
    if (showClouds) {
      _cloud(canvas, Offset(w * 0.18, hy * 0.18), w * 0.17);
      _cloud(canvas, Offset(w * 0.52, hy * 0.11), w * 0.13);
      _cloud(canvas, Offset(w * 0.86, hy * 0.42), w * 0.11);
      _bird(canvas, Offset(w * 0.38, hy * 0.28), min(w, h) * 0.018);
      _bird(canvas, Offset(w * 0.42, hy * 0.25), min(w, h) * 0.014);
      _bird(canvas, Offset(w * 0.45, hy * 0.29), min(w, h) * 0.012);
    }

    // 4. Цаст уулс (алсын сүрлэг уулс)
    _snowMountain(
      canvas,
      peak: Offset(w * 0.22, hy - h * 0.22),
      left: Offset(-w * 0.05, hy),
      right: Offset(w * 0.52, hy),
      color: AppColors.mountainFar,
    );
    _snowMountain(
      canvas,
      peak: Offset(w * 0.76, hy - h * 0.25),
      left: Offset(w * 0.42, hy),
      right: Offset(w * 1.08, hy),
      color: AppColors.mountainMid,
    );
    _snowMountain(
      canvas,
      peak: Offset(w * 0.5, hy - h * 0.17),
      left: Offset(w * 0.24, hy),
      right: Offset(w * 0.78, hy),
      color: Color.lerp(AppColors.mountainMid, AppColors.mountainFar, 0.4)!,
    );

    // 5. Алс толгод
    final farHills = Path()
      ..moveTo(0, hy)
      ..quadraticBezierTo(w * 0.22, hy - h * 0.10, w * 0.52, hy - h * 0.025)
      ..quadraticBezierTo(w * 0.80, hy - h * 0.11, w, hy - h * 0.035)
      ..lineTo(w, hy + 4)
      ..lineTo(0, hy + 4)
      ..close();
    canvas.drawPath(
      farHills,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.grassLight, AppColors.hillFar],
        ).createShader(Rect.fromLTWH(0, hy - h * 0.11, w, h * 0.12)),
    );

    // 6. Дунд толгод
    final midHills = Path()
      ..moveTo(0, hy - h * 0.01)
      ..quadraticBezierTo(w * 0.35, hy - h * 0.06, w * 0.68, hy - h * 0.005)
      ..quadraticBezierTo(w * 0.88, hy + h * 0.02, w, hy - h * 0.02)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(midHills, Paint()..color = AppColors.grass);

    // 7. Наад талын ногоон тал
    final field = Path()
      ..moveTo(0, hy + h * 0.015)
      ..quadraticBezierTo(w * 0.3, hy - h * 0.025, w * 0.62, hy + h * 0.01)
      ..quadraticBezierTo(w * 0.85, hy + h * 0.03, w, hy)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      field,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.grassLight, AppColors.grass, AppColors.grassDark],
          stops: [0.0, 0.35, 1.0],
        ).createShader(Rect.fromLTWH(0, hy - h * 0.03, w, h - hy + h * 0.03)),
    );

    // Талын зөрөг зам / гэрэлт судал
    final road = Path()
      ..moveTo(w * 0.48, hy + h * 0.01)
      ..quadraticBezierTo(w * 0.35, hy + (h - hy) * 0.45, w * 0.56, h)
      ..lineTo(w * 0.72, h)
      ..quadraticBezierTo(w * 0.46, hy + (h - hy) * 0.45, w * 0.53, hy + h * 0.01)
      ..close();
    canvas.drawPath(
      road,
      Paint()..color = AppColors.tile.withValues(alpha: 0.16),
    );

    // 8. Өвс, цэцэгс
    _paintGrassAndFlowers(canvas, size, hy);

    // 9. Монгол гэр (алсын жижиг гэр + наад талын том гэр)
    if (showGer) {
      _ger(
        canvas,
        Offset(w * 0.82, hy - h * 0.025),
        min(w, h) * 0.055,
        withSmoke: false,
      );
      _ger(
        canvas,
        Offset(w * 0.16, hy + h * 0.005),
        min(w, h) * 0.105,
        withSmoke: true,
      );
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  2. ОЙН ЗАХ (Түвшин 2)
  // ══════════════════════════════════════════════════════════════
  void _paintForest(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hy = h * horizon;

    // Үдшийн улбар-номин тэнгэр
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.forestSkyTop,
            Color(0xFF3E6B68),
            AppColors.forestSkyBottom,
            Color(0xFFF6C27A),
          ],
          stops: [0.0, 0.45, 0.82, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, hy)),
    );

    // Жаргаж буй том нар
    final sun = Offset(w * 0.5, hy * 0.58);
    final sunR = min(w, h) * 0.11;
    canvas.drawCircle(
      sun,
      sunR * 1.9,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFB74D).withValues(alpha: 0.45),
            const Color(0xFFFFB74D).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: sun, radius: sunR * 1.9)),
    );
    canvas.drawCircle(
      sun,
      sunR,
      Paint()..color = const Color(0xFFFFCC66).withValues(alpha: 0.9),
    );

    // Алсын бараан уулс
    _snowMountain(
      canvas,
      peak: Offset(w * 0.25, hy - h * 0.20),
      left: Offset(-w * 0.1, hy),
      right: Offset(w * 0.6, hy),
      color: const Color(0xFF284947),
      hasSnow: false,
    );
    _snowMountain(
      canvas,
      peak: Offset(w * 0.78, hy - h * 0.22),
      left: Offset(w * 0.38, hy),
      right: Offset(w * 1.1, hy),
      color: const Color(0xFF1F3B3A),
      hasSnow: false,
    );

    // Алсын гацуур модон ой
    for (int i = 0; i < 14; i++) {
      final tx = w * (i / 13.0);
      final th = h * (0.11 + (i % 3) * 0.025);
      _pineTree(canvas, Offset(tx, hy + 2), th, AppColors.forestTreeFar);
    }

    // Ойн хөрс, нуга
    final ground = Path()
      ..moveTo(0, hy)
      ..quadraticBezierTo(w * 0.35, hy - h * 0.03, w * 0.7, hy + h * 0.01)
      ..quadraticBezierTo(w * 0.9, hy + h * 0.02, w, hy - h * 0.01)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      ground,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF436F36),
            AppColors.forestGround,
            Color(0xFF1D3519),
          ],
        ).createShader(Rect.fromLTWH(0, hy, w, h - hy)),
    );

    // Хоёр хажуугийн том гацуур моднууд
    for (final xRatio in [0.06, 0.15, 0.86, 0.95]) {
      final th = h * (xRatio < 0.1 || xRatio > 0.9 ? 0.20 : 0.15);
      _pineTree(
        canvas,
        Offset(w * xRatio, hy + h * 0.03),
        th,
        AppColors.forestTreeNear,
      );
    }

    // Гэрэлт цохнууд (fireflies)
    final glow = Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.75);
    for (final pt in const [
      Offset(0.18, 0.42),
      Offset(0.32, 0.55),
      Offset(0.68, 0.48),
      Offset(0.82, 0.36),
      Offset(0.45, 0.72),
      Offset(0.75, 0.68),
    ]) {
      canvas.drawCircle(Offset(w * pt.dx, h * pt.dy), 2.5, glow);
    }

    _paintGrassAndFlowers(canvas, size, hy, isForest: true);
  }

  // ══════════════════════════════════════════════════════════════
  //  3. МАНГАСЫН АГУЙ (Түвшин 3)
  // ══════════════════════════════════════════════════════════════
  void _paintCave(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hy = h * horizon;

    // Харанхуй улаан-хүрэн агуйн дэвсгэр
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.caveSkyTop,
            AppColors.caveSkyBottom,
            Color(0xFF7B2428),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, hy)),
    );

    // Улаан сар / шидэт талст гэрэл
    final orb = Offset(w * 0.5, hy * 0.36);
    final orbR = min(w, h) * 0.09;
    canvas.drawCircle(
      orb,
      orbR * 2.2,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.caveLava.withValues(alpha: 0.4),
            AppColors.caveLava.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: orb, radius: orbR * 2.2)),
    );
    canvas.drawCircle(
      orb,
      orbR,
      Paint()..color = const Color(0xFFFF6E40).withValues(alpha: 0.85),
    );

    // Арзгар хадан уулс
    _snowMountain(
      canvas,
      peak: Offset(w * 0.2, hy - h * 0.24),
      left: Offset(-w * 0.08, hy),
      right: Offset(w * 0.52, hy),
      color: AppColors.caveRockFar,
      hasSnow: false,
    );
    _snowMountain(
      canvas,
      peak: Offset(w * 0.82, hy - h * 0.26),
      left: Offset(w * 0.48, hy),
      right: Offset(w * 1.1, hy),
      color: AppColors.caveRockFar,
      hasSnow: false,
    );

    // Дээрээс унжсан сталактит хаднууд
    final stalactites = Path()..moveTo(0, 0);
    const spikes = [
      (0.08, 0.14),
      (0.16, 0.05),
      (0.24, 0.18),
      (0.35, 0.06),
      (0.50, 0.12),
      (0.65, 0.05),
      (0.76, 0.19),
      (0.86, 0.07),
      (0.94, 0.15),
      (1.0, 0.0),
    ];
    for (final s in spikes) {
      stalactites.lineTo(w * s.$1, hy * s.$2);
    }
    stalactites
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(stalactites, Paint()..color = AppColors.caveRockNear);

    // Агуйн чулуун шал
    final floor = Path()
      ..moveTo(0, hy)
      ..lineTo(w * 0.28, hy - h * 0.025)
      ..lineTo(w * 0.55, hy + h * 0.01)
      ..lineTo(w * 0.82, hy - h * 0.02)
      ..lineTo(w, hy)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      floor,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF341C42),
            AppColors.caveRockNear,
            Color(0xFF100718),
          ],
        ).createShader(Rect.fromLTWH(0, hy, w, h - hy)),
    );

    // Халуун лаавын ан цав ба оч
    final lavaPaint = Paint()
      ..color = AppColors.caveLava
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final crack = Path()
      ..moveTo(w * 0.35, hy + (h - hy) * 0.25)
      ..lineTo(w * 0.48, hy + (h - hy) * 0.45)
      ..lineTo(w * 0.42, hy + (h - hy) * 0.72)
      ..moveTo(w * 0.48, hy + (h - hy) * 0.45)
      ..lineTo(w * 0.64, hy + (h - hy) * 0.60);
    canvas.drawPath(
      crack,
      Paint()
        ..color = AppColors.caveLava.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    canvas.drawPath(crack, lavaPaint);

    // Хөвж буй галын оч
    final ember = Paint()..color = const Color(0xFFFFAB40);
    for (final pt in const [
      Offset(0.15, 0.52),
      Offset(0.28, 0.38),
      Offset(0.55, 0.48),
      Offset(0.72, 0.40),
      Offset(0.85, 0.55),
    ]) {
      canvas.drawCircle(Offset(w * pt.dx, h * pt.dy), 2.2, ember);
    }
  }

  // ── Туслах дүрсүүд ───────────────────────────────────────────

  void _snowMountain(
    Canvas canvas, {
    required Offset peak,
    required Offset left,
    required Offset right,
    required Color color,
    bool hasSnow = true,
  }) {
    final midX = peak.dx + (right.dx - left.dx) * 0.04;
    final baseY = left.dy;

    // Үндсэн уул
    final mtn = Path()
      ..moveTo(left.dx, baseY)
      ..lineTo(peak.dx, peak.dy)
      ..lineTo(right.dx, baseY)
      ..close();
    canvas.drawPath(mtn, Paint()..color = color);

    // Сүүдэртэй баруун тал
    final shadowSide = Path()
      ..moveTo(peak.dx, peak.dy)
      ..lineTo(midX, baseY)
      ..lineTo(right.dx, baseY)
      ..close();
    canvas.drawPath(
      shadowSide,
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );

    // Цаст оргил
    if (hasSnow) {
      final snowH = (baseY - peak.dy) * 0.34;
      final snowLeft = Offset.lerp(peak, left, 0.34)!;
      final snowRight = Offset.lerp(peak, right, 0.34)!;
      final snow = Path()
        ..moveTo(peak.dx, peak.dy)
        ..lineTo(snowLeft.dx, snowLeft.dy)
        ..lineTo(peak.dx - (peak.dx - snowLeft.dx) * 0.35, peak.dy + snowH * 0.78)
        ..lineTo(peak.dx, peak.dy + snowH * 1.05)
        ..lineTo(peak.dx + (snowRight.dx - peak.dx) * 0.4, peak.dy + snowH * 0.8)
        ..lineTo(snowRight.dx, snowRight.dy)
        ..close();
      canvas.drawPath(snow, Paint()..color = AppColors.mountainSnow);
    }
  }

  void _pineTree(Canvas canvas, Offset base, double height, Color color) {
    final w = height * 0.46;
    final path = Path();
    for (int layer = 0; layer < 3; layer++) {
      final topY = base.dy - height * (1.0 - layer * 0.22);
      final botY = base.dy - height * (0.55 - layer * 0.24);
      final lw = w * (0.65 + layer * 0.22);
      path
        ..moveTo(base.dx, topY)
        ..lineTo(base.dx - lw / 2, botY)
        ..lineTo(base.dx + lw / 2, botY)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  void _paintGrassAndFlowers(
    Canvas canvas,
    Size size,
    double hy, {
    bool isForest = false,
  }) {
    final w = size.width;
    final h = size.height;
    final span = h - hy;
    if (span <= 8) return;

    final grassPaint = Paint()
      ..color = isForest
          ? const Color(0xFF568B44)
          : AppColors.grassDark.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    const tufts = [
      (0.10, 0.25),
      (0.24, 0.55),
      (0.38, 0.32),
      (0.62, 0.48),
      (0.76, 0.28),
      (0.88, 0.62),
    ];
    for (final t in tufts) {
      final gx = w * t.$1;
      final gy = hy + span * t.$2;
      canvas.drawLine(Offset(gx, gy), Offset(gx - 4, gy - 7), grassPaint);
      canvas.drawLine(Offset(gx, gy), Offset(gx + 1, gy - 9), grassPaint);
      canvas.drawLine(Offset(gx, gy), Offset(gx + 5, gy - 6), grassPaint);
      if (!isForest) {
        canvas.drawCircle(
          Offset(gx + 1, gy - 10),
          2.0,
          Paint()..color = AppColors.sun,
        );
      }
    }
  }

  void _bird(Canvas canvas, Offset c, double s) {
    final p = Paint()
      ..color = AppColors.navyDark.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(c.dx - s, c.dy)
      ..quadraticBezierTo(c.dx - s * 0.4, c.dy - s * 0.6, c.dx, c.dy - s * 0.1)
      ..quadraticBezierTo(c.dx + s * 0.4, c.dy - s * 0.6, c.dx + s, c.dy);
    canvas.drawPath(path, p);
  }

  void _cloud(Canvas canvas, Offset c, double width) {
    final shadow = Paint()
      ..color = AppColors.skyTop.withValues(alpha: 0.18);
    final p = Paint()..color = Colors.white.withValues(alpha: 0.92);
    final r = width * 0.28;

    // Үүлний доод зөөлөн сүүдэр
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - r, c.dy + r * 0.32, r * 4, r * 0.9),
        Radius.circular(r * 0.45),
      ),
      shadow,
    );

    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c + Offset(r * 1.1, r * 0.15), r * 1.2, p);
    canvas.drawCircle(c + Offset(r * 2.3, r * 0.32), r * 0.88, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - r, c.dy + r * 0.2, r * 4, r * 0.9),
        Radius.circular(r * 0.45),
      ),
      p,
    );
  }

  /// Монгол гэр: ханын тор, бүслүүр, унь, тооно, хээтэй хаалга, яндангийн утаа.
  void _ger(
    Canvas canvas,
    Offset base,
    double size, {
    required bool withSmoke,
  }) {
    final wallW = size * 2.1;
    final wallH = size * 0.88;
    final wall = Rect.fromLTWH(
      base.dx - wallW / 2,
      base.dy - wallH,
      wallW,
      wallH,
    );

    // Газар дээрх сүүдэр
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(base.dx, base.dy + size * 0.04),
        width: wallW * 1.15,
        height: size * 0.28,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );

    // Яндангийн утаа
    if (withSmoke) {
      final smokePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(base.dx + size * 0.15, wall.top - size * 0.78),
        size * 0.12,
        smokePaint,
      );
      canvas.drawCircle(
        Offset(base.dx + size * 0.28, wall.top - size * 1.02),
        size * 0.16,
        smokePaint,
      );
      canvas.drawCircle(
        Offset(base.dx + size * 0.44, wall.top - size * 1.28),
        size * 0.20,
        Paint()..color = Colors.white.withValues(alpha: 0.28),
      );
    }

    // Дээвэр (бөмбөгөр эсгий)
    final roof = Path()
      ..moveTo(wall.left - size * 0.1, wall.top + 2)
      ..quadraticBezierTo(
        base.dx,
        wall.top - size * 1.05,
        wall.right + size * 0.1,
        wall.top + 2,
      )
      ..close();

    // Хана
    canvas.drawRRect(
      RRect.fromRectAndRadius(wall, Radius.circular(size * 0.06)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.cream, Colors.white, AppColors.tile],
        ).createShader(wall),
    );

    // Ханын ташуу тор (хана)
    final latticePaint = Paint()
      ..color = AppColors.tileBorder.withValues(alpha: 0.22)
      ..strokeWidth = 1.0;
    canvas.save();
    canvas.clipRect(wall);
    for (double dx = -wallH; dx < wallW + wallH; dx += size * 0.28) {
      canvas.drawLine(
        Offset(wall.left + dx, wall.top),
        Offset(wall.left + dx - wallH * 0.6, wall.bottom),
        latticePaint,
      );
      canvas.drawLine(
        Offset(wall.left + dx, wall.top),
        Offset(wall.left + dx + wallH * 0.6, wall.bottom),
        latticePaint,
      );
    }
    canvas.restore();

    // Ханын хүрээ ба бүслүүр
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = AppColors.tileBorder;
    canvas.drawRRect(
      RRect.fromRectAndRadius(wall, Radius.circular(size * 0.06)),
      stroke,
    );

    // Дээвэр зурах
    canvas.drawPath(
      roof,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, AppColors.cream],
        ).createShader(
          Rect.fromLTWH(wall.left, wall.top - size, wallW, size),
        ),
    );

    // Унийн зураас
    final crownCenter = Offset(base.dx, wall.top - size * 0.48);
    for (final ratio in [-0.7, -0.35, 0.0, 0.35, 0.7]) {
      canvas.drawLine(
        crownCenter,
        Offset(base.dx + (wallW / 2) * ratio, wall.top + 1),
        Paint()
          ..color = AppColors.tileBorder.withValues(alpha: 0.35)
          ..strokeWidth = 1.1,
      );
    }
    canvas.drawPath(roof, stroke);

    // Хялгасан бүслүүр (улаан хээтэй тууз)
    canvas.drawRect(
      Rect.fromLTWH(wall.left, wall.top, wallW, size * 0.13),
      Paint()..color = AppColors.red,
    );
    canvas.drawLine(
      Offset(wall.left, wall.top + size * 0.42),
      Offset(wall.right, wall.top + size * 0.42),
      Paint()
        ..color = AppColors.tileBorder
        ..strokeWidth = 1.4,
    );

    // Тооно (оройн алтан/улаан титэм)
    final toono = Path()
      ..moveTo(base.dx - size * 0.32, wall.top - size * 0.42)
      ..quadraticBezierTo(
        base.dx,
        wall.top - size * 0.68,
        base.dx + size * 0.32,
        wall.top - size * 0.42,
      )
      ..close();
    canvas.drawPath(toono, Paint()..color = AppColors.red);
    canvas.drawPath(toono, stroke);

    // Гоёмсог хаалга
    final door = Rect.fromCenter(
      center: Offset(base.dx, base.dy - wallH * 0.38),
      width: size * 0.54,
      height: wallH * 0.76,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, Radius.circular(size * 0.06)),
      Paint()..color = AppColors.red,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, Radius.circular(size * 0.06)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = AppColors.accent,
    );
    // Хаалганы алтан цагираг/хээ
    canvas.drawCircle(
      door.center,
      size * 0.08,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.accent,
    );
  }

  @override
  bool shouldRepaint(_SteppePainter old) =>
      old.horizon != horizon ||
      old.showGer != showGer ||
      old.showClouds != showClouds ||
      old.levelId != levelId;
}
