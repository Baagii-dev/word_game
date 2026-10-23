import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Монгол "угалз" хээний тууз (дахин давтагдах мушгиа).
/// Дэлгэцийн дээд/доод ирмэгийг чимэхэд ашиглана.
class OrnamentStrip extends StatelessWidget {
  const OrnamentStrip({
    super.key,
    this.height = 22,
    this.background = AppColors.woodDark,
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
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // Дээд, доод алтан шугам
    canvas.drawLine(const Offset(0, 1.5), Offset(size.width, 1.5), line);
    canvas.drawLine(
      Offset(0, size.height - 1.5),
      Offset(size.width, size.height - 1.5),
      line,
    );

    final cell = size.height * 1.5;
    final r = size.height * 0.34;
    var i = 0;
    for (var x = cell / 2; x < size.width + cell; x += cell, i++) {
      final dir = i.isEven ? 1.0 : -1.0; // зэрэгцээ мушгиа эсрэг чиглэлтэй
      final path = Path();
      for (var t = 0.0; t <= 3 * pi; t += 0.18) {
        final rr = r * (0.18 + t / (3 * pi) * 0.82);
        final p = Offset(
          x + dir * rr * cos(t + pi),
          size.height / 2 + rr * sin(t + pi),
        );
        t == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(_OrnamentPainter old) =>
      old.background != background || old.color != color;
}
