// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:math';

import 'online_models.dart';
import 'online_service.dart';

/// Санах ойд ажилладаг онлайн үйлчилгээ (интернэт, Firebase шаардахгүй).
///
///  • Онооны жагсаалт: жишиг тоглогчид + нэвтэрсэн тоглогч (апп хаавал арилна)
///  • 1v1: bot өрсөлдөгч — жинхэнэ тоглогчтой адил интерфэйсээр хариу цохино
///
/// Firebase тохируулаагүй, эсвэл тест/демо үед ашиглана.
class LocalOnlineService extends OnlineService {
  LocalOnlineService({
    Random? random,
    this.searchDelay = const Duration(seconds: 2),
    this.duelDuration = const Duration(seconds: 90),
    this.duelHp = 40,
    this.botMinHit = const Duration(seconds: 7),
    this.botHitSpread = const Duration(seconds: 3),
    this.botMinDamage = 4,
    this.botDamageSpread = 5,
  }) : _random = random ?? Random();

  final Random _random;
  final Duration searchDelay;
  final Duration duelDuration;
  final int duelHp;
  final Duration botMinHit;
  final Duration botHitSpread;
  final int botMinDamage;
  final int botDamageSpread;

  static const _demoPlayers = <LeaderboardEntry>[
    LeaderboardEntry(
      uid: 'demo-1',
      name: 'Хангай',
      totalScore: 4820,
      wins: 31,
      bestScore: 410,
      duelWins: 12,
    ),
    LeaderboardEntry(
      uid: 'demo-2',
      name: 'Алтай',
      totalScore: 3965,
      wins: 26,
      bestScore: 372,
      duelWins: 9,
    ),
    LeaderboardEntry(
      uid: 'demo-3',
      name: 'Сэлэнгэ',
      totalScore: 3110,
      wins: 21,
      bestScore: 340,
      duelWins: 7,
    ),
    LeaderboardEntry(
      uid: 'demo-4',
      name: 'Мөнхөө',
      totalScore: 2240,
      wins: 15,
      bestScore: 301,
      duelWins: 4,
    ),
    LeaderboardEntry(
      uid: 'demo-5',
      name: 'Номин',
      totalScore: 1380,
      wins: 9,
      bestScore: 255,
      duelWins: 2,
    ),
  ];

  static const _botNames = [
    'Бат-Эрдэнэ',
    'Цэцэг',
    'Билгүүн',
    'Оюуна',
    'Тэмүүжин',
  ];
  static const _botWords = [
    'ном',
    'морь',
    'гэр',
    'нар',
    'сар',
    'хонь',
    'цагаан',
    'уул',
    'тал',
    'ус',
  ];

  PlayerProfile? _profile;
  LeaderboardEntry? _me;

  @override
  bool get isOnline => false;

  @override
  String get modeLabel => 'Офлайн демо';

  @override
  PlayerProfile? get profile => _profile;

  @override
  Future<PlayerProfile> signIn(String nickname) async {
    final name = nickname.trim();
    if (name.isEmpty) throw ArgumentError('Ник хоосон байж болохгүй');
    final p = PlayerProfile(uid: 'local-me', name: name);
    _profile = p;
    _me = LeaderboardEntry(
      uid: p.uid,
      name: name,
      totalScore: _me?.totalScore ?? 0,
      wins: _me?.wins ?? 0,
      bestScore: _me?.bestScore ?? 0,
      duelWins: _me?.duelWins ?? 0,
    );
    notifyListeners();
    return p;
  }

  void _update(LeaderboardEntry Function(LeaderboardEntry e) f) {
    final me = _me;
    if (me == null) return;
    _me = f(me);
    notifyListeners();
  }

  LeaderboardEntry _copy(
    LeaderboardEntry e, {
    int? total,
    int? wins,
    int? best,
    int? duelWins,
  }) => LeaderboardEntry(
    uid: e.uid,
    name: e.name,
    totalScore: total ?? e.totalScore,
    wins: wins ?? e.wins,
    bestScore: best ?? e.bestScore,
    duelWins: duelWins ?? e.duelWins,
  );

  @override
  Future<void> submitResult({required int score, required bool won}) async {
    _update(
      (e) => _copy(
        e,
        total: e.totalScore + score,
        wins: e.wins + (won ? 1 : 0),
        best: max(e.bestScore, score),
      ),
    );
  }

  @override
  Future<void> syncHistory({
    required int totalScore,
    required int wins,
    required int bestScore,
  }) async {
    _update(
      (e) => _copy(
        e,
        total: e.totalScore + totalScore,
        wins: e.wins + wins,
        best: max(e.bestScore, bestScore),
      ),
    );
  }

  @override
  Future<void> submitDuelResult({required bool won, required int score}) async {
    _update(
      (e) => _copy(
        e,
        total: e.totalScore + score,
        duelWins: e.duelWins + (won ? 1 : 0),
        best: max(e.bestScore, score),
      ),
    );
  }

  @override
  Future<List<LeaderboardEntry>> topPlayers({int limit = 50}) async {
    final all = [..._demoPlayers, ?_me]
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return all.take(limit).toList();
  }

