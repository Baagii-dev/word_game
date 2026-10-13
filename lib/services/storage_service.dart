import 'package:flutter/foundation.dart';

import '../models/player_progress.dart';

/// Тоглогчийн ахицыг хадгалах.
///
/// Одоогоор зөвхөн санах ойд (апп хаавал устна).
/// Hive эсвэл Firestore сонгосны дараа `load()` болон `_persist()`-ийг л
/// өөрчлөхөд хангалттай — бусад код өөрчлөгдөхгүй.
class StorageService extends ChangeNotifier {
  StorageService._();

  static final StorageService instance = StorageService._();

  PlayerProgress progress = PlayerProgress();

  Future<void> load() async {
    // TODO: Hive жишээ:
    //   final box = await Hive.openBox('progress');
    //   final map = box.get('data');
    //   if (map != null) progress = PlayerProgress.fromMap(Map<String, dynamic>.from(map));
  }

  Future<void> saveResult({
    required int levelId,
    required int score,
    required int stars,
  }) async {
    if (score > (progress.bestScores[levelId] ?? 0)) {
      progress.bestScores[levelId] = score;
    }
    if (stars > (progress.stars[levelId] ?? 0)) {
      progress.stars[levelId] = stars;
    }
    // Ялсан бол дараагийн түвшнийг нээнэ
    if (stars > 0 && levelId >= progress.unlockedLevel) {
      progress.unlockedLevel = levelId + 1;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    // TODO: Hive:      await Hive.box('progress').put('data', progress.toMap());
    // TODO: Firestore: await FirebaseFirestore.instance
    //                    .collection('players').doc(uid).set(progress.toMap());
  }
}
