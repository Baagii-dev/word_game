/// Хадгалагдах ахиц: аль түвшин нээгдсэн, түвшин бүрийн шилдэг оноо, од.
class PlayerProgress {
  PlayerProgress({
    int? unlockedLevel,
    Map<int, int>? bestScores,
    Map<int, int>? stars,
  }) : unlockedLevel = unlockedLevel ?? 1,
       bestScores = bestScores ?? {},
       stars = stars ?? {};

  int unlockedLevel;
  final Map<int, int> bestScores; // түвшний id → оноо
  final Map<int, int> stars; // түвшний id → 0..3 од

  /// NoSQL (Hive / Firestore) руу хадгалахад бэлэн Map хэлбэр.
  Map<String, dynamic> toMap() => {
    'unlockedLevel': unlockedLevel,
    'bestScores': bestScores.map((k, v) => MapEntry('$k', v)),
    'stars': stars.map((k, v) => MapEntry('$k', v)),
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

    return PlayerProgress(
      unlockedLevel: (map['unlockedLevel'] as num?)?.toInt() ?? 1,
      bestScores: toIntMap(map['bestScores']),
      stars: toIntMap(map['stars']),
    );
  }
}
