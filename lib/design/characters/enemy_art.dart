import 'package:flutter/material.dart';

import '../theme.dart';

/// Дайсны дүрс: зураг (`image`) байвал түүнийг, эсвэл кодоор зурсан
/// монгол үлгэрийн хэв маягтай дайсны зураглалыг харуулна.
class EnemyArt extends StatelessWidget {
  const EnemyArt({
    super.key,
    required this.emoji,
    this.image,
    required this.size,
  });

  final String emoji;
  final String? image; // жишээ: 'assets/images/characters/wolf.png'
  final double size;

  @override
  Widget build(BuildContext context) {
    final painted = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EnemyPainter(emoji: emoji),
        child: _EnemyPainter.supports(emoji)
            ? null
            : FittedBox(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 100, height: 1.1),
                ),
              ),
      ),
    );

    final path = image;
    if (path == null || path.isEmpty) return painted;
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => painted,
    );
  }
}

class _EnemyPainter extends CustomPainter {
  _EnemyPainter({required this.emoji});

  final String emoji;

  static const _supported = {
    '🐭',
    '🐍',
    '🐺',
    '🦊',
    '🐻',
    '🐯',
    '🦅',
    '🐉',
    '🧟',
    '👹',
  };

  static bool supports(String e) => _supported.contains(e);

  @override
  void paint(Canvas canvas, Size size) {
    if (!supports(emoji)) return;

    canvas.scale(size.width / 100, size.height / 100);

    final outline = Paint()
      ..color = AppColors.navyDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    Paint fill(Color c) => Paint()..color = c;

    void shape(Path p, Color c) {
      canvas.drawPath(p, fill(c));
      canvas.drawPath(p, outline);
    }

    void fierceEyes({
      Offset left = const Offset(39, 44),
      Offset right = const Offset(59, 44),
      Color color = const Color(0xFFFFEB3B),
      double r = 3.6,
    }) {
      for (final c in [left, right]) {
        canvas.drawCircle(c, r, fill(color));
        canvas.drawCircle(c, r, outline);
        canvas.drawCircle(c + const Offset(-0.6, 0), r * 0.42, fill(Colors.black));
      }
      // Ууртай хөмсөг (зүүн тийш баатар луу харсан)
      final brow = Paint()
        ..color = AppColors.navyDeep
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        left + const Offset(-5, -5),
        left + const Offset(4, -2),
        brow,
      );
      canvas.drawLine(
        right + const Offset(-4, -2),
        right + const Offset(5, -5),
        brow,
      );
    }

