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
    canvas.scale(size.width / _w, size.height / _h);

    final outline = Paint()
      ..color = AppColors.navyDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    Paint fill(Color c) => Paint()..color = c;

    void shape(Path p, Color c) {
      canvas.drawPath(p, fill(c));
      canvas.drawPath(p, outline);
    }

    // 1. Дайчны улаан нөмрөг (ар талд намирах)
    final cape = Path()
      ..moveTo(30, 48)
      ..quadraticBezierTo(10, 74, 12, 108)
      ..quadraticBezierTo(28, 104, 36, 106)
      ..lineTo(42, 52)
      ..close();
    shape(cape, const Color(0xFF9E1F1B));

    // 2. Монгол гутал (ээтэн хоншоортой, цагаан ултай)
    for (final x in [31.0, 53.0]) {
      final boot = Path()
        ..moveTo(x, 103)
        ..lineTo(x + 14, 103)
        ..lineTo(x + 16, 114)
        ..quadraticBezierTo(x + 20, 113, x + 19, 117)
        ..lineTo(x, 117)
        ..close();
      shape(boot, AppColors.heroBoots);
      // Цагаан ул
      canvas.drawLine(
        Offset(x + 1, 116),
        Offset(x + 18, 116),
        Paint()
          ..color = AppColors.cream
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }

    // 3. Дээл (хормой ба энгэр)
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
          colors: [
            Color(0xFF3478C6),
            AppColors.heroDeel,
            AppColors.heroDeelDark,
          ],
        ).createShader(const Rect.fromLTWH(24, 49, 52, 60)),
    );
    canvas.drawPath(deel, outline);

    // Дээлийн алтан эмжээр (энгэр ба хормой)
    final trim = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(45, 50)
        ..lineTo(64, 68)
        ..lineTo(67, 105),
      trim,
    );
    canvas.drawPath(
      Path()
        ..moveTo(26, 104)
        ..quadraticBezierTo(50, 108, 74, 104),
      trim,
    );

    // Энгэрийн алтан наран хээ
    canvas.drawCircle(
      const Offset(46, 62),
      4.2,
      Paint()..color = AppColors.accent.withValues(alpha: 0.85),
    );

    // 4. Мөрний хуяг (мөрөвч)
    for (final s in [(-1.0, 29.0), (1.0, 71.0)]) {
      final pauldron = Path()
        ..moveTo(s.$2 - s.$1 * 8, 47)
        ..quadraticBezierTo(s.$2 + s.$1 * 6, 46, s.$2 + s.$1 * 8, 57)
        ..lineTo(s.$2 - s.$1 * 6, 56)
        ..close();
      shape(pauldron, const Color(0xFF4A3525));
      canvas.drawCircle(Offset(s.$2, 52), 1.6, fill(AppColors.accent));
    }

    // 5. Улаан бүс + алтан горхи + унжлага
    final sash = RRect.fromRectAndRadius(
      const Rect.fromLTWH(28, 73, 44, 9),
      const Radius.circular(3.5),
    );
    shape(Path()..addRRect(sash), AppColors.heroSash);
    // Бүсний алтан горхи
    final buckle = RRect.fromRectAndRadius(
      const Rect.fromLTWH(45, 72, 10, 11),
      const Radius.circular(2.5),
    );
    shape(Path()..addRRect(buckle), AppColors.accent);
    canvas.drawRect(
      const Rect.fromLTWH(48, 75, 4, 5),
      fill(AppColors.heroSash),
    );

    // 6. Тахир монгол илд (баруун гарт)
    canvas.save();
    canvas.translate(77, 67);
    canvas.rotate(0.36);
    // Илдний ир (тахир)
    final blade = Path()
      ..moveTo(-3, -4)
      ..quadraticBezierTo(-4, -30, 3, -52)
      ..quadraticBezierTo(7, -32, 3.5, -4)
      ..close();
    canvas.drawPath(
      blade,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.white, AppColors.heroBlade, Color(0xFF9EB4CC)],
        ).createShader(const Rect.fromLTWH(-4, -52, 12, 48)),
    );
    canvas.drawPath(blade, outline);
    // Илдний гялбаа
    canvas.drawLine(
      const Offset(0, -10),
      const Offset(1.5, -42),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round,
    );
    // Алтан гарди (гар хамгаалалт) ба бариул
    shape(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-9, -5, 18, 5),
          const Radius.circular(2.5),
        ),
      ),
      AppColors.accent,
    );
    shape(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-2.5, 0, 5, 10),
          const Radius.circular(2),
        ),
      ),
      AppColors.heroSash,
    );
    canvas.restore();

    // 7. Баруун гар (илд барьсан)
    shape(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(66, 54, 11, 21),
          const Radius.circular(5),
        ),
      ),
      AppColors.heroDeel,
    );
    canvas.drawCircle(const Offset(76, 70), 5.2, fill(AppColors.heroSkin));
    canvas.drawCircle(const Offset(76, 70), 5.2, outline);

    // 8. Зүүн гар ба дугуй бамбай
    shape(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(21, 53, 10, 22),
          const Radius.circular(5),
        ),
      ),
      AppColors.heroDeel,
    );
    const shieldCenter = Offset(23, 71);
    canvas.drawCircle(shieldCenter, 12.5, fill(const Color(0xFF5D3A1A)));
    canvas.drawCircle(
      shieldCenter,
      12.5,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );
    canvas.drawCircle(shieldCenter, 12.5, outline);
    canvas.drawCircle(shieldCenter, 4.5, fill(AppColors.accent));
    canvas.drawCircle(shieldCenter, 4.5, outline);

    // 9. Толгой ба царай
    // Хүзүү
    shape(
      Path()..addRect(const Rect.fromLTWH(45, 44, 10, 7)),
      AppColors.heroSkin,
    );
    // Чих
    canvas.drawCircle(const Offset(35, 37), 3.8, fill(AppColors.heroSkin));
    canvas.drawCircle(const Offset(35, 37), 3.8, outline);

    // Нүүр
    canvas.drawCircle(const Offset(50, 35), 15.5, fill(AppColors.heroSkin));
    canvas.drawCircle(const Offset(50, 35), 15.5, outline);

    // Хацрын туяа
    final cheek = Paint()..color = AppColors.red.withValues(alpha: 0.22);
    canvas.drawOval(const Rect.fromLTWH(43, 38, 5.5, 3.2), cheek);
    canvas.drawOval(const Rect.fromLTWH(59, 38, 5.5, 3.2), cheek);

    // Хөмсөг (зоримог харц)
    final brow = Paint()
      ..color = AppColors.heroBrim
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(47, 31), const Offset(53, 32.2), brow);
    canvas.drawLine(const Offset(57, 32.2), const Offset(63, 31), brow);

    // Нүд + гялбаа
    final eye = fill(AppColors.navyDeep);
    canvas.drawCircle(const Offset(50.5, 35.5), 2.3, eye);
    canvas.drawCircle(const Offset(60.0, 35.5), 2.3, eye);
    final shine = fill(Colors.white);
    canvas.drawCircle(const Offset(51.2, 34.7), 0.9, shine);
    canvas.drawCircle(const Offset(60.7, 34.7), 0.9, shine);

    // Инээмсэглэл
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

    // 10. Монгол жанжин малгай / дуулга
    // Оройн улаан залаа (намирсан)
    final plume = Path()
      ..moveTo(50, 5)
      ..quadraticBezierTo(36, 0, 29, 11)
      ..quadraticBezierTo(39, 9, 50, 8)
      ..close();
    shape(plume, AppColors.red);

    // Малгайн шовгор орой
    final dome = Path()
      ..moveTo(35, 25)
      ..quadraticBezierTo(50, 0, 65, 25)
      ..close();
    shape(dome, AppColors.heroHat);

    // Малгайн үстэй хар хүрээ (сөхөөс)
    final brim = Path()
      ..moveTo(31, 24)
      ..quadraticBezierTo(50, 19, 69, 24)
      ..lineTo(67, 30)
      ..quadraticBezierTo(50, 26, 33, 30)
      ..close();
    shape(brim, AppColors.heroBrim);

    // Духны алтан чимэг ба оройн жинс
    canvas.drawCircle(const Offset(50, 25), 3.0, fill(AppColors.accent));
    canvas.drawCircle(const Offset(50, 25), 3.0, outline);
    canvas.drawCircle(const Offset(50, 6.5), 3.4, fill(AppColors.accent));
    canvas.drawCircle(const Offset(50, 6.5), 3.4, outline);
  }

  @override
  bool shouldRepaint(_HeroPainter old) => false;
}
