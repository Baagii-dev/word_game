import 'package:flutter/material.dart';

import '../design/characters/enemy_art.dart';
import '../design/glass.dart';
import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../models/level.dart';
import '../services/storage_service.dart';
import 'battle_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Түвшин сонгох')),
      // Ахиц өөрчлөгдөхөд (түвшин нээгдэх, од) жагсаалт автоматаар шинэчлэгдэнэ
      body: Stack(
        children: [
          const Positioned.fill(child: SteppeBackground(horizon: 0.78)),
          const Positioned.fill(child: ScrimOverlay(top: 0.55, bottom: 0.5)),
          SafeArea(
            child: ListenableBuilder(
              listenable: storage,
              builder: (context, _) {
                final progress = storage.progress;
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: kLevels.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final level = kLevels[i];
                    return _LevelCard(
                      level: level,
                      locked: level.id > progress.unlockedLevel,
                      stars: progress.stars[level.id] ?? 0,
                      best: progress.bestScores[level.id],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.locked,
    required this.stars,
    required this.best,
  });

  final Level level;
  final bool locked;
  final int stars;
  final int? best;

  @override
  Widget build(BuildContext context) {
    final boss = level.enemies.isNotEmpty ? level.enemies.last : null;

    return Opacity(
      opacity: locked ? 0.7 : 1,
      child: GlassPanel(
        padding: EdgeInsets.zero,
        opacity: 0.55,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: locked
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BattleScreen(level: level),
                    ),
                  ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Дайсны дүрс эсвэл цоож
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      gradient: locked
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.bronze, AppColors.primaryEnd],
                            ),
                      color: locked
                          ? Colors.white.withValues(alpha: 0.08)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: locked || boss == null
                        ? Icon(
                            locked ? Icons.lock_rounded : Icons.flag_rounded,
                            color: Colors.white70,
                          )
                        : EnemyArt(
                            emoji: boss.emoji,
                            image: boss.image,
                            size: 40,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${level.id}. ${level.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          locked
                              ? 'Өмнөх түвшнийг давж нээнэ'
                              : '${level.description} · ${level.waveCount} дайсан',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                        if (!locked && best != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Шилдэг оноо: $best',
                              style: const TextStyle(
                                color: AppColors.accentLight,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (s) => Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: s < stars
                            ? AppColors.accent
                            : Colors.white.withValues(alpha: 0.18),
                      ),
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
