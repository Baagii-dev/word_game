import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../theme.dart';

/// Баатар — монгол дээл, малгайтай дайчин. Кодоор зурсан (зураг шаардахгүй).
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
    width: size * 0.9,
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
    canvas.scale(size.width / _w, size.height / _h);

    final outline = Paint()
      ..color = AppColors.navyDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    Paint fill(Color c) => Paint()..color = c;

    void shape(Path p, Color c) {
      canvas.drawPath(p, fill(c));
      canvas.drawPath(p, outline);
    }

    // Гутал
    for (final x in [34.0, 53.0]) {
      shape(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, 106, 14, 12),
            const Radius.circular(4),
          ),
        ),
        AppColors.heroBoots,
      );
    }

    // Дээл (гэдэс, хормой)
    final deel = Path()
      ..moveTo(32, 50)
      ..lineTo(68, 50)
      ..lineTo(76, 108)
      ..lineTo(24, 108)
      ..close();
    shape(deel, AppColors.heroDeel);

    // Алтан хүрээ: баруун талын эвхэгдэл ба хормойн зах
    final trim = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(46, 50)
        ..lineTo(66, 76)
        ..lineTo(70, 106),
      trim,
    );
    canvas.drawLine(const Offset(25, 106), const Offset(75, 106), trim);

    // Улаан бүс
    shape(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(28, 74, 44, 9),
          const Radius.circular(3),
        ),
      ),
      AppColors.heroSash,
    );

    // Зүүн гар (биедээ наалдсан)
    shape(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(20, 52, 10, 28),
          const Radius.circular(5),
        ),
      ),
      AppColors.heroDeel,
    );

    // Сэлэм (баруун гарт, дээш өргөсөн)
    canvas.save();
    canvas.translate(76, 66);
    canvas.rotate(0.42);
    shape(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-2.5, -46, 5, 44),
          const Radius.circular(2),
        ),
      ),
      AppColors.heroBlade,
    );
    shape(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-8, -4, 16, 5),
          const Radius.circular(2),
        ),
      ),
      AppColors.accent,
    );
    canvas.restore();

    // Баруун гар
    shape(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(66, 54, 11, 22),
          const Radius.circular(5),
        ),
      ),
      AppColors.heroDeel,
    );
    canvas.drawCircle(const Offset(76, 70), 5, fill(AppColors.heroSkin));
    canvas.drawCircle(const Offset(76, 70), 5, outline);

    // Толгой
    canvas.drawCircle(const Offset(50, 36), 15, fill(AppColors.heroSkin));
    canvas.drawCircle(const Offset(50, 36), 15, outline);
    // Нүд (баруун тийш харсан)
    final eye = fill(AppColors.navyDark);
    canvas.drawCircle(const Offset(52, 36), 1.8, eye);
    canvas.drawCircle(const Offset(60, 36), 1.8, eye);
    canvas.drawArc(
      const Rect.fromLTWH(52, 38, 9, 7),
      0.2,
      2.6,
      false,
      outline..strokeWidth = 1.6,
    );
    outline.strokeWidth = 2.2;

    // Малгай: улаан орой, хар хүрээ, алтан бөмбөлөг
    shape(
      Path()
        ..moveTo(36, 26)
        ..quadraticBezierTo(50, -2, 64, 26)
        ..close(),
      AppColors.heroHat,
    );
    shape(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(33, 23, 34, 8),
          const Radius.circular(4),
        ),
      ),
      AppColors.heroBrim,
    );
    canvas.drawCircle(const Offset(50, 7), 3.2, fill(AppColors.accent));
    canvas.drawCircle(const Offset(50, 7), 3.2, outline);
  }

  @override
  bool shouldRepaint(_HeroPainter old) => false;
}
