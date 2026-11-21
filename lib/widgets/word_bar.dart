import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../models/letter_tile.dart';
import 'letter_tile_widget.dart';

/// Бүтээж буй үг. Үсэг дээр дарвал буцаад самбар руу орно.
class WordBar extends StatelessWidget {
  const WordBar({super.key, required this.tiles, required this.onTapTile});

  final List<LetterTile> tiles;
  final ValueChanged<LetterTile> onTapTile;

  @override
  Widget build(BuildContext context) {
    final active = tiles.isNotEmpty;
    return AnimatedContainer(
      duration: AppDurations.fast,
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: active ? Alignment.centerLeft : Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: active
              ? AppColors.primary.withValues(alpha: 0.75)
              : AppColors.inkLine,
          width: active ? 1.5 : 1,
        ),
      ),
      child: !active
          ? const Text(
              'Үсэг сонгож үг бүтээ',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final tile in tiles)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: LetterTileWidget(
                        key: ValueKey(tile.id),
                        tile: tile,
                        size: 42,
                        onTap: () => onTapTile(tile),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
