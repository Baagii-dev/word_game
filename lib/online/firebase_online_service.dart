import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'local_online_service.dart';
import 'online_models.dart';
import 'online_service.dart';

/// Firebase (Auth + Cloud Firestore) дээр ажиллах онлайн үйлчилгээ.
///
/// Өгөгдлийн бүтэц:
///  • `users/{uid}`  — {name, totalScore, wins, bestScore, duelWins}
///  • `matches/{id}` — 1v1 тулаан: {status, players, names, hps, hits, lastWord,
///                     lastSeen, seed, hp, durationSec, startedAt, winner}
///
/// Өрсөлдөгч олдохгүй бол ([botAfter] хугацааны дараа) bot-той тулаан эхэлнэ.
class FirebaseOnlineService extends OnlineService {
  FirebaseOnlineService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    Random? random,
    this.botAfter = const Duration(seconds: 15),
    this.duelHp = 40,
    this.duelDuration = const Duration(seconds: 90),
  }) : _auth = auth ?? FirebaseAuth.instance,
       _db = firestore ?? FirebaseFirestore.instance,
       _random = random ?? Random();

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final Random _random;
  final Duration botAfter;
  final int duelHp;
  final Duration duelDuration;

  PlayerProfile? _profile;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _matches => _db.collection('matches');

  @override
  bool get isOnline => true;

  @override
  String get modeLabel => 'Онлайн';

  @override
  PlayerProfile? get profile => _profile;

  @override
  Future<PlayerProfile> signIn(String nickname) async {
    final name = nickname.trim();
    if (name.isEmpty) throw ArgumentError('Ник хоосон байж болохгүй');
    final user = _auth.currentUser ?? (await _auth.signInAnonymously()).user;
    if (user == null) throw StateError('Нэвтэрч чадсангүй');

    final ref = _users.doc(user.uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) {
        tx.update(ref, {'name': name});
      } else {
        tx.set(ref, {
          'name': name,
          'totalScore': 0,
          'wins': 0,
          'bestScore': 0,
          'duelWins': 0,
        });
      }
    });
    _profile = PlayerProfile(uid: user.uid, name: name);
    notifyListeners();
    return _profile!;
  }

  /// Тоглогчийн статистикийг атомаар шинэчилнэ.
  Future<void> _addStats({
    int score = 0,
    int wins = 0,
    int duelWins = 0,
    int best = 0,
  }) async {
    final me = _profile;
    if (me == null) return;
    final ref = _users.doc(me.uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final d = snap.data() ?? const <String, dynamic>{};
      int n(String k) => (d[k] as num?)?.toInt() ?? 0;
      tx.set(ref, {
        'name': me.name,
        'totalScore': n('totalScore') + score,
        'wins': n('wins') + wins,
        'duelWins': n('duelWins') + duelWins,
        'bestScore': max(n('bestScore'), best),
      });
    });
  }

  @override
  Future<void> submitResult({required int score, required bool won}) =>
      _addStats(score: score, wins: won ? 1 : 0, best: score);

  @override
  Future<void> syncHistory({
    required int totalScore,
    required int wins,
    required int bestScore,
  }) => _addStats(score: totalScore, wins: wins, best: bestScore);

  @override
  Future<void> submitDuelResult({required bool won, required int score}) =>
      _addStats(score: score, duelWins: won ? 1 : 0, best: score);

  @override
  Future<List<LeaderboardEntry>> topPlayers({int limit = 50}) async {
    final snap = await _users
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .get();
    return [
      for (final d in snap.docs)
        LeaderboardEntry(
          uid: d.id,
          name: (d.data()['name'] as String?) ?? '—',
          totalScore: (d.data()['totalScore'] as num?)?.toInt() ?? 0,
          wins: (d.data()['wins'] as num?)?.toInt() ?? 0,
          bestScore: (d.data()['bestScore'] as num?)?.toInt() ?? 0,
          duelWins: (d.data()['duelWins'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  @override
  DuelSearch findDuel() {
    final me = _profile;
    if (me == null) throw StateError('Эхлээд нэвтэрнэ үү');
    return _FirebaseSearch(this, me)..start();
  }
}

class _FirebaseSearch implements DuelSearch {
  _FirebaseSearch(this._svc, this._me);

  final FirebaseOnlineService _svc;
  final PlayerProfile _me;
  final Completer<DuelSession?> _completer = Completer();
  DocumentReference<Map<String, dynamic>>? _myWaiting;
  bool _cancelled = false;

  @override
  Future<DuelSession?> get result => _completer.future;

  @override
  void cancel() {
    _cancelled = true;
    _deleteWaiting();
    if (!_completer.isCompleted) _completer.complete(null);
  }

  void _deleteWaiting() {
    final ref = _myWaiting;
    _myWaiting = null;
    ref?.delete().catchError((_) {});
  }

  void start() => _run().catchError((Object e, StackTrace s) {
    if (!_completer.isCompleted) _completer.completeError(e, s);
  });

  Future<void> _run() async {
    // 1. Хүлээж буй тулаанд нэгдэх
    var joined = await _tryJoin();
    if (joined == null && !_cancelled) {
      // 2. Өөрөө тулаан үүсгээд хүлээх
      final ref = await _svc._matches.add({
        'status': 'waiting',
        'players': [_me.uid],
        'names': {_me.uid: _me.name},
        'hps': {_me.uid: _svc.duelHp},
        'hits': {_me.uid: 0},
        'lastWord': <String, dynamic>{},
        'lastSeen': <String, dynamic>{},
        'seed': _svc._random.nextInt(1 << 30),
        'hp': _svc.duelHp,
        'durationSec': _svc.duelDuration.inSeconds,
        'createdAt': FieldValue.serverTimestamp(),
        'winner': null,
      });
      _myWaiting = ref;
      if (_cancelled) {
        _deleteWaiting();
        return;
      }
      joined = await _waitForOpponent(ref);
    }
    if (_cancelled) return;

    if (joined != null) {
      final doc = await joined.get();
      final session = _FirebaseDuel(me: _me, ref: joined, initial: doc.data()!);
      _myWaiting = null;
      if (!_completer.isCompleted) _completer.complete(session);
      return;
    }

    // 3. Хэн ч олдсонгүй → bot-той тулаан
    _deleteWaiting();
    final bot = LocalOnlineService(
      searchDelay: Duration.zero,
      duelHp: _svc.duelHp,
      duelDuration: _svc.duelDuration,
    );
    await bot.signIn(_me.name);
    final session = await bot.findDuel().result;
    if (!_completer.isCompleted) _completer.complete(session);
  }

  /// Өөрийн "waiting" тулааныг хүлээнэ. Өрсөлдөгч нэгдвэл эсвэл өөр хүлээж буй
  /// (илүү эртний) тулаан олдвол тэрэнд нэгдэнэ. [botAfter] дууссан бол `null`.
  Future<DocumentReference<Map<String, dynamic>>?> _waitForOpponent(
    DocumentReference<Map<String, dynamic>> mine,
  ) async {
    final deadline = DateTime.now().add(_svc.botAfter);
    while (!_cancelled && DateTime.now().isBefore(deadline)) {
      final snap = await mine.get();
      final data = snap.data();
      if (data == null) return null;
      if (data['status'] == 'active') return mine; // өрсөлдөгч нэгдлээ

      // Хоёр хүн зэрэг тулаан үүсгэсэн бол эртнийх нь хүлээнэ, сүүлийнх нь нэгдэнэ
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      if (createdAt != null) {
        final other = await _tryJoin(olderThan: createdAt, mineId: mine.id);
        if (other != null) {
          _deleteWaiting();
          return other;
        }
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    return null;
  }

  Future<DocumentReference<Map<String, dynamic>>?> _tryJoin({
    DateTime? olderThan,
    String? mineId,
  }) async {
    final snap = await _svc._matches
        .where('status', isEqualTo: 'waiting')
        .limit(10)
        .get();
    final now = DateTime.now();
    final candidates = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final d in snap.docs) {
      if (d.id == mineId) continue;
      final data = d.data();
      final players = List<String>.from(data['players'] as List? ?? const []);
      if (players.length != 1 || players.contains(_me.uid)) continue;
      final created = (data['createdAt'] as Timestamp?)?.toDate();
      if (created == null || now.difference(created) > const Duration(seconds: 30)) {
        continue; // хуучирсан эсвэл дөнгөж үүсэж байгаа
      }
      if (olderThan != null && !created.isBefore(olderThan)) continue;
      candidates.add(d);
    }
    candidates.sort((a, b) {
      final ta = (a.data()['createdAt'] as Timestamp).toDate();
      final tb = (b.data()['createdAt'] as Timestamp).toDate();
      return ta.compareTo(tb);
    });

    for (final c in candidates) {
      try {
        final ok = await _svc._db.runTransaction((tx) async {
          final s = await tx.get(c.reference);
          final d = s.data();
          if (d == null || d['status'] != 'waiting') return false;
          final players = List<String>.from(d['players'] as List);
          if (players.length != 1) return false;
          tx.update(c.reference, {
            'players': [...players, _me.uid],
            'names.${_me.uid}': _me.name,
            'hps.${_me.uid}': (d['hp'] as num).toInt(),
            'hits.${_me.uid}': 0,
            'status': 'active',
            'startedAt': FieldValue.serverTimestamp(),
          });
          return true;
        });
        if (ok) return c.reference;
      } catch (_) {
        // өөр хүн түрүүлж нэгдсэн — дараагийнхыг оролдоно
      }
    }
    return null;
  }
}

/// Firestore-ийн `matches/{id}` баримтаар дамжин ажиллах 1v1 тулаан.
/// Ялагчийг transaction дотор нэг л удаа тогтооно.
class _FirebaseDuel implements DuelSession {
  _FirebaseDuel({
    required PlayerProfile me,
    required DocumentReference<Map<String, dynamic>> ref,
    required Map<String, dynamic> initial,
  }) : _me = me,
       _ref = ref,
       seed = (initial['seed'] as num).toInt(),
       duration = Duration(seconds: (initial['durationSec'] as num).toInt()),
       _snap = _toSnapshot(me.uid, initial) {
    _sub = ref.snapshots().listen(_onDoc, onError: (_) {});
    _heartbeat = Timer.periodic(const Duration(seconds: 3), (_) => _beat());
    _beat();
  }

  final PlayerProfile _me;
  final DocumentReference<Map<String, dynamic>> _ref;
  @override
  final int seed;
  @override
  final Duration duration;

  final StreamController<DuelSnapshot> _controller = StreamController.broadcast();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;
  Timer? _heartbeat;
  DuelSnapshot _snap;
  DateTime? _startedAt;
  bool _disposed = false;

  @override
  DuelSnapshot get current => _snap;

  @override
  Stream<DuelSnapshot> get updates => _controller.stream;

  static DuelSnapshot _toSnapshot(String myUid, Map<String, dynamic> d) {
    final players = List<String>.from(d['players'] as List);
    final opp = players.firstWhere((p) => p != myUid, orElse: () => '');
    Map<String, dynamic> m(String k) => Map<String, dynamic>.from(d[k] as Map? ?? const {});
    final hps = m('hps'), names = m('names'), hits = m('hits'), words = m('lastWord');
    final winner = d['winner'] as String?;
    return DuelSnapshot(
      status: d['status'] == 'finished' ? DuelStatus.finished : DuelStatus.active,
      myUid: myUid,
      myHp: (hps[myUid] as num?)?.toInt() ?? 0,
      opponentHp: (hps[opp] as num?)?.toInt() ?? 0,
      maxHp: (d['hp'] as num).toInt(),
      opponentName: (names[opp] as String?) ?? 'Өрсөлдөгч',
      opponentLastWord: words[opp] as String?,
      opponentHits: (hits[opp] as num?)?.toInt() ?? 0,
      winnerUid: (winner == null || winner.isEmpty) ? null : winner,
    );
  }

  void _onDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null || _disposed) return;
    _startedAt = (d['startedAt'] as Timestamp?)?.toDate() ?? _startedAt;
    _snap = _toSnapshot(_me.uid, d);
    if (!_controller.isClosed) _controller.add(_snap);
    if (_snap.finished) _heartbeat?.cancel();
  }

  /// Холболтын цохилт: өрсөлдөгч 20 секунд чимээгүй бол тулаанаас гарсанд тооцно.
  Future<void> _beat() async {
    if (_disposed || _snap.finished) return;
    try {
      await _ref.update({'lastSeen.${_me.uid}': Timestamp.now()});
      final doc = await _ref.get();
      final d = doc.data();
      if (d == null || d['status'] != 'active') return;
      final players = List<String>.from(d['players'] as List);
      final opp = players.firstWhere((p) => p != _me.uid, orElse: () => '');
      final seen = ((d['lastSeen'] as Map?)?[opp] as Timestamp?)?.toDate();
      final started = (d['startedAt'] as Timestamp?)?.toDate();
      if (seen != null &&
          DateTime.now().difference(seen) > const Duration(seconds: 20) &&
          started != null &&
          DateTime.now().difference(started) > const Duration(seconds: 20)) {
        await _finish(winnerUid: _me.uid);
      }
    } catch (_) {}
  }

  /// Тулааныг transaction дотор нэг л удаа дуусгана.
  Future<void> _finish({String? winnerUid, bool byHp = false}) async {
    await _ref.firestore.runTransaction((tx) async {
      final s = await tx.get(_ref);
      final d = s.data();
      if (d == null || d['status'] != 'active') return;
      var winner = winnerUid;
      if (byHp) {
        final hps = Map<String, dynamic>.from(d['hps'] as Map);
        final players = List<String>.from(d['players'] as List);
        final a = (hps[players[0]] as num).toInt();
        final b = (hps[players[1]] as num).toInt();
        winner = a == b ? '' : (a > b ? players[0] : players[1]);
      }
      tx.update(_ref, {'status': 'finished', 'winner': winner ?? ''});
    });
  }

  @override
  Future<void> hit(int damage, String word) async {
    if (_snap.finished || damage <= 0 || _disposed) return;
    try {
      await _ref.firestore.runTransaction((tx) async {
        final s = await tx.get(_ref);
        final d = s.data();
        if (d == null || d['status'] != 'active') return;
        final players = List<String>.from(d['players'] as List);
        final opp = players.firstWhere((p) => p != _me.uid);
        final hps = Map<String, dynamic>.from(d['hps'] as Map);
        final hits = Map<String, dynamic>.from(d['hits'] as Map? ?? const {});
        final oppHp = max(0, (hps[opp] as num).toInt() - damage);
        tx.update(_ref, {
          'hps.$opp': oppHp,
          'lastWord.${_me.uid}': word,
          'hits.${_me.uid}': ((hits[_me.uid] as num?)?.toInt() ?? 0) + 1,
          if (oppHp == 0) ...{'status': 'finished', 'winner': _me.uid},
        });
      });
    } catch (_) {}
  }

  @override
  Future<void> timeUp() async {
    if (_snap.finished || _disposed) return;
    final started = _startedAt;
    // Сервер дээрх эхлэх цагаас duration өнгөрсөн (2 секундын алдаатай) үед л дуусгана
    if (started != null &&
        DateTime.now().difference(started) < duration - const Duration(seconds: 2)) {
      return;
    }
    try {
      await _finish(byHp: true);
    } catch (_) {}
  }

  @override
  Future<void> leave() async {
    try {
      if (!_snap.finished) {
        final opp = (await _ref.get()).data()?['players'] as List?;
        final other = opp
            ?.cast<String>()
            .firstWhere((p) => p != _me.uid, orElse: () => '');
        await _finish(winnerUid: other);
        // Snapshot сонсогчоос өмнө хаагдах тул дүнг шууд дамжуулна
        _snap = _snap.copyWith(status: DuelStatus.finished, winnerUid: other);
        if (!_controller.isClosed) _controller.add(_snap);
      }
    } catch (_) {}
    dispose();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _heartbeat?.cancel();
    _sub?.cancel();
    _controller.close();
  }
}
