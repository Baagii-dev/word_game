import 'dart:io';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/core/constants.dart';
import 'package:word_battle/logic/battle_controller.dart';
import 'package:word_battle/logic/damage_calculator.dart';
import 'package:word_battle/logic/letter_generator.dart';
import 'package:word_battle/models/enemy.dart';
import 'package:word_battle/models/level.dart';
import 'package:word_battle/services/dictionary_service.dart';

/// Автомат тоглогч (bot) бүтэн тулааныг тоглож, дүрэм алдагдаагүй эсэхийг шалгана.
void main() {
  final dict = DictionaryService()
    ..loadFromList(File('assets/data/words.txt').readAsLinesSync());
  final calc = DamageCalculator(dict.letterPoints);

  /// Самбараас бүтэх хамгийн их хохирол өгөх үг (тоглогчийн дээд хязгаар).
  String? bestWord(BattleController c, Set<String> used) {
    final have = <String, int>{};
    for (final t in c.board) {
      have[t.letter] = (have[t.letter] ?? 0) + 1;
    }
    String? best;
    var bestDmg = -1;
    for (final w in dict.words) {
      if (w.length < GameConfig.minWordLength || w.length > c.board.length) {
        continue;
      }
      if (used.contains(w)) continue;
      final need = <String, int>{};
      var ok = true;
      for (final ch in w.split('')) {
        need[ch] = (need[ch] ?? 0) + 1;
        if (need[ch]! > (have[ch] ?? 0)) {
          ok = false;
          break;
        }
      }
      if (!ok) continue;
      final dmg = calc.calculate(w, combo: c.combo);
      if (dmg > bestDmg) {
        bestDmg = dmg;
        best = w;
      }
    }
    return best;
  }

  void spell(BattleController c, String word) {
    for (final ch in word.split('')) {
      final tile = c.board.firstWhere((t) => t.letter == ch && !t.isSelected);
      c.selectTile(tile);
    }
  }

  void expectBoardOk(BattleController c) {
    expect(c.board.length, GameConfig.boardSize);
    expect(c.board.map((t) => t.id).toSet().length, c.board.length);
    expect(c.board.any((t) => t.isSelected), isFalse);
    expect(c.selected, isEmpty);
    final counts = <String, int>{};
    for (final t in c.board) {
      counts[t.letter] = (counts[t.letter] ?? 0) + 1;
      expect(kExcludedLetters.contains(t.letter), isFalse);
    }
    expect(counts.values.every((n) => n <= GameConfig.maxSameLetter), isTrue);
  }

  /// [pick] — bot-ийн үг сонгох арга. Үр дүн: (төлөв, тоглосон үгийн тоо).
  (BattleStatus, int) play(
    Level level,
    int seed,
    String? Function(BattleController, Set<String>) pick,
  ) {
    late BattleStatus end;
    var words = 0;
    fakeAsync((async) {
      final c = BattleController(
        level: level,
        dictionary: dict,
        random: Random(seed),
      )..start();
      var wave = c.waveIndex;
      var used = <String>{};
      for (var turn = 0; turn < 200; turn++) {
        if (c.status == BattleStatus.won || c.status == BattleStatus.lost) {
          break;
        }
        expect(c.status, BattleStatus.playerTurn);
        expectBoardOk(c);
        final w = pick(c, used);
        expect(w, isNotNull, reason: 'самбарт үг алга (seed $seed)');
        spell(c, w!);
        expect(c.currentWord, w);
        final hpBefore = c.enemy.hp;
        final comboBefore = c.combo;
        c.attack();
        used.add(w);
        words++;

        // Зөв үг → хохирол, combo нэмэгдсэн, самбар нөхөгдсөн
        expect(c.enemy.hp, lessThan(hpBefore), reason: '"$w" хохирол өгөөгүй');
        expect(c.combo, comboBefore + 1);
        expectBoardOk(c);

        async.elapse(const Duration(milliseconds: 1300));
        if (c.waveIndex != wave) {
          wave = c.waveIndex;
          used = <String>{}; // шинэ дайсан → үг дахин ашиглаж болно
          expect(c.enemyTurns, 0);
          expect(c.timeLeft, GameConfig.turnSeconds);
        }
      }
      end = c.status;
      expect(
        end == BattleStatus.won || end == BattleStatus.lost,
        isTrue,
        reason: 'тулаан дуусаагүй (seed $seed)',
      );
      expect(c.player.hp, inInclusiveRange(0, GameConfig.playerMaxHp));
      c.dispose();
    });
    return (end, words);
  }

  final sampler = LetterGenerator(
    frequency: dict.letterFrequency,
    points: dict.letterPoints,
    random: Random(1),
  );
  String? randomHintWord(BattleController c, Set<String> used) =>
      sampler.findWord(c.board, dict.words, exclude: used);

  test('Hint-ийн үгээр тоглосон bot: бүх түвшин алдаагүй дуусна', () {
    for (final level in kLevels) {
      for (var seed = 1; seed <= 3; seed++) {
        final (status, words) = play(level, seed, randomHintWord);
        expect(words, greaterThan(0));
        expect(status, isIn([BattleStatus.won, BattleStatus.lost]));
      }
    }
  });

  test('Хамгийн сайн үгээр тоглосон bot: бүх түвшин давагдах боломжтой', () {
    // Тоглогчийн онолын дээд хязгаар. Үүнээс ялагдвал түвшин давагдахгүй.
    final results = <String>[];
    for (final level in kLevels) {
      var wins = 0;
      for (var seed = 1; seed <= 3; seed++) {
        final (status, _) = play(level, seed, bestWord);
        if (status == BattleStatus.won) wins++;
      }
      results.add('түвшин ${level.id}: $wins/3');
      expect(wins, greaterThan(0), reason: 'түвшин ${level.id} давагдахгүй');
    }
    // ignore: avoid_print
    print('best-bot: ${results.join(', ')}');
  });

  test('Ялагдал: хугацаа дуусгасаар тоглогч ялагдаж, тулаан дуусна', () {
    fakeAsync((async) {
      final level = Level(
        id: 97,
        name: 't',
        description: '',
        enemies: [Enemy(name: 'x', emoji: 'x', maxHp: 999, attack: 5)],
      );
      final c = BattleController(
        level: level,
        dictionary: dict,
        random: Random(2),
      )..start();
      for (var i = 0; i < 20 && c.status != BattleStatus.lost; i++) {
        async.elapse(Duration(seconds: GameConfig.turnSeconds + 2));
      }
      expect(c.status, BattleStatus.lost);
      expect(c.player.hp, 0);
      expect(c.stars, 0);
      c.dispose();
    });
  });

  test('pause() дайсны ээлж үед ч цагийг зогсооно, resume() үргэлжлүүлнэ', () {
    fakeAsync((async) {
      final level = Level(
        id: 96,
        name: 't',
        description: '',
        enemies: [Enemy(name: 'x', emoji: 'x', maxHp: 999, attack: 1)],
      );
      final c = BattleController(
        level: level,
        dictionary: dict,
        random: Random(3),
      )..start();
      spell(c, bestWord(c, {})!);
      c.attack(); // → enemyTurn
      expect(c.status, BattleStatus.enemyTurn);

      c.pause(); // дайсны ээлж үед (жишээ: апп далд орсон)
      async.elapse(const Duration(seconds: 6));
      expect(c.status, BattleStatus.playerTurn);
      expect(c.timeLeft, GameConfig.turnSeconds, reason: 'цаг зогсоогүй');

      c.resume();
      async.elapse(const Duration(seconds: 3));
      expect(c.timeLeft, GameConfig.turnSeconds - 3);
      c.dispose();
    });
  });
}
