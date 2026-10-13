import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Баатар эсвэл дайсны дүрс. Зураг бэлэн болтол emoji ашиглана.
/// Зураг гарвал Text(emoji)-г Image.asset(...)-аар солино.
class CharacterSprite extends StatelessWidget {
  const CharacterSprite({
    super.key,
    required this.emoji,
    required this.name,
    this.isHit = false,
    this.isDead = false,
  });

  final String emoji;
  final String name;
  final bool isHit; // цохилт авах үед жижгэрнэ
  final bool isDead; // үхвэл бүдгэрнэ

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isDead ? 0.15 : 1,
      duration: const Duration(milliseconds: 500),
      child: AnimatedScale(
        scale: isHit ? 0.8 : 1,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 76)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.woodDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
