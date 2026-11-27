import 'package:flutter/material.dart';

import 'theme.dart';

/// Үлгэрийн номын илгэн цаасан хуудас: шаргал градиент, бор хүрээ,
/// булангийн угалз хээ. Үлгэрийн текст, сургамжид ашиглана.
class ParchmentCard extends StatelessWidget {
  const ParchmentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 22, 22, 20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        gradient: const RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.2,
          colors: [AppColors.parchment, AppColors.parchmentDeep],
        ),
        border: Border.all(color: AppColors.parchmentEdge, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(
        painter: const _CornerOrnaments(),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Дөрвөн буланд хээ (өлзий маягийн муруй).
class _CornerOrnaments extends CustomPainter {
  const _CornerOrnaments();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.parchmentEdge.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const m = 7.0; // хүрээнээс зай
    const s = 16.0; // хээний хэмжээ
    for (final (sx, sy) in const [
      (1.0, 1.0),
      (-1.0, 1.0),
      (1.0, -1.0),
      (-1.0, -1.0),
    ]) {
      final ox = sx > 0 ? m : size.width - m;
      final oy = sy > 0 ? m : size.height - m;
      final path = Path()
        ..moveTo(ox, oy + sy * s)
        ..lineTo(ox, oy)
        ..lineTo(ox + sx * s, oy)
        ..moveTo(ox + sx * 4, oy + sy * (s - 4))
        ..quadraticBezierTo(
          ox + sx * 4,
          oy + sy * 4,
          ox + sx * (s - 4),
          oy + sy * 4,
        );
      canvas.drawPath(path, paint);
      canvas.drawCircle(
        Offset(ox + sx * 8, oy + sy * 8),
        1.8,
        paint..style = PaintingStyle.fill,
      );
      paint.style = PaintingStyle.stroke;
    }
  }

  @override
  bool shouldRepaint(_CornerOrnaments old) => false;
}

/// Үлгэрийн гарчигт тохирох текстийн хэв маяг.
class TaleText {
  static const TextStyle title = TextStyle(
    color: AppColors.parchmentInk,
    fontSize: 24,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.3,
    height: 1.15,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.parchmentInk,
    fontSize: 17,
    height: 1.55,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.parchmentInkSoft,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );
}
