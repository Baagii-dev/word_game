import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../models/letter_tile.dart';

/// Нэг үсгийн хавтан. Баруун доод буланд оноо нь бичигдэнэ.
///  • алтан үсэг — шар өнгөтэй, оноо ×3
///  • эдгээх үсэг — ногоон, зүрхний тэмдэгтэй
///  • хараагдсан — бараан ягаан, цоожтой (энэ ээлжинд дарагдахгүй)
class LetterTileWidget extends StatelessWidget {
  const LetterTileWidget({
    super.key,
    required this.tile,
    this.onTap,
    this.size = 48,
    this.hidden = false,
  });

  final LetterTile tile;
  final VoidCallback? onTap;
  final double size;
  final bool hidden; // сонгогдсон үед самбар дээр бүдэг үлдэнэ

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.26);
    final cursed = tile.cursed;
    final (top, bottom, edge) = cursed
        ? (
            const Color(0xFF6B5179),
            AppColors.cursedTile,
            const Color(0xFF2A1C33),
          )
        : switch (tile.bonus) {
            TileBonus.gold => (
              const Color(0xFFFFF3B8),
              AppColors.goldTile,
              AppColors.goldTileDeep,
            ),
            TileBonus.heal => (
              const Color(0xFFE8FFF0),
              AppColors.healTile,
              AppColors.healTileDeep,
            ),
            TileBonus.none => (
              const Color(0xFFFFFBF4),
              const Color(0xFFF1E4D2),
              const Color(0xFFCDB394),
            ),
          };
    final letterColor = cursed ? Colors.white54 : AppColors.ink;

    return Semantics(
      button: true,
      label: tile.letter,
      child: GestureDetector(
        onTap: hidden ? null : onTap,
        child: AnimatedOpacity(
          opacity: hidden ? 0.14 : 1,
          duration: AppDurations.fast,
          child: AnimatedScale(
            scale: hidden ? 0.9 : 1,
            duration: AppDurations.fast,
            curve: Curves.easeOut,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [top, bottom],
                ),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                  BoxShadow(color: edge, offset: const Offset(0, 2)),
                  if (tile.bonus == TileBonus.gold && !cursed)
                    BoxShadow(
                      color: AppColors.goldTile.withValues(alpha: 0.6),
                      blurRadius: 12,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      tile.letter.toUpperCase(),
                      style: TextStyle(
                        fontSize: size * 0.46,
                        fontWeight: FontWeight.w800,
                        color: letterColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                  Positioned(
                    right: size * 0.1,
                    bottom: size * 0.06,
                    child: Text(
                      '${tile.value}',
                      style: TextStyle(
                        fontSize: size * 0.2,
                        fontWeight: FontWeight.w800,
                        color: cursed ? Colors.white38 : AppColors.bronze,
                      ),
                    ),
                  ),
                  if (cursed || tile.bonus != TileBonus.none)
                    Positioned(
                      left: size * 0.08,
                      top: size * 0.06,
                      child: Icon(
                        cursed
                            ? Icons.lock_rounded
                            : tile.bonus == TileBonus.gold
                            ? Icons.star_rounded
                            : Icons.favorite_rounded,
                        size: size * 0.22,
                        color: cursed
                            ? Colors.white70
                            : tile.bonus == TileBonus.gold
                            ? AppColors.goldTileDeep
                            : AppColors.healTileDeep,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
