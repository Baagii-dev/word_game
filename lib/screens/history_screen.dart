import 'package:flutter/material.dart';

import '../design/ornament_strip.dart';
import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../models/player_progress.dart';
import '../services/storage_service.dart';

/// Тоглогчийн өмнөх тоглолтуудын түүх болон нийт статистик.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}.${two(dt.month)}.${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Түүх устгах уу?'),
        content: const Text('Өмнөх тоглолтуудын түүх устах болно.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Үгүй'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Тийм'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await StorageService.instance.clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: storage,
      builder: (context, _) {
        final history = storage.progress.history;
        final wins = history.where((r) => r.won).length;
        final bestScore = history.fold<int>(
          0,
          (m, r) => r.score > m ? r.score : m,
        );
        final longest = history.fold<String>(
          '',
          (m, r) => r.longestWord.length > m.length ? r.longestWord : m,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Тоглолтын түүх'),
            actions: [
              if (history.isNotEmpty)
                IconButton(
                  tooltip: 'Түүх арилгах',
                  onPressed: () => _confirmClear(context),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(18),
              child: OrnamentStrip(height: 18),
            ),
          ),
          body: Stack(
            children: [
              const Positioned.fill(child: SteppeBackground(horizon: 0.78)),
              history.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '📜',
                                  style: TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Одоогоор тоглолтын түүх алга',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.accentLight
                                        : AppColors.navyDeep,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Тулаанд орж тоглосны дараа үр дүн энд хадгалагдана.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Нийт үзүүлэлтийн самбар
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Wrap(
                              alignment: WrapAlignment.spaceAround,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _StatBadge(
                                  label: 'Тоглосон',
                                  value: '${history.length}',
                                  isDark: isDark,
                                ),
                                _StatBadge(
                                  label: 'Ялалт',
                                  value: '$wins',
                                  isDark: isDark,
                                ),
                                _StatBadge(
                                  label: 'Дээд оноо',
                                  value: '$bestScore',
                                  isDark: isDark,
                                ),
                                _StatBadge(
                                  label: 'Урт үг',
                                  value: longest.isEmpty
                                      ? '-'
                                      : longest.toUpperCase(),
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final record in history)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RecordCard(
                              record: record,
                              dateText: _formatDate(record.playedAt),
                              isDark: isDark,
                            ),
                          ),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.accentLight : AppColors.navyDeep,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.dateText,
    required this.isDark,
  });

  final BattleRecord record;
  final String dateText;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final wordText = record.longestWord.isEmpty
        ? '-'
        : record.longestWord.toUpperCase();

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: record.won ? AppColors.playerHp : AppColors.enemyHp,
          child: Text(
            record.won ? '🏆' : '💀',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${record.levelId}. ${record.levelName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accentLight : AppColors.navyDeep,
                ),
              ),
            ),
            if (record.won)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (s) => Icon(
                    s < record.stars ? Icons.star : Icons.star_border,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          'Оноо: ${record.score} · Үг: ${record.wordsCount} · Урт үг: $wordText\n$dateText',
          style: const TextStyle(fontSize: 12, height: 1.35),
        ),
      ),
    );
  }
}
