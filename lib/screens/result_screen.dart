import 'package:flutter/material.dart';

import '../design/characters/enemy_art.dart';
import '../design/characters/hero_art.dart';
import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../models/level.dart';
import '../services/storage_service.dart';
import 'battle_screen.dart';

/// Ялалт / ялагдлын дэлгэц. Нээгдэх үедээ үр дүн болон түүхийг хадгална.
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.level,
    required this.won,
    required this.score,
    required this.stars,
    required this.wordsCount,
    required this.longestWord,
  });

  final Level level;
  final bool won;
  final int score;
  final int stars;
  final int wordsCount;
  final String longestWord;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // Дэлгэц зурагдаж дууссаны дараа хадгална
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StorageService.instance.saveResult(
        levelId: widget.level.id,
        levelName: widget.level.name,
        won: widget.won,
        score: widget.score,
        stars: widget.stars,
        wordsCount: widget.wordsCount,
        longestWord: widget.longestWord,
      );
    });
  }

  Level? get _nextLevel {
    for (final l in kLevels) {
      if (l.id == widget.level.id + 1) return l;
    }
    return null;
  }

  void _play(Level level) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BattleScreen(level: level)),
    );
  }

  Widget _statRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final next = _nextLevel;
    final boss = widget.level.enemies.isNotEmpty
        ? widget.level.enemies.last
        : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: widget.won ? AppColors.grass : AppColors.navyDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: SteppeBackground(
              horizon: 0.75,
              levelId: widget.won ? widget.level.id : 3,
              showGer: widget.won && widget.level.id == 1,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget.won || boss == null
                                  ? const HeroArt(size: 76)
                                  : EnemyArt(
                                      emoji: boss.emoji,
                                      image: boss.image,
                                      size: 76,
                                    ),
                              const SizedBox(height: 6),
                              Text(
                                widget.won ? 'Ялалт!' : 'Ялагдал',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.accentLight
                                      : AppColors.navyDeep,
                                ),
                              ),
                              if (widget.won)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (i) => Icon(
                                      i < widget.stars
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppColors.accent,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              _statRow('Оноо', '${widget.score}'),
                              _statRow('Бүтээсэн үг', '${widget.wordsCount}'),
                              _statRow(
                                'Хамгийн урт үг',
                                widget.longestWord.isEmpty
                                    ? '-'
                                    : widget.longestWord.toUpperCase(),
                              ),
                              const SizedBox(height: 24),
                              if (widget.won && next != null)
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () => _play(next),
                                    child: const Text('Дараагийн түвшин'),
                                  ),
                                ),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => _play(widget.level),
                                  child: const Text('Дахин тоглох'),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Түвшин сонгох'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
