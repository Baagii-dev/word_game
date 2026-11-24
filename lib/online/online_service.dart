import 'package:flutter/foundation.dart';

import 'online_models.dart';

/// Онлайн боломжуудын нэгдсэн интерфэйс: нэвтрэлт, онооны жагсаалт, 1v1.
///
/// Хоёр хэрэгжүүлэлттэй:
///  • [LocalOnlineService] — санах ойд (интернэт/Firebase шаардахгүй, bot өрсөлдөгчтэй)
///  • Firebase-ийн хэрэгжүүлэлт (Firestore) — төсөл холбогдсоны дараа
abstract class OnlineService extends ChangeNotifier {
  /// Жинхэнэ сервертэй холбогдсон эсэх. `false` бол офлайн (демо) горим.
  bool get isOnline;

  /// Дэлгэц дээр харуулах горимын нэр.
  String get modeLabel;

  /// Нэвтэрсэн тоглогч (ник өгөөгүй бол `null`).
  PlayerProfile? get profile;

  /// Ник өгч нэвтэрнэ (анх удаа бол бүртгэнэ).
  Future<PlayerProfile> signIn(String nickname);

  /// Тулааны дүнг онооны жагсаалтад нэмнэ. Нэвтрээгүй бол юу ч хийхгүй.
  Future<void> submitResult({required int score, required bool won});

  /// Өмнөх тоглолтуудын нийлбэрийг анх удаа нэвтрэх үед жагсаалтад оруулна.
  Future<void> syncHistory({
    required int totalScore,
    required int wins,
    required int bestScore,
  });

  /// Нийт оноогоор эрэмбэлсэн шилдэг тоглогчид.
  Future<List<LeaderboardEntry>> topPlayers({int limit = 50});

  /// Өрсөлдөгч хайна.
  DuelSearch findDuel();

  /// 1v1-д ялсныг бүртгэнэ.
  Future<void> submitDuelResult({required bool won, required int score});
}

/// Апп даяар ашиглах онлайн үйлчилгээ. `main.dart` дээр тохируулна.
class OnlineServices {
  static OnlineService? _current;

  static OnlineService get current {
    final c = _current;
    if (c == null) {
      throw StateError('OnlineServices.use(...) дуудаагүй байна');
    }
    return c;
  }

  static bool get isReady => _current != null;

  static void use(OnlineService service) => _current = service;
}
