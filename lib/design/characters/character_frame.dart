import 'package:flutter/material.dart';

import '../theme.dart';

/// Кодоор зурсан дүрсний нийтлэг дугуй алтан хүрээ (баатар, дайсан).
class CharacterFrame extends StatelessWidget {
  const CharacterFrame({super.key, required this.size, required this.painter});

  final double size;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: ClipOval(
        child: RepaintBoundary(child: CustomPaint(painter: painter)),
      ),
    );
  }
}

/// [image] замтай PNG байвал түүнийг, хоосон эсвэл олдохгүй бол [drawn]-ыг
/// харуулна.
Widget imageOrDrawn({
  required String? image,
  required double size,
  required Widget drawn,
}) {
  if (image == null || image.isEmpty) return drawn;
  return Image.asset(
    image,
    width: size,
    height: size,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stack) => drawn,
  );
}
