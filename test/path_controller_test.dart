import 'dart:io';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/core/constants.dart';
import 'package:word_battle/logic/path_controller.dart';
import 'package:word_battle/models/chapter.dart';
import 'package:word_battle/models/enemy.dart';
import 'package:word_battle/models/tale_path.dart';
import 'package:word_battle/services/dictionary_service.dart';

import 'helpers.dart';

void main() {
  final dict = DictionaryService()
    ..loadFromList(File('assets/data/words.txt').readAsLinesSync());

  Chapter withPath(List<PathSegment> path) => Chapter(
    id: 1,
    title: 'тест',
    subtitle: '',
    scene: Scene.steppe,
    playerHp: 30,
    intro: const [],
    outro: const [],
    moral: '',
    path: path,
    enemies: [Enemy(name: 'x', kind: EnemyKind.mouse, maxHp: 10, attack: 1)],
  );

  final twoPages = withPath([
    PathSegment(
      text: 'Хадыг [алх]аар бутална.',
      obstacles: const [PathObstacle(name: 'Хад', word: 'алх', at: 0.5)],
    ),
    PathSegment(
      text: 'Голыг [завь]аар гатлана.',
      obstacles: const [PathObstacle(name: 'Гол', word: 'завь', at: 0.5)],
    ),
  ]);

  PathController make([Chapter? c]) => PathController(
    chapter: c ?? twoPages,
    dictionary: dict,
    random: Random(1),
  )..start();

  /// Баатар саадтай тулах хүртэл хугацааг гүйлгэнэ.
  void walkToObstacle(FakeAsync async, PathController c) {
    for (var i = 0; i < 400 && c.status != PathStatus.facing; i++) {
      async.elapse(PathController.tick);
    }
    expect(c.status, PathStatus.facing);
  }

  void spell(PathController c, String word) {
    for (final ch in word.split('')) {
      c.selectTile(c.board.firstWhere((t) => t.letter == ch && !t.isSelected));
    }
  }

  test('[үг] тэмдэглэгээ зөв задрана', () {
    final seg = PathSegment(
      text: 'Хадыг [алх]аар, шугуйг [хутга] ашиглан.',
      obstacles: const [],
    );
    expect(seg.markedWords, {'алх', 'хутга'});
    expect(seg.plainText, 'Хадыг алхаар, шугуйг хутга ашиглан.');
    expect(seg.spans.where((s) => s.marked).length, 2);
  });

  test('Баатар алхаж саадтай тулна, самбарт үгийн үсгүүд байна', () {
    fakeAsync((async) {
      final c = make();
      expect(c.status, PathStatus.walking);
      walkToObstacle(async, c);
      expect(c.heroPos, closeTo(0.4, 0.01));
      expect(c.board.length, GameConfig.pathBoardSize);
      final letters = c.board.map((t) => t.letter).toList();
      for (final ch in 'алх'.split('')) {
        expect(letters.remove(ch), isTrue, reason: ch);
      }
      c.dispose();
    });
  });

  test('Зөв үг саадыг давж, дараагийн хуудас, эцэст нь дуусна', () {
    fakeAsync((async) {
      final c = make();
      walkToObstacle(async, c);
      spell(c, 'алх');
      c.submit();
      expect(c.status, PathStatus.cleared);
      expect(c.isCleared(0), isTrue);
      expect(c.score, greaterThan(10));

      // Хуудасны төгсгөл хүртэл алхаад дараагийн хуудас руу шилжинэ
      walkToObstacle(async, c);
      expect(c.segmentIndex, 1);
      spell(c, 'завь');
      c.submit();
      for (var i = 0; i < 400 && !c.isOver; i++) {
        async.elapse(PathController.tick);
      }
      expect(c.status, PathStatus.finished);
      expect(c.hearts, GameConfig.pathHearts);
      c.dispose();
    });
  });

  test('Буруу үг хугацаа хасна, ээлж үлдэнэ', () {
    fakeAsync((async) {
      final c = make();
      walkToObstacle(async, c);
      final before = c.timeLeft;
      c.selectTile(c.board.first);
      c.selectTile(c.board.last);
      c.submit();
      expect(c.status, PathStatus.facing);
      expect(c.invalidCount, 1);
      expect(c.timeLeft, closeTo(before - GameConfig.pathWrongPenalty, 0.05));
      expect(c.selected, isEmpty);
      c.dispose();
    });
  });

  test('Хугацаа дуусвал зүрх алдаж, бүгд дуусвал бүтэлгүйтнэ', () {
    fakeAsync((async) {
      final c = make();
      walkToObstacle(async, c);
      async.elapse(Duration(seconds: GameConfig.pathObstacleSeconds + 1));
      expect(c.hearts, GameConfig.pathHearts - 1);
      expect(c.status, PathStatus.facing);
      async.elapse(
        Duration(
          seconds: (GameConfig.pathObstacleSeconds + 1) * GameConfig.pathHearts,
        ),
      );
      expect(c.status, PathStatus.failed);
      expect(c.hearts, 0);
      c.dispose();
    });
  });

  test('pause() үед цаг явахгүй', () {
    fakeAsync((async) {
      final c = make();
      walkToObstacle(async, c);
      c.pause();
      final t = c.timeLeft;
      async.elapse(const Duration(seconds: 30));
      expect(c.timeLeft, t);
      expect(c.hearts, GameConfig.pathHearts);
      c.resume();
      async.elapse(const Duration(seconds: 1));
      expect(c.timeLeft, lessThan(t));
      c.dispose();
    });
  });

  group('stories.json-ийн зам', () {
    final chapters = loadRealChapters();

    test('Үлгэр бүр замтай, үг бүр толь бичигт, текстэд сануулсан', () {
      for (final ch in chapters) {
        expect(ch.path, isNotEmpty, reason: ch.title);
        for (final seg in ch.path) {
          expect(seg.obstacles, isNotEmpty, reason: seg.text);
          for (final o in seg.obstacles) {
            expect(dict.words.contains(o.word), isTrue, reason: o.word);
            expect(
              seg.markedWords.contains(o.word),
              isTrue,
              reason: '"${o.word}" текстэд [ ]-ээр тэмдэглэгдээгүй',
            );
            for (final l in o.word.split('')) {
              expect(kExcludedLetters.contains(l), isFalse, reason: o.word);
            }
            expect(o.emoji != null || o.kind != null, isTrue, reason: o.name);
          }
        }
      }
    });

    test('Bot бодит үлгэр бүрийн замыг дуусгана', () {
      for (final ch in chapters) {
        fakeAsync((async) {
          final c = make(ch);
          for (var i = 0; i < 5000 && !c.isOver; i++) {
            if (c.status == PathStatus.facing) {
              spell(c, c.obstacle!.word);
              c.submit();
            }
            async.elapse(PathController.tick);
          }
          expect(c.status, PathStatus.finished, reason: ch.title);
          c.dispose();
        });
      }
    });
  });
}
