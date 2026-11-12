import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_progress.dart';

/// Тоглогчийн ахиц болон тоглолтын түүхийг төхөөрөмж дээр хадгалах (shared_preferences, JSON).
class StorageService extends ChangeNotifier {
  StorageService._();

  static final StorageService instance = StorageService._();
  static const String _key = 'progress';
  static const int maxHistoryCount = 50;

  PlayerProgress progress = PlayerProgress();

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        progress = PlayerProgress.fromMap(
          jsonDecode(raw) as Map<String, dynamic>,
        );
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
    String? levelName,
    bool? won,
    int wordsCount = 0,
    String longestWord = '',
  }) async {
    final isWin = won ?? (stars > 0);

    if (score > (progress.bestScores[levelId] ?? 0)) {
      progress.bestScores[levelId] = score;
    }
    if (stars > (progress.stars[levelId] ?? 0)) {
      progress.stars[levelId] = stars;
    }
    // Ялсан бол дараагийн түвшнийг нээнэ
    if (isWin && levelId >= progress.unlockedLevel) {
      progress.unlockedLevel = levelId + 1;
    }

    // Түүхэнд нэмэх (хамгийн шинэ нь эхэндээ)
    progress.history.insert(
      0,
      BattleRecord(
        levelId: levelId,
        levelName: levelName ?? 'Түвшин $levelId',
        won: isWin,
        score: score,
        stars: stars,
        wordsCount: wordsCount,
        longestWord: longestWord,
      ),
    );
    if (progress.history.length > maxHistoryCount) {
      progress.history.removeRange(maxHistoryCount, progress.history.length);
    }

    notifyListeners();
    await _persist();
  }

  Future<void> clearHistory() async {
    progress.history.clear();
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
