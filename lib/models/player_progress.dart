/// Нэг тулааны түүхийн бичлэг.
class BattleRecord {
  BattleRecord({
    required this.levelId,
    required this.levelName,
    required this.won,
    required this.score,
    required this.stars,
    this.wordsCount = 0,
    this.longestWord = '',
    DateTime? playedAt,
  }) : playedAt = playedAt ?? DateTime.now();

  final int levelId;
  final String levelName;
  final bool won;
  final int score;
  final int stars;
  final int wordsCount;
  final String longestWord;
  final DateTime playedAt;

  Map<String, dynamic> toMap() => {
    'levelId': levelId,
    'levelName': levelName,
    'won': won,
    'score': score,
    'stars': stars,
    'wordsCount': wordsCount,
    'longestWord': longestWord,
    'playedAt': playedAt.toIso8601String(),
  };

  factory BattleRecord.fromMap(Map<String, dynamic> map) => BattleRecord(
    levelId: (map['levelId'] as num?)?.toInt() ?? 1,
    levelName: map['levelName'] as String? ?? 'Түвшин',
    won: map['won'] as bool? ?? false,
    score: (map['score'] as num?)?.toInt() ?? 0,
    stars: (map['stars'] as num?)?.toInt() ?? 0,
    wordsCount: (map['wordsCount'] as num?)?.toInt() ?? 0,
    longestWord: map['longestWord'] as String? ?? '',
    playedAt:
        DateTime.tryParse(map['playedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

/// Хадгалагдах ахиц: аль түвшин нээгдсэн, түвшин бүрийн шилдэг оноо, од, түүх.
class PlayerProgress {
  PlayerProgress({
    int? unlockedLevel,
    Map<int, int>? bestScores,
    Map<int, int>? stars,
    List<BattleRecord>? history,
  }) : unlockedLevel = unlockedLevel ?? 1,
       bestScores = bestScores ?? {},
       stars = stars ?? {},
       history = history ?? [];

  int unlockedLevel;
  final Map<int, int> bestScores; // түвшний id → оноо
  final Map<int, int> stars; // түвшний id → 0..3 од
  final List<BattleRecord> history; // сүүлд тоглосон тулаанууд (эхэндээ шинэ нь)

  /// NoSQL (Hive / Firestore) руу хадгалахад бэлэн Map хэлбэр.
  Map<String, dynamic> toMap() => {
    'unlockedLevel': unlockedLevel,
    'bestScores': bestScores.map((k, v) => MapEntry('$k', v)),
    'stars': stars.map((k, v) => MapEntry('$k', v)),
    'history': history.map((h) => h.toMap()).toList(),
  };

  factory PlayerProgress.fromMap(Map<String, dynamic> map) {
    Map<int, int> toIntMap(dynamic raw) {
      if (raw is! Map) return {};
      final result = <int, int>{};
      for (final entry in raw.entries) {
        final k = int.tryParse('${entry.key}');
        final v = entry.value;
        if (k != null && v is num) {
          result[k] = v.toInt();
        }
      }
      return result;
    }

    final rawHistory = map['history'];
    final historyList = <BattleRecord>[];
    if (rawHistory is List) {
      for (final item in rawHistory) {
        if (item is Map) {
          historyList.add(
            BattleRecord.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return PlayerProgress(
      unlockedLevel: (map['unlockedLevel'] as num?)?.toInt() ?? 1,
      bestScores: toIntMap(map['bestScores']),
      stars: toIntMap(map['stars']),
      history: historyList,
    );
  }
}
