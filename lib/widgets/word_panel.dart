import 'package:flutter/material.dart';

import '../design/ornament_strip.dart';
import '../design/theme.dart';
import '../models/letter_tile.dart';
import 'letter_grid.dart';
import 'shake_widget.dart';
import 'word_bar.dart';

/// Доод самбар: бүтээж буй үг, үсгийн самбар, "Холих" ба "Довтлох" товчнууд.
/// 1v1 тулаанд ашиглана (ердийн тулаан өөрийн хувилбартай хэвээр).
class WordPanel extends StatelessWidget {
  const WordPanel({
    super.key,
    required this.board,
    required this.selected,
    required this.enabled,
    required this.combo,
    required this.previewDamage,
    required this.invalidCount,
    required this.onSelect,
    required this.onDeselect,
    required this.onClear,
    required this.onShuffle,
    required this.onAttack,
  });

  final List<LetterTile> board;
  final List<LetterTile> selected;
  final bool enabled;
  final int combo;
  final int previewDamage;
  final int invalidCount;
  final ValueChanged<LetterTile> onSelect;
  final ValueChanged<LetterTile> onDeselect;
  final VoidCallback onClear;
  final VoidCallback onShuffle;
  final VoidCallback onAttack;

  @override
  Widget build(BuildContext context) {
    final canAttack = enabled && selected.isNotEmpty;
    const outline = BorderSide(color: Colors.white70);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.navyDark, AppColors.navyDeep],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OrnamentStrip(height: 18, background: AppColors.navy),
          Padding(
            padding: EdgeInsets.fromLTRB(
              10,
              10,
              10,
              10 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ShakeWidget(
                        trigger: invalidCount,
                        child: WordBar(tiles: selected, onTapTile: onDeselect),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: canAttack ? onClear : null,
                      icon: const Icon(Icons.backspace),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LetterGrid(tiles: board, onTap: onSelect),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: enabled ? onShuffle : null,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Холих'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: outline,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          combo > 0
                              ? '🔥$combo  ⚔ $previewDamage'
                              : '⚔ $previewDamage',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: canAttack ? onAttack : null,
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Довтлох'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.text,
                        disabledBackgroundColor: Colors.white.withValues(
                          alpha: 0.16,
                        ),
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
