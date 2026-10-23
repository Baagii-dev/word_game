import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_progress.dart';

/// Тоглогчийн ахицыг төхөөрөмж дээр хадгалах (shared_preferences, JSON).
///
/// Дараа нь Firestore руу шилжих бол `load()` болон `_persist()`-ийг л
/// өөрчлөхөд хангалттай — бусад код өөрчлөгдөхгүй.
class StorageService extends ChangeNotifier {
  StorageService._();

  static final StorageService instance = StorageService._();
  static const String _key = 'progress';

  PlayerProgress progress = PlayerProgress();

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        progress =
            PlayerProgress.fromMap(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      progress = PlayerProgress(); // эвдэрсэн өгөгдөл → шинээр эхэлнэ
    }
    notifyListeners();
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
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(progress.toMap()));
    } catch (e) {
      debugPrint('Ахиц хадгалж чадсангүй: $e');
    }
  }
}
