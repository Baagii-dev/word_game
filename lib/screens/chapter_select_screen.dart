import 'package:flutter/material.dart';

import '../design/characters/enemy_art.dart';
import '../design/glass.dart';
import '../design/scene_background.dart';
import '../design/theme.dart';
import '../models/chapter.dart';
import '../services/storage_service.dart';
import 'tale_flow.dart';

/// Үлгэрийн ном: бүлгүүдийг замын дагуу харуулна. Түгжээтэй бүлэг өмнөхөө
/// давахад нээгдэнэ. Давсан бүлгийг дахин уншиж эсвэл шууд тулалдаж болно.
class ChapterSelectScreen extends StatelessWidget {
  const ChapterSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Үлгэрийн ном')),
      body: Stack(
        children: [
          const Positioned.fill(child: SceneBackground(horizon: 0.78)),
          const Positioned.fill(child: ScrimOverlay(top: 0.55, bottom: 0.5)),
          SafeArea(
            child: ListenableBuilder(
              listenable: storage,
              builder: (context, _) {
                final progress = storage.progress;
                final maxStars = kChapters.length * 3;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Center(
                      child: GlassPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        opacity: 0.35,
                        child: Text(
                          '⭐ ${progress.totalStars}/$maxStars',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < kChapters.length; i++) ...[
                      if (i > 0) const _PathLink(),
                      _ChapterCard(
                        chapter: kChapters[i],
                        locked: kChapters[i].id > progress.unlockedChapter,
                        stars: progress.stars[kChapters[i].id] ?? 0,
                        best: progress.bestScores[kChapters[i].id],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Бүлгүүдийг холбосон цэгэн зам.
class _PathLink extends StatelessWidget {
  const _PathLink();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (_) => Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.locked,
    required this.stars,
    required this.best,
  });

  final Chapter chapter;
  final bool locked;
  final int stars;
  final int? best;

  bool get _cleared => stars > 0;

  @override
  Widget build(BuildContext context) {
    final boss = chapter.boss;

    return Opacity(
      opacity: locked ? 0.7 : 1,
      child: GlassPanel(
        padding: EdgeInsets.zero,
        opacity: 0.55,
        borderColor: _cleared
            ? AppColors.accent.withValues(alpha: 0.6)
            : AppColors.inkLine,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: locked ? null : () => TaleFlow.start(context, chapter),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Бүлгийн дүр зураг + гол дайсан, эсвэл цоож
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: SceneBackground(
                        scene: chapter.scene,
                        horizon: 0.7,
                        child: Center(
                          child: locked
                              ? Container(
                                  color: Colors.black45,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white70,
                                  ),
                                )
                              : EnemyArt(
                                  kind: boss.kind,
                                  image: boss.image,
                                  size: 44,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${chapter.id}-р үлгэр',
                          style: const TextStyle(
                            color: AppColors.accentLight,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          chapter.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          locked
                              ? 'Өмнөх үлгэрийг сэргээж нээнэ'
                              : '${chapter.subtitle} · ${chapter.waveCount} дайсан',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                        if (!locked) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ...List.generate(
                                3,
                                (s) => Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: s < stars
                                      ? AppColors.accent
                                      : Colors.white.withValues(alpha: 0.18),
                                ),
                              ),
                              if (best != null) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Шилдэг: $best',
                                    overflow: TextOverflow.ellipsis,
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
                        ],
                      ],
                    ),
                  ),
                  if (_cleared)
                    IconButton(
                      tooltip: 'Үлгэрийг алгасаад шууд тулалдах',
                      onPressed: () => TaleFlow.battle(context, chapter),
                      icon: const Icon(Icons.flash_on_rounded),
                      color: Colors.white,
                    )
                  else if (!locked)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white70,
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