  @override
  DuelSearch findDuel() {
    final me = _profile;
    if (me == null) throw StateError('Эхлээд нэвтэрнэ үү');
    final search = _LocalSearch();
    search._timer = Timer(searchDelay, () {
      if (search._cancelled) return;
      final name = _botNames[_random.nextInt(_botNames.length)];
      search._complete(
        _LocalDuel(
          me: me,
          opponentName: name,
          seed: _random.nextInt(1 << 30),
          duration: duelDuration,
          hp: duelHp,
          random: _random,
          botMinHit: botMinHit,
          botHitSpread: botHitSpread,
          botMinDamage: botMinDamage,
          botDamageSpread: botDamageSpread,
          botWords: _botWords,
        ),
      );
    });
    return search;
  }
}

class _LocalSearch implements DuelSearch {
  final Completer<DuelSession?> _completer = Completer();
  Timer? _timer;
  bool _cancelled = false;

  void _complete(DuelSession s) {
    if (!_completer.isCompleted) _completer.complete(s);
  }

  @override
  Future<DuelSession?> get result => _completer.future;

  @override
  void cancel() {
    _cancelled = true;
    _timer?.cancel();
    if (!_completer.isCompleted) _completer.complete(null);
  }
}

/// Bot-той тулаан. Серверийн үүргийг энд гүйцэтгэнэ: хохирол хэрэглэх,
/// ялагчийг нэг л удаа тогтоох.
class _LocalDuel implements DuelSession {
  _LocalDuel({
    required PlayerProfile me,
    required String opponentName,
    required this.seed,
    required this.duration,
    required int hp,
    required Random random,
    required Duration botMinHit,
    required Duration botHitSpread,
    required int botMinDamage,
    required int botDamageSpread,
    required List<String> botWords,
  }) : _me = me,
       _random = random,
       _botMinHit = botMinHit,
       _botHitSpread = botHitSpread,
       _botMinDamage = botMinDamage,
       _botDamageSpread = botDamageSpread,
       _botWords = botWords,
       _snap = DuelSnapshot(
         status: DuelStatus.active,
         myUid: me.uid,
         myHp: hp,
         opponentHp: hp,
         maxHp: hp,
         opponentName: opponentName,
       ) {
    _clock = Timer(duration, timeUp);
    _scheduleBot();
  }

  static const _botUid = 'bot';
  final PlayerProfile _me;
  final Random _random;
  final Duration _botMinHit;
  final Duration _botHitSpread;
  final int _botMinDamage;
  final int _botDamageSpread;
  final List<String> _botWords;

  @override
  final int seed;
  @override
  final Duration duration;

  final StreamController<DuelSnapshot> _controller =
      StreamController.broadcast();
  DuelSnapshot _snap;
  Timer? _clock;
  Timer? _botTimer;
  bool _disposed = false;

  @override
  DuelSnapshot get current => _snap;

  @override
  Stream<DuelSnapshot> get updates => _controller.stream;

  void _emit(DuelSnapshot s) {
    _snap = s;
    if (!_disposed && !_controller.isClosed) _controller.add(s);
  }

  void _scheduleBot() {
    final ms =
        _botMinHit.inMilliseconds +
        _random.nextInt(_botHitSpread.inMilliseconds + 1);
    _botTimer = Timer(Duration(milliseconds: ms), () {
      if (_snap.finished || _disposed) return;
      final dmg = _botMinDamage + _random.nextInt(_botDamageSpread + 1);
      final word = _botWords[_random.nextInt(_botWords.length)];
      final myHp = max(0, _snap.myHp - dmg);
      _emit(
        _snap.copyWith(
          myHp: myHp,
          opponentLastWord: word,
          opponentHits: _snap.opponentHits + 1,
        ),
      );
      if (myHp == 0) {
        _finish(_botUid);
      } else {
        _scheduleBot();
      }
    });
  }

  void _finish(String? winnerUid) {
    if (_snap.finished) return; // ялагчийг зөвхөн нэг удаа тогтооно
    _clock?.cancel();
    _botTimer?.cancel();
    _emit(
      _snap.copyWith(
        status: DuelStatus.finished,
        winnerUid: winnerUid,
        clearWinner: winnerUid == null,
      ),
    );
  }

  @override
  Future<void> hit(int damage, String word) async {
    if (_snap.finished || damage <= 0) return;
    final hp = max(0, _snap.opponentHp - damage);
    _emit(_snap.copyWith(opponentHp: hp));
    if (hp == 0) _finish(_me.uid);
  }

  @override
  Future<void> timeUp() async {
    if (_snap.finished) return;
    if (_snap.myHp == _snap.opponentHp) {
      _finish(null);
    } else {
      _finish(_snap.myHp > _snap.opponentHp ? _me.uid : _botUid);
    }
  }

  @override
  Future<void> leave() async {
    if (!_snap.finished) _finish(_botUid);
    dispose();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _clock?.cancel();
    _botTimer?.cancel();
    _controller.close();
  }
}
