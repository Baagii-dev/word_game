import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/models/letter_tile.dart';
import 'package:word_battle/online/duel_controller.dart';
import 'package:word_battle/online/local_online_service.dart';
import 'package:word_battle/online/online_models.dart';
import 'package:word_battle/services/dictionary_service.dart';

void main() {
  final dict = DictionaryService()
    ..loadFromList(['морь', 'ном', 'гэр', 'нар', 'сар', 'хонь', 'цагаан']);

  /// Самбар дээр [word]-ийн үсгүүдийг хүчээр тавьж сонгоно.
  void spell(DuelController c, String word) {
    c.board = [
      for (var i = 0; i < word.length; i++)
        LetterTile(id: 900 + i, letter: word[i], points: 1),
      ...c.board.skip(word.length),
    ];
    for (final t in c.board.take(word.length)) {
      c.selectTile(t);
    }
  }

  /// Bot-ыг чимээгүй болгосон үйлчилгээ (тест тогтвортой байхын тулд).
  LocalOnlineService quietService({int hp = 40, Duration? duration}) =>
      LocalOnlineService(
        searchDelay: const Duration(seconds: 1),
        duelHp: hp,
        duelDuration: duration ?? const Duration(seconds: 30),
        botMinHit: const Duration(hours: 1),
      );

  /// Нэвтэрч, өрсөлдөгч олдтол (searchDelay) хүлээгээд сессийг буцаана.
  DuelSession startDuel(LocalOnlineService s, FakeAsync async) {
    s.signIn('Тест');
    async.flushMicrotasks();
    final search = s.findDuel();
    DuelSession? session;
    search.result.then((v) => session = v);
    async.elapse(const Duration(seconds: 1)); // searchDelay
    async.flushMicrotasks();
    return session!;
  }

  group('Онооны жагсаалт', () {
    test(
      'Нэвтрээгүй үед дүн нэмэгдэхгүй, нэвтэрсний дараа эрэмблэгдэнэ',
      () async {
        final s = LocalOnlineService();
        await s.submitResult(
          score: 999,
          won: true,
        ); // нэвтрээгүй → үл тоомсорлоно
        var top = await s.topPlayers();
        expect(top.any((e) => e.uid == 'local-me'), isFalse);

        await s.signIn('Баатар');
        await s.submitResult(score: 6000, won: true);
        await s.submitResult(score: 100, won: false);
        top = await s.topPlayers();
        expect(top.first.name, 'Баатар'); // 6100 нь жишиг тоглогчдоос өндөр
        expect(top.first.totalScore, 6100);
        expect(top.first.wins, 1);
        expect(top.first.bestScore, 6000);
        // Буурахаар эрэмблэгдсэн
        for (var i = 1; i < top.length; i++) {
          expect(
            top[i - 1].totalScore,
            greaterThanOrEqualTo(top[i].totalScore),
          );
        }
      },
    );

    test(
      'syncHistory өмнөх тоглолтын нийлбэрийг нэмнэ, limit хүндэтгэнэ',
      () async {
        final s = LocalOnlineService();
        await s.signIn('Ном');
        await s.syncHistory(totalScore: 500, wins: 3, bestScore: 200);
        final top = await s.topPlayers(limit: 3);
        expect(top.length, 3);
        final me = (await s.topPlayers()).firstWhere(
          (e) => e.uid == 'local-me',
        );
        expect(me.totalScore, 500);
        expect(me.wins, 3);
      },
    );

    test('Ник хоосон бол алдаа', () {
      expect(() => LocalOnlineService().signIn('  '), throwsArgumentError);
    });
  });

  group('Өрсөлдөгч хайх', () {
    test('Нэвтрээгүй бол хайж болохгүй', () {
      expect(() => LocalOnlineService().findDuel(), throwsStateError);
    });

    test('Цуцлахад үр дүн null, дараа нь сесс үүсэхгүй', () {
      fakeAsync((async) {
        final s = quietService();
        s.signIn('Тест');
        async.flushMicrotasks();
        final search = s.findDuel();
        DuelSession? got = DuelSessionPlaceholder.sentinel;
        var done = false;
        search.result.then((v) {
          got = v;
          done = true;
        });
        async.elapse(const Duration(milliseconds: 300));
        search.cancel();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        expect(done, isTrue);
        expect(got, isNull);
      });
    });
  });

  group('1v1 тулаан', () {
    test('Зөв үг өрсөлдөгчийн HP-г бууруулна, буруу үг ээлж/HP хөндөхгүй', () {
      fakeAsync((async) {
        final s = quietService();
        final session = startDuel(s, async);
        final c = DuelController(session: session, dictionary: dict);

        spell(c, 'ххх');
        c.attack(); // толь бичигт алга
        async.flushMicrotasks();
        expect(c.snapshot.opponentHp, 40);
        expect(c.invalidCount, 1);
        expect(c.combo, 0);

        spell(c, 'морь');
        c.attack();
        async.flushMicrotasks();
        expect(c.snapshot.opponentHp, lessThan(40));
        expect(c.snapshot.myHp, 40);
        expect(c.wordsCount, 1);
        expect(c.combo, 1);
        c.dispose();
      });
    });

    test(
      'Өрсөлдөгчийн HP 0 болоход би нэг удаа ялна, дараа нь цохилт хүчингүй',
      () {
        fakeAsync((async) {
          final s = quietService(hp: 5);
          final session = startDuel(s, async);
          final c = DuelController(session: session, dictionary: dict);

          spell(c, 'морь');
          c.attack();
          async.flushMicrotasks();
          expect(c.snapshot.finished, isTrue);
          expect(c.snapshot.iWon, isTrue);
          expect(c.snapshot.opponentHp, 0);

          final winner = c.snapshot.winnerUid;
          spell(c, 'ном'); // дууссаны дараа сонгож/цохиж болохгүй
          c.attack();
          async.flushMicrotasks();
          expect(c.snapshot.winnerUid, winner);
          expect(c.wordsCount, 1);
          c.dispose();
        });
      },
    );

    test('Bot цохиж, миний HP 0 болбол bot ялна', () {
      fakeAsync((async) {
        final s = LocalOnlineService(
          searchDelay: const Duration(seconds: 1),
          duelHp: 6,
          duelDuration: const Duration(minutes: 5),
          botMinHit: const Duration(seconds: 2),
          botHitSpread: Duration.zero,
          botMinDamage: 10,
          botDamageSpread: 0,
        );
        final session = startDuel(s, async);
        final c = DuelController(session: session, dictionary: dict);
        async.elapse(const Duration(seconds: 3));
        expect(c.snapshot.finished, isTrue);
        expect(c.snapshot.iWon, isFalse);
        expect(c.snapshot.draw, isFalse);
        expect(c.snapshot.myHp, 0);
        expect(c.message, contains(c.snapshot.opponentName));
        c.dispose();
      });
    });

    test('Хугацаа дуусахад HP өндөртэй нь ялна, тэнцвэл тэнцлээ', () {
      fakeAsync((async) {
        // Хэн ч цохихгүй → тэнцлээ
        var s = quietService(duration: const Duration(seconds: 10));
        final a = startDuel(s, async);
        final c1 = DuelController(session: a, dictionary: dict);
        async.elapse(const Duration(seconds: 11));
        expect(c1.snapshot.finished, isTrue);
        expect(c1.snapshot.draw, isTrue);
        expect(c1.timeLeft, lessThanOrEqualTo(1));
        c1.dispose();

        // Би нэг удаа цохисон → ялна
        s = quietService(duration: const Duration(seconds: 10));
        final b = startDuel(s, async);
        final c2 = DuelController(session: b, dictionary: dict);
        spell(c2, 'ном');
        c2.attack();
        async.elapse(const Duration(seconds: 11));
        expect(c2.snapshot.iWon, isTrue);
        c2.dispose();
      });
    });

    test('Тулаанаас гарвал өрсөлдөгч ялна', () {
      fakeAsync((async) {
        final s = quietService();
        final session = startDuel(s, async);
        final c = DuelController(session: session, dictionary: dict);
        c.leave();
        async.flushMicrotasks();
        expect(c.snapshot.finished, isTrue);
        expect(c.snapshot.iWon, isFalse);
        c.dispose();
      });
    });

    test('Нэг seed → хоёр тоглогч ижил эхний самбартай', () {
      fakeAsync((async) {
        final s = quietService();
        final session = startDuel(s, async);
        final a = DuelController(session: session, dictionary: dict);
        final b = DuelController(session: session, dictionary: dict);
        expect(
          a.board.map((t) => t.letter).join(),
          b.board.map((t) => t.letter).join(),
        );
        expect(a.board.length, 12);
        a.dispose();
      });
    });
  });
}

/// `null` (цуцалсан) ба "хараахан үр дүн ирээгүй"-г ялгах тэмдэглэгч.
class DuelSessionPlaceholder {
  static final DuelSession sentinel = _Sentinel();
}

class _Sentinel implements DuelSession {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
