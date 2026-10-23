import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/core/constants.dart';
import 'package:word_battle/logic/battle_controller.dart';
import 'package:word_battle/models/enemy.dart';
import 'package:word_battle/models/letter_tile.dart';
import 'package:word_battle/models/level.dart';
import 'package:word_battle/services/dictionary_service.dart';

void main() {
  final dict = DictionaryService()
    ..loadFromList(['морь', 'ном', 'гэр', 'нар', 'сар', 'хонь', 'цагаан']);

  Level makeLevel({int hp = 100}) => Level(
    id: 99,
    name: 'тест',
    description: '',
    enemies: [Enemy(name: 'Хулгана', emoji: '🐭', maxHp: hp, attack: 3)],
  );

  BattleController makeController({int hp = 100}) => BattleController(
    level: makeLevel(hp: hp),
    dictionary: dict,
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

  test('3-аас богино үг хүчингүй', () {
    fakeAsync((async) {
      final c = makeController();
      spell(c, 'ом');
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
      expect(c.player.hp, GameConfig.playerMaxHp - 3);
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

      expect(c.player.hp, GameConfig.playerMaxHp - 3);
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
      final level = Level(
        id: 98,
        name: 'тест',
        description: '',
        enemies: [
          Enemy(
            name: 'Мангас',
            emoji: '👹',
            maxHp: 100,
            attack: 2,
            specialEvery: 2,
          ),
        ],
      );
      final c = BattleController(level: level, dictionary: dict)..start();
      expect(c.specialIncoming, isFalse);
      expect(c.turnsUntilSpecial, 2);

      async.elapse(Duration(seconds: GameConfig.turnSeconds));
      async.elapse(const Duration(milliseconds: 1000));
      expect(c.player.hp, GameConfig.playerMaxHp - 2); // энгийн
      expect(c.specialIncoming, isTrue);

      async.elapse(Duration(seconds: GameConfig.turnSeconds));
      async.elapse(const Duration(milliseconds: 1000));
      expect(c.player.hp, GameConfig.playerMaxHp - 2 - 4); // 2× тусгай
      c.dispose();
    });
  });
}
