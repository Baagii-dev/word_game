/// Нэг тулааны түүхийн бичлэг.
class BattleRecord {
  BattleRecord({
    required this.chapterId,
    required this.chapterTitle,
    required this.won,
    required this.score,
    required this.stars,
    this.wordsCount = 0,
    this.longestWord = '',
    DateTime? playedAt,
  }) : playedAt = playedAt ?? DateTime.now();

  final int chapterId;
  final String chapterTitle;
  final bool won;
  final int score;
  final int stars;
  final int wordsCount;
  final String longestWord;
  final DateTime playedAt;

  Map<String, dynamic> toMap() => {
    'chapterId': chapterId,
    'chapterTitle': chapterTitle,
    'won': won,
    'score': score,
    'stars': stars,
    'wordsCount': wordsCount,
    'longestWord': longestWord,
    'playedAt': playedAt.toIso8601String(),
  };

  factory BattleRecord.fromMap(Map<String, dynamic> map) => BattleRecord(
    chapterId: (map['chapterId'] as num?)?.toInt() ?? 1,
    chapterTitle: map['chapterTitle'] as String? ?? 'Үлгэр',
    won: map['won'] as bool? ?? false,
    score: (map['score'] as num?)?.toInt() ?? 0,
    stars: (map['stars'] as num?)?.toInt() ?? 0,
    wordsCount: (map['wordsCount'] as num?)?.toInt() ?? 0,
    longestWord: map['longestWord'] as String? ?? '',
    playedAt:
        DateTime.tryParse(map['playedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

/// Хадгалагдах ахиц: аль бүлэг нээгдсэн, бүлэг бүрийн шилдэг оноо, од, түүх.
class PlayerProgress {
  PlayerProgress({
    int? unlockedChapter,
    Map<int, int>? bestScores,
    Map<int, int>? stars,
    List<BattleRecord>? history,
  }) : unlockedChapter = unlockedChapter ?? 1,
       bestScores = bestScores ?? {},
       stars = stars ?? {},
       history = history ?? [];

  int unlockedChapter;
  final Map<int, int> bestScores; // бүлгийн id → оноо
  final Map<int, int> stars; // бүлгийн id → 0..3 од
  final List<BattleRecord>
  history; // сүүлд тоглосон тулаанууд (шинэ нь эхэндээ)

  int get totalStars => stars.values.fold(0, (s, v) => s + v);

  Map<String, dynamic> toMap() => {
    'unlockedChapter': unlockedChapter,
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
        if (k != null && v is num) result[k] = v.toInt();
      }
      return result;
    }

    final historyList = <BattleRecord>[];
    final rawHistory = map['history'];
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
      unlockedChapter: (map['unlockedChapter'] as num?)?.toInt() ?? 1,
      bestScores: toIntMap(map['bestScores']),
      stars: toIntMap(map['stars']),
      history: historyList,
    );
  }
}