    switch (emoji) {
      case '🐭': // Хулгана
        // Сүүл
        canvas.drawPath(
          Path()
            ..moveTo(68, 84)
            ..quadraticBezierTo(92, 78, 86, 56),
          Paint()
            ..color = const Color(0xFFE09198)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round,
        );
        // Чих
        for (final cx in [32.0, 66.0]) {
          canvas.drawCircle(Offset(cx, 32), 13, fill(const Color(0xFF8D99AE)));
          canvas.drawCircle(Offset(cx, 32), 13, outline);
          canvas.drawCircle(Offset(cx, 32), 7.5, fill(const Color(0xFFF4A5AE)));
        }
        // Бие ба толгой
        shape(
          Path()..addOval(const Rect.fromLTWH(28, 54, 44, 38)),
          const Color(0xFF8D99AE),
        );
        shape(
          Path()..addOval(const Rect.fromLTWH(35, 60, 26, 26)),
          const Color(0xFFD8E2DC),
        );
        shape(
          Path()..addOval(const Rect.fromLTWH(26, 30, 46, 36)),
          const Color(0xFF9AA6B8),
        );
        fierceEyes(
          left: const Offset(39, 46),
          right: const Offset(56, 46),
          color: const Color(0xFFFF5252),
          r: 3.2,
        );
        // Хамар + сахал + шүд
        canvas.drawCircle(const Offset(46, 54), 3.2, fill(const Color(0xFFE56B6F)));
        shape(
          Path()..addRect(const Rect.fromLTWH(43, 58, 6, 5)),
          Colors.white,
        );
        for (final dy in [-2.0, 2.0]) {
          canvas.drawLine(
            Offset(32, 54 + dy),
            Offset(16, 52 + dy * 2),
            outline..strokeWidth = 1.6,
          );
          canvas.drawLine(
            Offset(60, 54 + dy),
            Offset(76, 52 + dy * 2),
            outline,
          );
        }

      case '🐍': // Могой
        // Ороосон бие
        shape(
          Path()
            ..addRRect(
              RRect.fromRectAndRadius(
                const Rect.fromLTWH(20, 74, 62, 16),
                const Radius.circular(8),
              ),
            ),
          const Color(0xFF388E3C),
        );
        shape(
          Path()
            ..addRRect(
              RRect.fromRectAndRadius(
                const Rect.fromLTWH(26, 60, 50, 16),
                const Radius.circular(8),
              ),
            ),
          const Color(0xFF4CAF50),
        );
        // Хүзүү ба халхавч (кобра)
        final hood = Path()
          ..moveTo(42, 62)
          ..quadraticBezierTo(18, 44, 30, 24)
          ..quadraticBezierTo(50, 14, 70, 24)
          ..quadraticBezierTo(82, 44, 58, 62)
          ..close();
        shape(hood, const Color(0xFF2E7D32));
        shape(
          Path()..addOval(const Rect.fromLTWH(38, 28, 24, 32)),
          const Color(0xFFC8E6C9),
        );
        // Толгой
        shape(
          Path()..addOval(const Rect.fromLTWH(31, 20, 38, 26)),
          const Color(0xFF4CAF50),
        );
        // Хэл ба соёо
        canvas.drawPath(
          Path()
            ..moveTo(36, 44)
            ..lineTo(22, 50)
            ..lineTo(17, 47)
            ..moveTo(22, 50)
            ..lineTo(18, 54),
          Paint()
            ..color = AppColors.red
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round,
        );
        fierceEyes(
          left: const Offset(40, 32),
          right: const Offset(58, 32),
          color: AppColors.warning,
        );

      case '🐺': // Чоно
      case '🦊': // Үнэг
        final isFox = emoji == '🦊';
        final mainColor = isFox
            ? const Color(0xFFE65100)
            : const Color(0xFF607D8B);
        final lightColor = isFox
            ? const Color(0xFFFFF3E0)
            : const Color(0xFFCFD8DC);
        // Сүүл
        final tail = Path()
          ..moveTo(66, 78)
          ..quadraticBezierTo(96, 68, 90, 42)
          ..quadraticBezierTo(76, 50, 64, 68)
          ..close();
        shape(tail, mainColor);
        // Шовх чих
        for (final x in [28.0, 62.0]) {
          final ear = Path()
            ..moveTo(x - 6, 34)
            ..lineTo(x + 2, 10)
            ..lineTo(x + 12, 34)
            ..close();
          shape(ear, mainColor);
        }
        // Бие ба цээж
        shape(
          Path()
            ..moveTo(28, 54)
            ..lineTo(72, 54)
            ..lineTo(78, 92)
            ..lineTo(22, 92)
            ..close(),
          mainColor,
        );
        shape(
          Path()
            ..moveTo(36, 56)
            ..lineTo(60, 56)
            ..lineTo(48, 84)
            ..close(),
          lightColor,
        );
        // Толгой ба хацар
        final head = Path()
          ..moveTo(26, 30)
          ..lineTo(72, 30)
          ..lineTo(80, 48)
          ..lineTo(50, 62)
          ..lineTo(18, 48)
          ..close();
        shape(head, mainColor);
        // Цагаан хоншоор ба соёо
        shape(
          Path()
            ..moveTo(22, 46)
            ..lineTo(48, 44)
            ..lineTo(76, 46)
            ..lineTo(48, 62)
            ..close(),
          lightColor,
        );
        canvas.drawCircle(const Offset(48, 52), 4, fill(AppColors.navyDeep));
        // Соёо
        for (final fx in [38.0, 56.0]) {
          shape(
            Path()
              ..moveTo(fx, 56)
              ..lineTo(fx + 2.5, 63)
              ..lineTo(fx + 5, 56)
              ..close(),
            Colors.white,
          );
        }
        fierceEyes(
          left: const Offset(38, 39),
          right: const Offset(59, 39),
          color: isFox ? const Color(0xFFFFD54F) : const Color(0xFFFFEB3B),
        );

      case '🐻': // Баавгай
      case '🐯': // Бар
        final isTiger = emoji == '🐯';
        final coat = isTiger
            ? const Color(0xFFF57C00)
            : const Color(0xFF6D4C41);
        final muzzle = isTiger
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFD7CCC8);
        // Дугуй чих
        for (final cx in [28.0, 72.0]) {
          canvas.drawCircle(Offset(cx, 24), 10, fill(coat));
          canvas.drawCircle(Offset(cx, 24), 10, outline);
        }
        // Хүчирхэг бие
        shape(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(18, 48, 64, 44),
              const Radius.circular(18),
            ),
          ),
          coat,
        );
        // Толгой
        shape(
          Path()..addOval(const Rect.fromLTWH(22, 20, 56, 44)),
          coat,
        );
        if (isTiger) {
          // Барын судал
          final stripe = Paint()
            ..color = AppColors.navyDeep
            ..strokeWidth = 3.2
            ..strokeCap = StrokeCap.round;
          for (final dy in [30.0, 38.0, 46.0]) {
            canvas.drawLine(Offset(24, dy), Offset(32, dy + 2), stripe);
            canvas.drawLine(Offset(76, dy), Offset(68, dy + 2), stripe);
          }
        }
        // Хоншоор ба архирсан ам
        shape(
          Path()..addOval(const Rect.fromLTWH(34, 40, 32, 22)),
          muzzle,
        );
        shape(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(38, 49, 24, 10),
              const Radius.circular(4),
            ),
          ),
          const Color(0xFF880E4F),
        );
        // Соёо
        for (final fx in [40.0, 55.0]) {
          shape(
            Path()
              ..moveTo(fx, 49)
              ..lineTo(fx + 2.5, 56)
              ..lineTo(fx + 5, 49)
              ..close(),
            Colors.white,
          );
        }
        canvas.drawOval(
          const Rect.fromLTWH(45, 41, 10, 6),
          fill(AppColors.navyDeep),
        );
        fierceEyes(
          left: const Offset(39, 34),
          right: const Offset(61, 34),
          color: const Color(0xFFFFD600),
        );

      case '🦅': // Хар шувуу
        // Дэлгэсэн далавч
        final wings = Path()
          ..moveTo(50, 44)
          ..quadraticBezierTo(18, 16, 4, 34)
          ..quadraticBezierTo(12, 58, 32, 62)
          ..lineTo(50, 58)
          ..lineTo(68, 62)
          ..quadraticBezierTo(88, 58, 96, 34)
          ..quadraticBezierTo(82, 16, 50, 44)
          ..close();
        shape(wings, const Color(0xFF263238));
        // Бие
        shape(
          Path()..addOval(const Rect.fromLTWH(33, 42, 34, 42)),
          const Color(0xFF37474F),
        );
        // Толгой
        shape(
          Path()..addCircle(const Offset(50, 34), 16),
          const Color(0xFF455A64),
        );
        // Махир алтан хошуу
        final beak = Path()
          ..moveTo(42, 34)
          ..quadraticBezierTo(28, 36, 32, 48)
          ..quadraticBezierTo(44, 44, 52, 40)
          ..close();
        shape(beak, AppColors.accent);
        // Хумс
        for (final x in [40.0, 58.0]) {
          canvas.drawLine(
            Offset(x, 82),
            Offset(x - 4, 92),
            Paint()
              ..color = AppColors.accent
              ..strokeWidth = 3
              ..strokeCap = StrokeCap.round,
          );
        }
        fierceEyes(
          left: const Offset(41, 31),
          right: const Offset(57, 31),
          color: const Color(0xFFFF5252),
        );

      case '🐉': // Луу
        // Далавч
        final leftWing = Path()
          ..moveTo(38, 52)
          ..lineTo(8, 24)
          ..lineTo(14, 58)
          ..lineTo(36, 66)
          ..close();
        final rightWing = Path()
          ..moveTo(62, 52)
          ..lineTo(92, 24)
          ..lineTo(86, 58)
          ..lineTo(64, 66)
          ..close();
        shape(leftWing, const Color(0xFF8E0000));
        shape(rightWing, const Color(0xFF8E0000));
        // Эвэр
        for (final s in [(-1.0, 36.0), (1.0, 64.0)]) {
          shape(
            Path()
              ..moveTo(s.$2, 24)
              ..lineTo(s.$2 + s.$1 * 12, 6)
              ..lineTo(s.$2 + s.$1 * 4, 28)
              ..close(),
            AppColors.accent,
          );
        }
        // Бие ба алтан гэдэс
        shape(
          Path()..addOval(const Rect.fromLTWH(28, 46, 44, 46)),
          const Color(0xFFC62828),
        );
        shape(
          Path()..addOval(const Rect.fromLTWH(36, 52, 28, 36)),
          AppColors.accent,
        );
        // Толгой
        shape(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(28, 20, 44, 32),
              const Radius.circular(12),
            ),
          ),
          const Color(0xFFD32F2F),
        );
        // Амнаас гарах галын дөл
        final flame = Path()
          ..moveTo(32, 44)
          ..quadraticBezierTo(10, 38, 6, 48)
          ..quadraticBezierTo(16, 58, 34, 49)
          ..close();
        canvas.drawPath(flame, fill(const Color(0xFFFF9800)));
        fierceEyes(
          left: const Offset(40, 34),
          right: const Offset(60, 34),
          color: const Color(0xFFFFEA00),
          r: 4.0,
        );

      case '🧟': // Шулам
        // Шидэт таяг
        canvas.drawLine(
          const Offset(20, 26),
          const Offset(26, 92),
          Paint()
            ..color = const Color(0xFF4E342E)
            ..strokeWidth = 4.5
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(
          const Offset(20, 22),
          7,
          fill(const Color(0xFFE040FB)),
        );
        canvas.drawCircle(const Offset(20, 22), 7, outline);
        // Хар ягаан нөмрөг
        final cloak = Path()
          ..moveTo(52, 12)
          ..lineTo(80, 42)
          ..lineTo(84, 92)
          ..lineTo(26, 92)
          ..lineTo(30, 42)
          ..close();
        shape(cloak, const Color(0xFF4A148C));
        // Царай (ногоон туяатай)
        shape(
          Path()..addOval(const Rect.fromLTWH(36, 26, 32, 30)),
          const Color(0xFF9CCC65),
        );
        // Шовгор малгай
        shape(
          Path()
            ..moveTo(24, 30)
            ..lineTo(52, 4)
            ..lineTo(80, 30)
            ..close(),
          const Color(0xFF311B92),
        );
        fierceEyes(
          left: const Offset(45, 39),
          right: const Offset(60, 39),
          color: const Color(0xFFE040FB),
        );

      case '👹': // Мангас (Эцсийн босс)
        // Иржгэр бороохой (баруун талд)
        shape(
          Path()
            ..moveTo(78, 22)
            ..lineTo(92, 22)
            ..lineTo(88, 76)
            ..lineTo(80, 76)
            ..close(),
          const Color(0xFF4E342E),
        );
        // Аварга улаан бие ба хуяг
        shape(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(16, 44, 66, 48),
              const Radius.circular(16),
            ),
          ),
          const Color(0xFFB71C1C),
        );
        shape(
          Path()
            ..moveTo(22, 54)
            ..lineTo(76, 54)
            ..lineTo(68, 90)
            ..lineTo(30, 90)
            ..close(),
          const Color(0xFF263238),
        );
        // Хоёр том тахир эвэр
        for (final s in [(-1.0, 30.0), (1.0, 68.0)]) {
          shape(
            Path()
              ..moveTo(s.$2, 26)
              ..quadraticBezierTo(s.$2 + s.$1 * 22, 12, s.$2 + s.$1 * 16, 4)
              ..quadraticBezierTo(s.$2 + s.$1 * 8, 16, s.$2 + s.$1 * 4, 30)
              ..close(),
            AppColors.accent,
          );
        }
        // Толгой
        shape(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(24, 18, 50, 38),
              const Radius.circular(14),
            ),
          ),
          const Color(0xFFD32F2F),
        );
        // Гурав дахь нүд (духан дээр)
        canvas.drawCircle(
          const Offset(49, 25),
          3.4,
          fill(const Color(0xFFFFEA00)),
        );
        canvas.drawCircle(const Offset(49, 25), 3.4, outline);
        // Том соёотой ам
        shape(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(33, 42, 32, 10),
              const Radius.circular(4),
            ),
          ),
          AppColors.navyDeep,
        );
        for (final fx in [36.0, 56.0]) {
          shape(
            Path()
              ..moveTo(fx, 52)
              ..lineTo(fx + 3.5, 41)
              ..lineTo(fx + 7, 52)
              ..close(),
            Colors.white,
          );
        }
        fierceEyes(
          left: const Offset(38, 34),
          right: const Offset(60, 34),
          color: const Color(0xFFFFEA00),
          r: 4.2,
        );
    }
  }

  @override
  bool shouldRepaint(_EnemyPainter old) => old.emoji != emoji;
}

extension on Path {
  addCircle(Offset offset, int i) {}
}
