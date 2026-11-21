import 'package:flutter/material.dart';

import '../design/characters/enemy_art.dart';
import '../design/characters/hero_art.dart';
import '../design/glass.dart';
import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../models/level.dart';
import '../services/storage_service.dart';
import '../widgets/game_button.dart';
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
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
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
          const Positioned.fill(child: ScrimOverlay(top: 0.3, bottom: 0.6)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: GlassPanel(
                          padding: const EdgeInsets.all(24),
                          radius: AppSizes.radiusXl,
                          opacity: 0.6,
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
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              if (widget.won)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (i) => Icon(
                                      Icons.star_rounded,
                                      color: i < widget.stars
                                          ? AppColors.accent
                                          : Colors.white.withValues(
                                              alpha: 0.18,
                                            ),
                                      size: i == 1 ? 52 : 42,
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
                              if (widget.won && next != null) ...[
                                GameButton(
                                  label: 'Дараагийн түвшин',
                                  icon: Icons.arrow_forward_rounded,
                                  onPressed: () => _play(next),
                                ),
                                const SizedBox(height: 10),
                              ],
                              GameButton(
                                label: 'Дахин тоглох',
                                icon: Icons.replay_rounded,
                                glass: widget.won && next != null,
                                colors: widget.won
                                    ? const [
                                        AppColors.primary,
                                        AppColors.primaryEnd,
                                      ]
                                    : const [
                                        AppColors.bronze,
                                        AppColors.bronzeDeep,
                                      ],
                                onPressed: () => _play(widget.level),
                              ),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                ),
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
