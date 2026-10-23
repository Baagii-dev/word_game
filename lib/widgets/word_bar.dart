import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/letter_tile.dart';
import 'letter_tile_widget.dart';

/// Бүтээж буй үг (зурган дээрх "TRUE" мөр).
/// Үсэг дээр дарвал буцаад самбар руу орно.
class WordBar extends StatelessWidget {
  const WordBar({super.key, required this.tiles, required this.onTapTile});

  final List<LetterTile> tiles;
  final ValueChanged<LetterTile> onTapTile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFF0B2347),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.7)),
      ),
      child: tiles.isEmpty
          ? const Text(
              'Үсэг сонгож үг бүтээ',
              style: TextStyle(color: Colors.white54),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final tile in tiles)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
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
