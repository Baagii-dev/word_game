import 'package:flutter/material.dart';

import '../design/ornament_strip.dart';
import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../online/nickname_dialog.dart';
import '../online/online_models.dart';
import '../online/online_service.dart';

/// Онооны жагсаалт (leaderboard): нийт оноогоор шилдэг тоглогчид.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> _future = _load();

  Future<List<LeaderboardEntry>> _load() =>
      OnlineServices.current.topPlayers(limit: 50);

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _signIn() async {
    final p = await ensureProfile(context);
    if (p != null && mounted) await _refresh();
  }

  String _medal(int rank) => switch (rank) {
    1 => '🥇',
    2 => '🥈',
    3 => '🥉',
    _ => '$rank',
  };

  @override
  Widget build(BuildContext context) {
    final service = OnlineServices.current;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.accentLight : AppColors.navyDeep;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Онооны жагсаалт'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(18),
          child: OrnamentStrip(height: 18),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SteppeBackground(horizon: 0.8)),
          FutureBuilder<List<LeaderboardEntry>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Жагсаалтыг ачаалж чадсангүй'),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: _refresh,
                            child: const Text('Дахин оролдох'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              final list = snap.data ?? const [];
              final myUid = service.profile?.uid;
              final myIndex = list.indexWhere((e) => e.uid == myUid);

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(
                              service.isOnline
                                  ? Icons.cloud_done
                                  : Icons.cloud_off,
                              color: service.isOnline
                                  ? AppColors.playerHp
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                service.isOnline
                                    ? 'Онлайн жагсаалт'
                                    : '${service.modeLabel}: жишиг тоглогчидтой. Firebase холбосны дараа бүх тоглогч харагдана.',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (service.profile == null)
                      Card(
                        child: ListTile(
                          leading: const Text(
                            '🧑',
                            style: TextStyle(fontSize: 28),
                          ),
                          title: const Text('Жагсаалтад орох'),
                          subtitle: const Text(
                            'Ник нэрээ оруулаад оноогоо нэмүүл',
                          ),
                          trailing: FilledButton(
                            onPressed: _signIn,
                            child: const Text('Ник'),
                          ),
                        ),
                      )
                    else if (myIndex >= 0)
                      Card(
                        child: ListTile(
                          leading: const Text(
                            '🎯',
                            style: TextStyle(fontSize: 26),
                          ),
                          title: Text(
                            'Таны байр: ${myIndex + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                          ),
                          subtitle: Text('${list[myIndex].totalScore} оноо'),
                        ),
                      ),
                    const SizedBox(height: 6),
                    for (var i = 0; i < list.length; i++)
                      _EntryCard(
                        rank: _medal(i + 1),
                        entry: list[i],
                        isMe: list[i].uid == myUid,
                        titleColor: titleColor,
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.rank,
    required this.entry,
    required this.isMe,
    required this.titleColor,
  });

  final String rank;
  final LeaderboardEntry entry;
  final bool isMe;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        shape: isMe
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                side: const BorderSide(color: AppColors.accent, width: 3),
              )
            : null,
        child: ListTile(
          leading: SizedBox(
            width: 36,
            child: Text(
              rank,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
          title: Text(
            isMe ? '${entry.name} (та)' : entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w800, color: titleColor),
          ),
          subtitle: Text(
            'Ялалт: ${entry.wins} · 1v1: ${entry.duelWins} · Шилдэг: ${entry.bestScore}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Text(
            '${entry.totalScore}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),
        ),
      ),
    );
  }
}
