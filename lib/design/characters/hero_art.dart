import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../theme.dart';

/// Баатар — монгол дээл, хуяг дуулга, бамбай, тахир сэлэмтэй дайчин.
/// `AppAssets.heroImage` тохируулбал тэр зургийг харуулна.
class HeroArt extends StatelessWidget {
  const HeroArt({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final image = AppAssets.heroImage;
    if (image != null) {
      return Image.asset(
        image,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => _painted(),
      );
    }
    return _painted();
  }

  Widget _painted() => SizedBox(
    width: size * 0.95,
    height: size,
    child: CustomPaint(painter: _HeroPainter()),
  );
}

/// 100 × 120 нэгжийн дүрслэл дээр зурж, хэмжээнд тааруулан томруулна.
class _HeroPainter extends CustomPainter {
  static const double _w = 100;
  static const double _h = 120;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.scale(size.width / _w, size.height / _h);

    final outline = Paint()
      ..color = AppColors.navyDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    void shape(Path p, Color c) {
      canvas.drawPath(p, Paint()..color = c);
      canvas.drawPath(p, outline);
    }

    void rrect(Rect r, double rad, Color c) => shape(
      Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(rad))),
      c,
    );

    void circle(Offset center, double r, Color c) {
      canvas.drawCircle(center, r, Paint()..color = c);
      canvas.drawCircle(center, r, outline);
    }

    // 1. Улаан нөмрөг
    shape(
      Path()
        ..moveTo(30, 48)
        ..quadraticBezierTo(10, 74, 12, 108)
        ..quadraticBezierTo(28, 104, 36, 106)
        ..lineTo(42, 52)
        ..close(),
      const Color(0xFF9E1F1B),
    );

    // 2. Монгол гутал
    for (final x in const [31.0, 53.0]) {
      shape(
        Path()
          ..moveTo(x, 103)
          ..lineTo(x + 14, 103)
          ..lineTo(x + 16, 114)
          ..quadraticBezierTo(x + 20, 113, x + 19, 117)
          ..lineTo(x, 117)
          ..close(),
        AppColors.heroBoots,
      );
    }

    // 3. Дээл ба алтан эмжээр
    final deel = Path()
      ..moveTo(31, 49)
      ..lineTo(69, 49)
      ..lineTo(76, 106)
      ..quadraticBezierTo(50, 110, 24, 106)
      ..close();
    canvas.drawPath(
      deel,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3478C6), AppColors.heroDeel, AppColors.heroDeelDark],
        ).createShader(const Rect.fromLTWH(24, 49, 52, 60)),
    );
    canvas.drawPath(deel, outline);

    final trim = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(45, 50)
        ..lineTo(64, 68)
        ..lineTo(67, 105),
      trim,
    );
    canvas.drawLine(const Offset(26, 105), const Offset(74, 105), trim);

    // 4. Улаан бүс ба алтан горхи
    rrect(const Rect.fromLTWH(28, 73, 44, 9), 3.5, AppColors.heroSash);
    rrect(const Rect.fromLTWH(45, 72, 10, 11), 2.5, AppColors.accent);

    // 5. Тахир монгол илд (баруун гарт)
    canvas.save();
    canvas.translate(77, 67);
    canvas.rotate(0.36);
    shape(
      Path()
        ..moveTo(-3, -4)
        ..quadraticBezierTo(-4, -30, 3, -52)
        ..quadraticBezierTo(7, -32, 3.5, -4)
        ..close(),
      AppColors.heroBlade,
    );
    rrect(const Rect.fromLTWH(-9, -5, 18, 5), 2.5, AppColors.accent);
    canvas.restore();

    // 6. Баруун гар, зүүн гар ба бамбай
    rrect(const Rect.fromLTWH(66, 54, 11, 21), 5, AppColors.heroDeel);
    circle(const Offset(76, 70), 5, AppColors.heroSkin);

    rrect(const Rect.fromLTWH(21, 53, 10, 22), 5, AppColors.heroDeel);
    circle(const Offset(23, 71), 12, const Color(0xFF5D3A1A));
    circle(const Offset(23, 71), 4.2, AppColors.accent);

    // 7. Толгой ба царай
    circle(const Offset(50, 35), 15.5, AppColors.heroSkin);
    final eye = Paint()..color = AppColors.navyDeep;
    canvas.drawCircle(const Offset(50.5, 35.5), 2.2, eye);
    canvas.drawCircle(const Offset(60.0, 35.5), 2.2, eye);
    canvas.drawArc(
      const Rect.fromLTWH(51, 38, 9, 6.5),
      0.15,
      2.6,
      false,
      Paint()
        ..color = AppColors.navyDeep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // 8. Жанжин малгай (улаан залаа, шовгор орой, хар хүрээ, алтан жинс)
    shape(
      Path()
        ..moveTo(50, 5)
        ..quadraticBezierTo(36, 0, 29, 11)
        ..quadraticBezierTo(39, 9, 50, 8)
        ..close(),
      AppColors.red,
    );
    shape(
      Path()
        ..moveTo(35, 25)
        ..quadraticBezierTo(50, 0, 65, 25)
        ..close(),
      AppColors.heroHat,
    );
    rrect(const Rect.fromLTWH(32, 23, 36, 7.5), 4, AppColors.heroBrim);
    circle(const Offset(50, 6.5), 3.2, AppColors.accent);
  }

  @override
  bool shouldRepaint(_HeroPainter old) => false;
}
