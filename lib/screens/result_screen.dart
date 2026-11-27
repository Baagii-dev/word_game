import 'package:flutter/material.dart';

import '../design/characters/enemy_art.dart';
import '../design/characters/hero_art.dart';
import '../design/glass.dart';
import '../design/scene_background.dart';
import '../design/theme.dart';
import '../models/chapter.dart';
import '../widgets/game_button.dart';
import 'tale_flow.dart';

/// Ялалт / ялагдлын дэлгэц. (Ахиц TaleFlow.finishBattle-д аль хэдийн хадгалагдсан.)
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.outcome});

  final BattleOutcome outcome;

  Chapter? get _next => chapterById(outcome.chapter.id + 1);

  Widget _statRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
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
    final chapter = outcome.chapter;
    final won = outcome.won;
    final next = _next;
    final boss = chapter.boss;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SceneBackground(
              scene: won ? chapter.scene : Scene.cave,
              horizon: 0.75,
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
                              won
                                  ? const HeroArt(size: 76)
                                  : EnemyArt(
                                      kind: boss.kind,
                                      image: boss.image,
                                      size: 76,
                                    ),
                              const SizedBox(height: 6),
                              Text(
                                won ? 'Үлгэр сэргэлээ!' : 'Ялагдал',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                chapter.title,
                                style: const TextStyle(
                                  color: AppColors.accentLight,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (won)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (i) => Icon(
                                      Icons.star_rounded,
                                      color: i < outcome.stars
                                          ? AppColors.accent
                                          : Colors.white.withValues(
                                              alpha: 0.18,
                                            ),
                                      size: i == 1 ? 52 : 42,
                                    ),
                                  ),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Мангас энэ удаад давлаа. Үгээ дайчлаад дахин оролдоорой!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              _statRow('Оноо', '${outcome.score}'),
                              _statRow('Бүтээсэн үг', '${outcome.wordsCount}'),
                              _statRow(
                                'Хамгийн урт үг',
                                outcome.longestWord.isEmpty
                                    ? '-'
                                    : outcome.longestWord.toUpperCase(),
                              ),
                              if (won && chapter.moral.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  '“${chapter.moral}”',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              if (won && next == null) ...[
                                const SizedBox(height: 12),
                                const Text(
                                  '🎉 Та бүх үлгэрийг мангасаас авралаа!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.accentLight,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              if (won && next != null) ...[
                                GameButton(
                                  label: 'Дараагийн үлгэр',
                                  icon: Icons.auto_stories_rounded,
                                  onPressed: () => TaleFlow.start(
                                    context,
                                    next,
                                    replace: true,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              GameButton(
                                label: 'Дахин тоглох',
                                icon: Icons.replay_rounded,
                                glass: won && next != null,
                                colors: won
                                    ? const [
                                        AppColors.primary,
                                        AppColors.primaryEnd,
                                      ]
                                    : const [
                                        AppColors.bronze,
                                        AppColors.bronzeDeep,
                                      ],
                                onPressed: () => TaleFlow.battle(
                                  context,
                                  chapter,
                                  replace: true,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                ),
                                child: const Text('Үлгэрийн ном руу'),
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
