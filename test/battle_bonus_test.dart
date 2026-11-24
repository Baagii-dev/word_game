import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/core/constants.dart';
import 'package:word_battle/logic/battle_controller.dart';
import 'package:word_battle/models/enemy.dart';
import 'package:word_battle/models/level.dart';
import 'package:word_battle/services/dictionary_service.dart';
import 'package:word_battle/wallet/wallet_models.dart';

void main() {
  final dict = DictionaryService()
    ..loadFromList(['морь', 'ном', 'гэр', 'нар', 'сар', 'хонь', 'цагаан']);
  final level = Level(
    id: 90,
    name: 't',
    description: '',
    enemies: [Enemy(name: 'x', emoji: 'x', maxHp: 99, attack: 2)],
  );

  test('Бэлтгэлгүй үед анхдагч утгатай', () {
    fakeAsync((async) {
      final c = BattleController(level: level, dictionary: dict)..start();
      expect(c.player.maxHp, GameConfig.playerMaxHp);
      expect(c.hintsLeft, GameConfig.hintsPerBattle);
      expect(c.timeLeft, GameConfig.turnSeconds);
      expect(c.message, isNot(contains('Бэлтгэл')));
      c.dispose();
    });
  });

  test('Бэлтгэл: амь, санамж, цаг нэмэгдэж, мессежид харагдана', () {
    fakeAsync((async) {
      const b = BattleBonuses(extraHints: 3, extraSeconds: 10, extraHp: 10);
      final c = BattleController(level: level, dictionary: dict, bonuses: b)
        ..start();
      expect(c.player.hp, GameConfig.playerMaxHp + 10);
      expect(c.player.maxHp, GameConfig.playerMaxHp + 10);
      expect(c.hintsLeft, GameConfig.hintsPerBattle + 3);
      expect(c.timeLeft, GameConfig.turnSeconds + 10);
      expect(c.message, contains('+10 амь'));

      // Ээлж бүр шинэ хугацаатай эхэлнэ (дайсны ээлжийн дараа ч +10)
      async.elapse(Duration(seconds: GameConfig.turnSeconds + 10));
      async.elapse(const Duration(milliseconds: 1000));
      expect(c.timeLeft, GameConfig.turnSeconds + 10);
      c.dispose();
    });
  });
}
