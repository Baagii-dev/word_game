/// Онлайн боломжийн (leaderboard, 1v1) өгөгдлийн бүтцүүд.
/// Backend нь (санах ой / Firebase) эдгээрээр дамжуулан харилцана.
library;

/// Нэвтэрсэн тоглогч. Зөвхөн ник хадгална (и-мэйл хадгалахгүй).
class PlayerProfile {
  const PlayerProfile({required this.uid, required this.name});

  final String uid;
  final String name;
}

/// Онооны жагсаалтын нэг мөр.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.totalScore,
    this.wins = 0,
    this.bestScore = 0,
    this.duelWins = 0,
  });

  final String uid;
  final String name;
  final int totalScore; // нийт оноо (эрэмбэлэх гол үзүүлэлт)
  final int wins; // ялсан тулааны тоо
  final int bestScore; // нэг тулааны шилдэг оноо
  final int duelWins; // 1v1-д ялсан тоо
}

enum DuelStatus { active, finished }

/// 1v1 тулааны одоогийн байдал (backend-ээс ирнэ).
class DuelSnapshot {
  const DuelSnapshot({
    required this.status,
    required this.myUid,
    required this.myHp,
    required this.opponentHp,
    required this.maxHp,
    required this.opponentName,
    this.opponentLastWord,
    this.opponentHits = 0,
    this.winnerUid,
  });

  final DuelStatus status;
  final String myUid;
  final int myHp;
  final int opponentHp;
  final int maxHp;
  final String opponentName;
  final String? opponentLastWord; // өрсөлдөгчийн сүүлд бүтээсэн үг
  final int opponentHits; // өрсөлдөгчийн цохилтын тоо (анимацид)

  /// Дууссан үед ялагч. `null` бол тэнцсэн.
  final String? winnerUid;

  bool get finished => status == DuelStatus.finished;
  bool get iWon => finished && winnerUid == myUid;
  bool get draw => finished && winnerUid == null;

  DuelSnapshot copyWith({
    DuelStatus? status,
    int? myHp,
    int? opponentHp,
    String? opponentLastWord,
    int? opponentHits,
    String? winnerUid,
    bool clearWinner = false,
  }) => DuelSnapshot(
    status: status ?? this.status,
    myUid: myUid,
    myHp: myHp ?? this.myHp,
    opponentHp: opponentHp ?? this.opponentHp,
    maxHp: maxHp,
    opponentName: opponentName,
    opponentLastWord: opponentLastWord ?? this.opponentLastWord,
    opponentHits: opponentHits ?? this.opponentHits,
    winnerUid: clearWinner ? null : (winnerUid ?? this.winnerUid),
  );
}

/// Эхэлсэн 1v1 тулаан. Хоёр тоглогч ижил `seed`-ээс ижил эхний самбар авна.
abstract class DuelSession {
  int get seed;
  Duration get duration;
  DuelSnapshot get current;

  /// Төлөв өөрчлөгдөх бүрт шинэ snapshot ирнэ.
  Stream<DuelSnapshot> get updates;

  /// Зөв үг бүтээж өрсөлдөгчид [damage] хохирол учруулав.
  Future<void> hit(int damage, String word);

  /// Хугацаа дууссаныг мэдэгдэнэ (олон удаа дуудахад аюулгүй).
  Future<void> timeUp();

  /// Тулаанаас гарах (өрсөлдөгч ялна).
  Future<void> leave();

  /// Нөөцийг чөлөөлнө.
  void dispose();
}

/// Өрсөлдөгч хайж буй байдал.
abstract class DuelSearch {
  /// Олдвол сесс, цуцалбал `null`.
  Future<DuelSession?> get result;
  void cancel();
}
