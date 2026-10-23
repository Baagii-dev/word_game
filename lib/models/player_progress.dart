/// Хадгалагдах ахиц: аль түвшин нээгдсэн, түвшин бүрийн шилдэг оноо, од.
class PlayerProgress {
  PlayerProgress({
    this.unlockedLevel = 1,
    Map<int, int>? bestScores,
    Map<int, int>? stars,
  }) : bestScores = bestScores ?? {},
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
    Map<int, int> toIntMap(dynamic raw) => (raw as Map? ?? {}).map(
      (k, v) => MapEntry(int.parse('$k'), (v as num).toInt()),
    );

    return PlayerProgress(
      unlockedLevel: (map['unlockedLevel'] as num?)?.toInt() ?? 1,
      bestScores: toIntMap(map['bestScores']),
      stars: toIntMap(map['stars']),
    );
  }
}
