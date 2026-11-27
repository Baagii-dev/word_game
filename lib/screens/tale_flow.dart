import 'package:flutter/material.dart';

import '../models/chapter.dart';
import '../services/storage_service.dart';
import 'battle_screen.dart';
import 'result_screen.dart';
import 'story_screen.dart';

/// Нэг үлгэрийн урсгал нэг дор:
///
///   эхлэлийн хуудсууд → тулаан → (ялбал) төгсгөлийн хуудсууд → үр дүн
///                              → (ялагдвал) үр дүн
///
/// Дэлгэцүүд бие биеэ шууд дуудахгүй, энд байгаа функцуудыг дуудна.
class TaleFlow {
  /// Үлгэрийг эхнээс нь (эхлэлийн хуудаснаас) эхлүүлнэ.
  static Future<void> start(
    BuildContext context,
    Chapter chapter, {
    bool replace = false,
  }) {
    final route = MaterialPageRoute<void>(
      builder: (_) => StoryScreen(
        chapter: chapter,
        outro: false,
        onFinished: (ctx) => battle(ctx, chapter, replace: true),
      ),
    );
    return replace
        ? Navigator.pushReplacement(context, route)
        : Navigator.push(context, route);
  }

  /// Шууд тулаанд оруулна (дахин тоглоход үлгэрийг алгасна).
  static Future<void> battle(
    BuildContext context,
    Chapter chapter, {
    bool replace = false,
  }) {
    final route = MaterialPageRoute<void>(
      builder: (_) => BattleScreen(chapter: chapter),
    );
    return replace
        ? Navigator.pushReplacement(context, route)
        : Navigator.push(context, route);
  }

  /// Тулаан дууссаны дараа: ахицыг шууд хадгалаад (төгсгөлийн хуудсыг
  /// алгасаж гарсан ч алдагдахгүй), ялбал үлгэрийн төгсгөл, дараа нь үр дүн.
  static void finishBattle(BuildContext context, BattleOutcome outcome) {
    StorageService.instance.saveResult(
      chapterId: outcome.chapter.id,
      chapterTitle: outcome.chapter.title,
      won: outcome.won,
      score: outcome.score,
      stars: outcome.stars,
      wordsCount: outcome.wordsCount,
      longestWord: outcome.longestWord,
    );
    final result = MaterialPageRoute<void>(
      builder: (_) => ResultScreen(outcome: outcome),
    );
    if (!outcome.won || outcome.chapter.outro.isEmpty) {
      Navigator.pushReplacement(context, result);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => StoryScreen(
          chapter: outcome.chapter,
          outro: true,
          onFinished: (ctx) => Navigator.pushReplacement(ctx, result),
        ),
      ),
    );
  }
}

/// Тулааны үр дүн (ResultScreen-д дамжуулна).
class BattleOutcome {
  const BattleOutcome({
    required this.chapter,
    required this.won,
    required this.score,
    required this.stars,
    required this.wordsCount,
    required this.longestWord,
  });

  final Chapter chapter;
  final bool won;
  final int score;
  final int stars;
  final int wordsCount;
  final String longestWord;
}
