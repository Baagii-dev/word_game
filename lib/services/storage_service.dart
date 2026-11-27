import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_progress.dart';

/// Тоглогчийн ахиц болон тоглолтын түүхийг төхөөрөмж дээр хадгална
/// (shared_preferences, JSON).
class StorageService extends ChangeNotifier {
  StorageService._();

  static final StorageService instance = StorageService._();

  /// "Үгийн Тулаан"-ы хуучин ахиц ('progress') шинэ бүлгүүдтэй таарахгүй тул
  /// шинэ түлхүүр ашиглана.
  static const String _key = 'progress_v2';
  static const int maxHistoryCount = 50;

  PlayerProgress progress = PlayerProgress();

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      progress = raw == null
          ? PlayerProgress()
          : PlayerProgress.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      progress = PlayerProgress(); // эвдэрсэн өгөгдөл → шинээр эхэлнэ
    }
    notifyListeners();
  }

  Future<void> saveResult({
    required int chapterId,
    required String chapterTitle,
    required bool won,
    required int score,
    required int stars,
    int wordsCount = 0,
    String longestWord = '',
  }) async {
    if (score > (progress.bestScores[chapterId] ?? 0)) {
      progress.bestScores[chapterId] = score;
    }
    if (stars > (progress.stars[chapterId] ?? 0)) {
      progress.stars[chapterId] = stars;
    }
    // Ялсан бол дараагийн бүлгийг нээнэ
    if (won && chapterId >= progress.unlockedChapter) {
      progress.unlockedChapter = chapterId + 1;
    }

    progress.history.insert(
      0,
      BattleRecord(
        chapterId: chapterId,
        chapterTitle: chapterTitle,
        won: won,
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

  /// Бүх ахицыг арилгаж эхнээс нь эхэлнэ (тохиргооноос).
  Future<void> resetAll() async {
    progress = PlayerProgress();
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
