import 'package:flutter/material.dart';

import '../models/letter_tile.dart';
import 'letter_tile_widget.dart';

/// Доод талын үсгийн самбар (6 багана × 2 мөр).
class LetterGrid extends StatelessWidget {
  const LetterGrid({super.key, required this.tiles, required this.onTap});

  final List<LetterTile> tiles;
  final ValueChanged<LetterTile> onTap;

  static const int columns = 6;
  static const double gap = 6;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Дэлгэцийн өргөнөөс хавтангийн хэмжээг тооцно
        final size = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles)
              LetterTileWidget(
                key: ValueKey(tile.id),
                tile: tile,
                size: size,
                hidden: tile.isSelected,
                onTap: () => onTap(tile),
              ),
          ],
        );
      },
    );
  }
}
