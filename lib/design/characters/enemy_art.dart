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

  static final Paint _outline = Paint()
    ..color = AppColors.navyDeep
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  void _shape(Canvas c, Path p, Color col) {
    c.drawPath(p, Paint()..color = col);
    c.drawPath(p, _outline);
  }

  void _oval(Canvas c, Rect r, Color col) =>
      _shape(c, Path()..addOval(r), col);

  void _rrect(Canvas c, Rect r, double rad, Color col) => _shape(
    c,
    Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(rad))),
    col,
  );

  void _poly(Canvas c, List<Offset> pts, Color col) =>
      _shape(c, Path()..addPolygon(pts, true), col);

  void _eyes(
    Canvas c, {
    Offset left = const Offset(39, 44),
    Offset right = const Offset(59, 44),
    Color color = const Color(0xFFFFEB3B),
    double r = 3.6,
  }) {
    for (final pos in [left, right]) {
      c.drawCircle(pos, r, Paint()..color = color);
      c.drawCircle(pos, r, _outline);
      c.drawCircle(pos + const Offset(-0.6, 0), r * 0.42, Paint());
    }
    c.drawLine(left + const Offset(-5, -5), left + const Offset(4, -2), _outline);
    c.drawLine(right + const Offset(-4, -2), right + const Offset(5, -5), _outline);
  }

  void _fangs(Canvas c, double y, List<double> xs, {double dy = 7}) {
    for (final x in xs) {
      _poly(
        c,
        [Offset(x, y), Offset(x + 2.5, y + dy), Offset(x + 5, y)],
        Colors.white,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!supports(emoji) || size.isEmpty) return;
    canvas.scale(size.width / 100, size.height / 100);

    switch (emoji) {
      case '🐭': // Хулгана
        for (final cx in const [32.0, 66.0]) {
          _oval(canvas, Rect.fromCircle(center: Offset(cx, 32), radius: 12), const Color(0xFF8D99AE));
          canvas.drawCircle(Offset(cx, 32), 7, Paint()..color = const Color(0xFFF4A5AE));
        }
        _oval(canvas, const Rect.fromLTWH(28, 54, 44, 38), const Color(0xFF8D99AE));
        _oval(canvas, const Rect.fromLTWH(35, 60, 26, 26), const Color(0xFFD8E2DC));
        _oval(canvas, const Rect.fromLTWH(26, 30, 46, 36), const Color(0xFF9AA6B8));
        _eyes(canvas, left: const Offset(39, 46), right: const Offset(56, 46), color: const Color(0xFFFF5252));
        canvas.drawCircle(const Offset(47, 54), 3, Paint()..color = const Color(0xFFE56B6F));
        _rrect(canvas, const Rect.fromLTWH(44, 58, 6, 5), 1, Colors.white);

      case '🐍': // Могой
        _rrect(canvas, const Rect.fromLTWH(20, 74, 62, 16), 8, const Color(0xFF388E3C));
        _rrect(canvas, const Rect.fromLTWH(26, 60, 50, 16), 8, const Color(0xFF4CAF50));
        _oval(canvas, const Rect.fromLTWH(24, 22, 52, 42), const Color(0xFF2E7D32));
        _oval(canvas, const Rect.fromLTWH(38, 28, 24, 32), const Color(0xFFC8E6C9));
        _oval(canvas, const Rect.fromLTWH(31, 20, 38, 26), const Color(0xFF4CAF50));
        _eyes(canvas, left: const Offset(40, 32), right: const Offset(58, 32));

      case '🐺': // Чоно
      case '🦊': // Үнэг
        final isFox = emoji == '🦊';
        final main = isFox ? const Color(0xFFE65100) : const Color(0xFF607D8B);
        final light = isFox ? const Color(0xFFFFF3E0) : const Color(0xFFCFD8DC);
        for (final x in const [28.0, 62.0]) {
          _poly(canvas, [Offset(x - 6, 34), Offset(x + 2, 10), Offset(x + 12, 34)], main);
        }
        _poly(canvas, const [Offset(28, 54), Offset(72, 54), Offset(78, 92), Offset(22, 92)], main);
        _poly(canvas, const [Offset(36, 56), Offset(60, 56), Offset(48, 84)], light);
        _poly(canvas, const [Offset(26, 30), Offset(72, 30), Offset(80, 48), Offset(50, 62), Offset(18, 48)], main);
        _poly(canvas, const [Offset(22, 46), Offset(48, 44), Offset(76, 46), Offset(48, 62)], light);
        canvas.drawCircle(const Offset(48, 52), 4, Paint()..color = AppColors.navyDeep);
        _fangs(canvas, 56, const [38, 56]);
        _eyes(canvas, left: const Offset(38, 39), right: const Offset(59, 39));

      case '🐻': // Баавгай
      case '🐯': // Бар
        final isTiger = emoji == '🐯';
        final coat = isTiger ? const Color(0xFFF57C00) : const Color(0xFF6D4C41);
        final muzzle = isTiger ? const Color(0xFFFFF8E1) : const Color(0xFFD7CCC8);
        for (final cx in const [28.0, 72.0]) {
          _oval(canvas, Rect.fromCircle(center: Offset(cx, 24), radius: 10), coat);
        }
        _rrect(canvas, const Rect.fromLTWH(18, 48, 64, 44), 18, coat);
        _oval(canvas, const Rect.fromLTWH(22, 20, 56, 44), coat);
        _oval(canvas, const Rect.fromLTWH(34, 40, 32, 22), muzzle);
        _rrect(canvas, const Rect.fromLTWH(38, 49, 24, 10), 4, const Color(0xFF880E4F));
        _fangs(canvas, 49, const [40, 55]);
        _eyes(canvas, left: const Offset(39, 34), right: const Offset(61, 34));

      case '🦅': // Хар шувуу
        _poly(
          canvas,
          const [
            Offset(50, 44),
            Offset(6, 30),
            Offset(18, 58),
            Offset(50, 58),
            Offset(82, 58),
            Offset(94, 30),
          ],
          const Color(0xFF263238),
        );
        _oval(canvas, const Rect.fromLTWH(33, 42, 34, 42), const Color(0xFF37474F));
        _oval(canvas, Rect.fromCircle(center: const Offset(50, 34), radius: 16), const Color(0xFF455A64));
        _poly(canvas, const [Offset(42, 34), Offset(30, 44), Offset(52, 42)], AppColors.accent);
        _eyes(canvas, left: const Offset(41, 31), right: const Offset(57, 31), color: const Color(0xFFFF5252));

      case '🐉': // Луу
        _poly(canvas, const [Offset(38, 52), Offset(8, 24), Offset(14, 58), Offset(36, 66)], const Color(0xFF8E0000));
        _poly(canvas, const [Offset(62, 52), Offset(92, 24), Offset(86, 58), Offset(64, 66)], const Color(0xFF8E0000));
        _poly(canvas, const [Offset(36, 24), Offset(24, 6), Offset(40, 28)], AppColors.accent);
        _poly(canvas, const [Offset(64, 24), Offset(76, 6), Offset(60, 28)], AppColors.accent);
        _oval(canvas, const Rect.fromLTWH(28, 46, 44, 46), const Color(0xFFC62828));
        _oval(canvas, const Rect.fromLTWH(36, 52, 28, 36), AppColors.accent);
        _rrect(canvas, const Rect.fromLTWH(28, 20, 44, 32), 12, const Color(0xFFD32F2F));
        _eyes(canvas, left: const Offset(40, 34), right: const Offset(60, 34), r: 4.0);

      case '🧟': // Шулам
        _poly(
          canvas,
          const [Offset(52, 12), Offset(80, 42), Offset(84, 92), Offset(26, 92), Offset(30, 42)],
          const Color(0xFF4A148C),
        );
        _oval(canvas, const Rect.fromLTWH(36, 26, 32, 30), const Color(0xFF9CCC65));
        _poly(canvas, const [Offset(24, 30), Offset(52, 4), Offset(80, 30)], const Color(0xFF311B92));
        _eyes(canvas, left: const Offset(45, 39), right: const Offset(60, 39), color: const Color(0xFFE040FB));

      case '👹': // Мангас
        _poly(canvas, const [Offset(78, 22), Offset(92, 22), Offset(88, 76), Offset(80, 76)], const Color(0xFF4E342E));
        _rrect(canvas, const Rect.fromLTWH(16, 44, 66, 48), 16, const Color(0xFFB71C1C));
        _poly(canvas, const [Offset(22, 54), Offset(76, 54), Offset(68, 90), Offset(30, 90)], const Color(0xFF263238));
        _poly(canvas, const [Offset(30, 26), Offset(14, 6), Offset(34, 30)], AppColors.accent);
        _poly(canvas, const [Offset(68, 26), Offset(84, 6), Offset(64, 30)], AppColors.accent);
        _rrect(canvas, const Rect.fromLTWH(24, 18, 50, 38), 14, const Color(0xFFD32F2F));
        _rrect(canvas, const Rect.fromLTWH(33, 42, 32, 10), 4, AppColors.navyDeep);
        _fangs(canvas, 52, const [36, 56], dy: -10);
        _eyes(canvas, left: const Offset(38, 34), right: const Offset(60, 34), r: 4.2);
    }
  }

  @override
  bool shouldRepaint(_EnemyPainter old) => old.emoji != emoji;
}
