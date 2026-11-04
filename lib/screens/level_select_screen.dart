import 'package:flutter/material.dart';

import '../design/characters/enemy_art.dart';
import '../design/ornament_strip.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Түвшин сонгох'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(18),
          child: OrnamentStrip(height: 18),
        ),
      ),
      // Ахиц өөрчлөгдөхөд (түвшин нээгдэх, од) жагсаалт автоматаар шинэчлэгдэнэ
      body: Stack(
        children: [
          const Positioned.fill(child: SteppeBackground(horizon: 0.78)),
          ListenableBuilder(
            listenable: storage,
            builder: (context, _) {
              final progress = storage.progress;
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: kLevels.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final level = kLevels[i];
                  final locked = level.id > progress.unlockedLevel;
                  final stars = progress.stars[level.id] ?? 0;
                  final best = progress.bestScores[level.id];
                  final boss = level.enemies.last;

                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: locked
                                ? [Colors.grey.shade500, Colors.grey.shade700]
                                : [AppColors.accentLight, AppColors.accent],
                          ),
                          border: Border.all(
                            color: locked
                                ? Colors.grey.shade700
                                : AppColors.tileShadow,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: locked
                            ? const Icon(Icons.lock, color: Colors.white)
                            : EnemyArt(
                                emoji: boss.emoji,
                                image: boss.image,
                                size: 36,
                              ),
                      ),
                      title: Text(
                        '${level.id}. ${level.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.accentLight
                              : AppColors.navyDeep,
                        ),
                      ),
                      subtitle: Text(
                        locked
                            ? 'Өмнөх түвшнийг давж нээнэ'
                            : '${level.description} · ${level.waveCount} дайсан'
                                  '${best != null ? '\nШилдэг оноо: $best' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          3,
                          (s) => Icon(
                            s < stars ? Icons.star : Icons.star_border,
                            size: 22,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      onTap: locked
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BattleScreen(level: level),
                              ),
                            ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
