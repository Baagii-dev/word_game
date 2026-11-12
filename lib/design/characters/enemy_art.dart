import 'package:flutter/material.dart';

import '../theme.dart';

/// Дайсны дүрс: зураг (`image`) байвал PNG зургийг,
/// үгүй бол вектороор зурахгүйгээр эможи дүрсийг гоё хүрээтэй харуулна.
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
    final badge = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF6B232B),
            Color(0xFF3B1219),
            AppColors.navyDeep,
          ],
        ),
        border: Border.all(color: AppColors.accent, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: FittedBox(
        child: Text(emoji, style: const TextStyle(fontSize: 80, height: 1.1)),
      ),
    );

    final path = image;
    if (path == null || path.isEmpty) return badge;

    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => badge,
    );
  }
}
