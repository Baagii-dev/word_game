import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/level.dart';
import '../services/storage_service.dart';
import '../widgets/ornament_strip.dart';
import '../widgets/steppe_background.dart';
import 'battle_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;

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
          const Positioned.fill(child: SteppeBackground(horizon: 0.8)),
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

                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: locked
                            ? Colors.grey
                            : AppColors.accent,
                        child: locked
                            ? const Icon(Icons.lock, color: Colors.white)
                            : Text('${level.id}'),
                      ),
                      title: Text(level.name),
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
                            size: 20,
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
