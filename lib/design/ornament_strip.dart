import 'package:flutter/material.dart';

import 'theme.dart';

/// Монгол "алхан хээ" болон "угалз" хосолсон гоёлын тууз.
/// Дэлгэцийн дээд/доод ирмэг болон самбарын заагийг чимэхэд ашиглана.
class OrnamentStrip extends StatelessWidget {
  const OrnamentStrip({
    super.key,
    this.height = 22,
    this.background = AppColors.navyDark,
    this.color = AppColors.accent,
  });

  final double height;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _OrnamentPainter(background, color)),
    );
  }
}

class _OrnamentPainter extends CustomPainter {
  _OrnamentPainter(this.background, this.color);

  final Color background;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rect = Offset.zero & size;
    // Гүнзгий градиент дэвсгэр
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(background, Colors.black, 0.22) ?? background,
            background,
            Color.lerp(background, Colors.black, 0.28) ?? background,
          ],
        ).createShader(rect),
    );

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final glowPaint = Paint()
      ..color = (Color.lerp(color, Colors.white, 0.35) ?? color).withValues(
        alpha: 0.85,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    // Дээд, доод давхар алтан хүрээ
    canvas.drawLine(
      const Offset(0, 1.2),
      Offset(size.width, 1.2),
      borderPaint,
    );
    canvas.drawLine(
      Offset(0, size.height - 1.2),
      Offset(size.width, size.height - 1.2),
      borderPaint,
    );

    // Алхан хээ (T-хэлбэрийн тасралтгүй монгол хээ)
    final top = size.height * 0.22;
    final bottom = size.height * 0.78;
    final mid = size.height * 0.5;
    final unit = size.height * 1.45;
    if (unit <= 4) return;

    final path = Path();
    for (double x = -unit; x < size.width + unit; x += unit) {
      final s = unit / 4;
      path.moveTo(x, bottom);
      path.lineTo(x, top);
      path.lineTo(x + s * 2.5, top);
      path.lineTo(x + s * 2.5, mid);
      path.lineTo(x + s * 1.2, mid);
      path.moveTo(x + s * 1.5, bottom);
      path.lineTo(x + s * 4, bottom);
      path.lineTo(x + s * 4, top);
    }
    canvas.drawPath(path, glowPaint);

    final dotPaint = Paint()..color = color;
    for (double x = unit * 0.3; x < size.width + unit; x += unit) {
      canvas.drawCircle(
        Offset(x, bottom - (bottom - mid) * 0.45),
        1.3,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_OrnamentPainter old) =>
      old.background != background || old.color != color;
}
