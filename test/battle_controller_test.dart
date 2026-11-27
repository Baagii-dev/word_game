import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/core/constants.dart';
import 'package:word_battle/logic/battle_controller.dart';
import 'package:word_battle/models/enemy.dart';
import 'package:word_battle/models/letter_tile.dart';
import 'package:word_battle/services/dictionary_service.dart';

import 'helpers.dart';

void main() {
  final dict = DictionaryService()
    ..loadFromList([
      'үг',
      'ус',
      'морь',
      'ном',
      'гэр',
      'нар',
      'сар',
      'хонь',
      'цагаан',
    ]);

  const playerHp = 30;

  BattleController makeController({
    int hp = 100,
    List<Enemy>? enemies,
  }) => BattleController(
    chapter: testChapter(
      playerHp: playerHp,
      enemies:
          enemies ??
          [Enemy(name: 'Хулгана', kind: EnemyKind.mouse, maxHp: hp, attack: 3)],
    ),
    dictionary: dict,
    bonuses: false, // тусгай үсэг тооцоог санамсаргүй болгохгүй
  )..start();

  /// Самбар дээрх үсгээр үг бүтээхийн тулд тухайн үсгүүдийг самбарт хүчээр тавина.
  void spell(BattleController c, String word) {
    c.board = [
      for (var i = 0; i < word.length; i++)
        LetterTile(id: 1000 + i, letter: word[i], points: 1),
      ...c.board.skip(word.length),
    ];
    for (final tile in c.board.take(word.length)) {
      c.selectTile(tile);
    }
  }

  test('Зөв үг дайсанд хохирол учруулж, combo нэмэгдүүлнэ', () {
    fakeAsync((async) {
      final c = makeController();
      spell(c, 'морь');
      c.attack();

      expect(c.enemy.hp, lessThan(c.enemy.maxHp));
      expect(c.combo, 1);
      expect(c.wordsCount, 1);
      expect(c.status, BattleStatus.enemyTurn);
      c.dispose();
    });
  });

  test('2 үсэгтэй үг ("үг") зөв тооцогдож хохирол өгнө', () {
    fakeAsync((async) {
      final c = makeController();
      spell(c, 'үг');
      c.attack();

      expect(c.enemy.hp, lessThan(c.enemy.maxHp));
      expect(c.combo, 1);
      expect(c.wordsCount, 1);
      expect(c.status, BattleStatus.enemyTurn);
      c.dispose();
    });
  });

  test('Буруу үг ээлж алдуулахгүй, combo-г тасалж, сонголтыг цэвэрлэнэ', () {
    fakeAsync((async) {
      final c = makeController();
      spell(c, 'морь');
      c.attack();
      async.elapse(const Duration(milliseconds: 1000)); // дайсны ээлж дуусна

      spell(c, 'ххх');
      c.attack();

      expect(c.combo, 0);
      expect(c.status, BattleStatus.playerTurn);
      expect(c.selected, isEmpty);
      c.dispose();
    });
  });

  test('2-оос богино (1 үсэгтэй) үг хүчингүй', () {
    fakeAsync((async) {
      final c = makeController();
      spell(c, 'а');
      c.attack();

      expect(c.wordsCount, 0);
      expect(c.enemy.hp, c.enemy.maxHp);
      expect(c.status, BattleStatus.playerTurn);
      c.dispose();
    });
  });

  test('Хугацаа дуусвал дайсан довтолж, тоглогчийн HP буурна', () {
    fakeAsync((async) {
      final c = makeController();
      async.elapse(Duration(seconds: GameConfig.turnSeconds));
      expect(c.status, BattleStatus.enemyTurn);

      async.elapse(const Duration(milliseconds: 1000));
      expect(c.player.hp, playerHp - 3);
      expect(c.status, BattleStatus.playerTurn);
      c.dispose();
    });
  });

  test('pause() хугацааг зогсоож, resume() үргэлжлүүлнэ', () {
    fakeAsync((async) {
      final c = makeController();
      async.elapse(const Duration(seconds: 5));
      c.pause();
      final frozen = c.timeLeft;

      async.elapse(const Duration(seconds: 20));
      expect(c.timeLeft, frozen);

      c.resume();
      async.elapse(const Duration(seconds: 3));
      expect(c.timeLeft, frozen - 3);
      c.dispose();
    });
  });

  test('Сүүлийн дайсныг ялбал ялалт, од тооцогдоно', () {
    fakeAsync((async) {
      final c = makeController(hp: 1);
      spell(c, 'морь');
      c.attack();
      expect(c.status, BattleStatus.enemyDefeated);

      async.elapse(const Duration(milliseconds: 1300));
      expect(c.status, BattleStatus.won);
      expect(c.stars, 3);
      expect(c.finalScore, greaterThan(c.damageTotal));
      c.dispose();
    });
  });

  test('Давхар довтлох оролдлого ээлжийг хоёр удаа эхлүүлэхгүй', () {
    fakeAsync((async) {
      final c = makeController();
      spell(c, 'морь');
      c.attack();
      c.attack(); // дайсны ээлж үед — үл тоомсорлоно
      async.elapse(const Duration(milliseconds: 1000));

      expect(c.player.hp, playerHp - 3);
      c.dispose();
    });
  });

  test('Санамж ээлж алдуулахгүй, тоолууртай, самбараас бүтэх үг өгнө', () {
    fakeAsync((async) {
      final c = makeController();
      spell(c, 'морь');
      c.clearSelection();
      c.hint();

      expect(c.hintsLeft, GameConfig.hintsPerBattle - 1);
      expect(c.message, startsWith('Санамж:'));
      expect(c.status, BattleStatus.playerTurn);

      c.hint();
      c.hint();
      c.hint(); // хязгаарлагдсан
      expect(c.hintsLeft, 0);
      c.dispose();
    });
  });

  test('Дайсны тусгай цохилт N ээлж тутамд 2× хохирол өгнө', () {
    fakeAsync((async) {
      final c = makeController(
        enemies: [
          Enemy(
            name: 'Мангас',
            kind: EnemyKind.demon,
            maxHp: 100,
            attack: 2,
            special: EnemySpecial.strike,
            specialEvery: 2,
          ),
        ],
      );
      expect(c.specialIncoming, isFalse);
      expect(c.turnsUntilSpecial, 2);

      async.elapse(Duration(seconds: GameConfig.turnSeconds));
      async.elapse(const Duration(milliseconds: 1000));
      expect(c.player.hp, playerHp - 2); // энгийн
      expect(c.specialIncoming, isTrue);

      async.elapse(Duration(seconds: GameConfig.turnSeconds));
      async.elapse(const Duration(milliseconds: 1000));
      expect(c.player.hp, playerHp - 2 - 4); // 2× тусгай
      c.dispose();
    });
  });

  test('Хараал: 2 үсэг дараагийн ээлжинд түгжигдэж, дараа нь тайлагдана', () {
    fakeAsync((async) {
      final c = makeController(
        enemies: [
          Enemy(
            name: 'Шулам',
            kind: EnemyKind.witch,
            maxHp: 100,
            attack: 1,
            special: EnemySpecial.curse,
            specialEvery: 1,
          ),
        ],
      );
      async.elapse(Duration(seconds: GameConfig.turnSeconds));
      async.elapse(const Duration(milliseconds: 1000));
      final cursed = c.board.where((t) => t.cursed).toList();
      expect(cursed.length, GameConfig.curseTiles);

      // Хараагдсан үсэг сонгогдохгүй
      c.selectTile(cursed.first);
      expect(c.selected, isEmpty);
      expect(c.player.hp, playerHp - 1);

      // Дайсны дараагийн ээлж эхлэхэд хуучин хараал арилна
      async.elapse(Duration(seconds: GameConfig.turnSeconds));
      expect(cursed.every((t) => !t.cursed), isTrue);
      c.dispose();
    });
  });

  test('Дайсан эдгээх чадвараар амиа нөхнө', () {
    fakeAsync((async) {
      final c = makeController(
        enemies: [
          Enemy(
            name: 'Үнэг',
            kind: EnemyKind.fox,
            maxHp: 40,
            attack: 1,
            special: EnemySpecial.heal,
            specialEvery: 1,
          ),
        ],
      );
      spell(c, 'морь');
      c.attack();
      final afterHit = c.enemy.hp;
      expect(afterHit, lessThan(40));
      async.elapse(const Duration(milliseconds: 1000));
      expect(c.enemy.hp, greaterThan(afterHit));
      expect(c.enemy.hp, lessThanOrEqualTo(40));
      c.dispose();
    });
  });

  test('Алтан үсэг 3× оноо, эдгээх үсэг баатрын амийг нөхнө', () {
    fakeAsync((async) {
      final c = makeController();
      // Эхлээд баатрыг шархлуулна
      async.elapse(Duration(seconds: GameConfig.turnSeconds));
      async.elapse(const Duration(milliseconds: 1000));
      expect(c.player.hp, playerHp - 3);

      c.board = [
        LetterTile(id: 2000, letter: 'у', points: 1, bonus: TileBonus.gold),
        LetterTile(id: 2001, letter: 'с', points: 1, bonus: TileBonus.heal),
        ...c.board.skip(2),
      ];
      c.selectTile(c.board[0]);
      c.selectTile(c.board[1]);
      expect(c.previewDamage, 4); // у(1×3) + с(1)
      c.attack();
      expect(c.enemy.hp, 100 - 4);
      expect(c.player.hp, playerHp); // +4, дээд хэмжээнээс хэтрэхгүй
      expect(c.healCount, 1);
      c.dispose();
    });
  });

  test('undo() сүүлийн үсгийг л буцаана', () {
    fakeAsync((async) {
      final c = makeController();
      spell(c, 'морь');
      c.undo();
      expect(c.currentWord, 'мор');
      c.dispose();
    });
  });
}
