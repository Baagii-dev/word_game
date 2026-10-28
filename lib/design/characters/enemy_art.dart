import 'package:flutter/material.dart';

/// Дайсны дүрс: зураг (`image`) байвал түүнийг, үгүй бол emoji харуулна.
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
    final emojiText = SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        child: Text(emoji, style: const TextStyle(fontSize: 100, height: 1.1)),
      ),
    );
    final path = image;
    if (path == null || path.isEmpty) return emojiText;
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => emojiText,
    );
  }
}
