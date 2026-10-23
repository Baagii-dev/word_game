import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Тал нутгийн дэвсгэр: тэнгэр, нар, үүл, толгод, (сонголтоор) гэр.
/// [horizon] — тэнгэр/талын зааг (0..1, дээрээс).
class SteppeBackground extends StatelessWidget {
  const SteppeBackground({
    super.key,
    this.child,
    this.horizon = 0.62,
    this.showGer = true,
    this.showClouds = true,
  });

  final Widget? child;
  final double horizon;
  final bool showGer;
  final bool showClouds;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SteppePainter(
        horizon: horizon,
        showGer: showGer,
        showClouds: showClouds,
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
  });

  final double horizon;
  final bool showGer;
  final bool showClouds;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hy = h * horizon;

    // Тэнгэр
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.skyTop, AppColors.sky],
        ).createShader(Rect.fromLTWH(0, 0, w, hy)),
    );

    // Нар
    final sun = Offset(w * 0.8, hy * 0.28);
    final sunR = min(w, h) * 0.07;
    canvas.drawCircle(
      sun,
      sunR * 2.2,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.45),
            AppColors.accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: sun, radius: sunR * 2.2)),
    );
    canvas.drawCircle(sun, sunR, Paint()..color = const Color(0xFFFFD66B));

    // Үүл
    if (showClouds) {
      _cloud(canvas, Offset(w * 0.22, hy * 0.2), w * 0.16);
      _cloud(canvas, Offset(w * 0.5, hy * 0.1), w * 0.12);
    }

    // Алс толгод
    final far = Path()
      ..moveTo(0, hy)
      ..quadraticBezierTo(w * 0.25, hy - h * 0.09, w * 0.5, hy - h * 0.02)
      ..quadraticBezierTo(w * 0.78, hy - h * 0.1, w, hy - h * 0.03)
      ..lineTo(w, hy + 2)
      ..close();
    canvas.drawPath(far, Paint()..color = const Color(0xFF8DB85A));

    // Тал (урд талын нуга)
    final field = Path()
      ..moveTo(0, hy)
      ..quadraticBezierTo(w * 0.3, hy - h * 0.035, w * 0.6, hy)
      ..quadraticBezierTo(w * 0.85, hy + h * 0.02, w, hy - h * 0.01)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      field,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.grass, AppColors.grassDark],
        ).createShader(Rect.fromLTWH(0, hy - h * 0.03, w, h - hy + h * 0.03)),
    );

    if (showGer) {
      _ger(canvas, Offset(w * 0.14, hy - h * 0.012), min(w, h) * 0.1);
    }
  }

  void _cloud(Canvas canvas, Offset c, double width) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final r = width * 0.28;
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c + Offset(r * 1.1, r * 0.2), r * 1.15, p);
    canvas.drawCircle(c + Offset(r * 2.3, r * 0.35), r * 0.85, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - r, c.dy + r * 0.2, r * 4, r * 0.9),
        Radius.circular(r * 0.45),
      ),
      p,
    );
  }

  /// Гэр: цагаан хана, цагаан дээвэр, улаан хаалга, титэм.
  void _ger(Canvas canvas, Offset base, double size) {
    final wallW = size * 2;
    final wallH = size * 0.9;
    final wall = Rect.fromLTWH(
      base.dx - wallW / 2,
      base.dy - wallH,
      wallW,
      wallH,
    );
    final roof = Path()
      ..moveTo(wall.left - size * 0.12, wall.top + 2)
      ..quadraticBezierTo(
        base.dx,
        wall.top - size * 1.1,
        wall.right + size * 0.12,
        wall.top + 2,
      )
      ..close();
    canvas.drawRect(wall, Paint()..color = AppColors.cream);
    canvas.drawRect(
      wall,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.tileBorder,
    );
    canvas.drawPath(roof, Paint()..color = Colors.white);
    canvas.drawPath(
      roof,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.tileBorder,
    );
    // Улаан зурвас (ханын дээд)
    canvas.drawRect(
      Rect.fromLTWH(wall.left, wall.top, wallW, size * 0.12),
      Paint()..color = AppColors.red,
    );
    // Хаалга
    final door = Rect.fromCenter(
      center: Offset(base.dx, base.dy - wallH * 0.36),
      width: size * 0.5,
      height: wallH * 0.72,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, Radius.circular(size * 0.05)),
      Paint()..color = AppColors.red,
    );
    // Тооно
    canvas.drawCircle(
      Offset(base.dx, wall.top - size * 0.42),
      size * 0.1,
      Paint()..color = AppColors.tileBorder,
    );
  }

  @override
  bool shouldRepaint(_SteppePainter old) =>
      old.horizon != horizon ||
      old.showGer != showGer ||
      old.showClouds != showClouds;
}
