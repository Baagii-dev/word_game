import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/core/constants.dart';
import 'package:word_battle/logic/letter_generator.dart';
import 'package:word_battle/models/letter_tile.dart';
import 'package:word_battle/services/dictionary_service.dart';

/// Үсэг/үг үүсгэх алгоритмын бүрэн шалгалт (бодит толь бичгээр).
void main() {
  final dict = DictionaryService()
    ..loadFromList(File('assets/data/words.txt').readAsLinesSync());

  LetterGenerator gen(int seed) => LetterGenerator(
    frequency: dict.letterFrequency,
    points: dict.letterPoints,
    random: Random(seed),
  );

  int vowelsOf(List<LetterTile> b) =>
      b.where((t) => kVowels.contains(t.letter)).length;

  void expectValidBoard(List<LetterTile> board, {String? reason}) {
    expect(board.length, GameConfig.boardSize, reason: reason);
    expect(
      board.map((t) => t.id).toSet().length,
      board.length,
      reason: 'tile id давхардсан: $reason',
    );
    final min = (GameConfig.boardSize * GameConfig.minVowelRatio).ceil();
    final max = (GameConfig.boardSize * GameConfig.maxVowelRatio).floor();
    expect(vowelsOf(board), inInclusiveRange(min, max), reason: reason);
    final counts = <String, int>{};
    for (final t in board) {
      counts[t.letter] = (counts[t.letter] ?? 0) + 1;
      expect(kAlphabet.contains(t.letter), isTrue, reason: t.letter);
      expect(kExcludedLetters.contains(t.letter), isFalse, reason: t.letter);
      expect(t.points, dict.letterPoints[t.letter], reason: t.letter);
    }
    expect(
      counts.values.every((c) => c <= GameConfig.maxSameLetter),
      isTrue,
      reason: 'нэг үсэг хэт олон: $counts',
    );
  }

  test('words.txt-ийн бүх тэмдэгт цагаан толгойд байна (ө/ү зэрэг)', () {
    expect(dict.words, isNotEmpty);
    for (final w in dict.words) {
      for (final ch in w.split('')) {
        expect(kAlphabet.contains(ch), isTrue, reason: '"$w" дахь "$ch"');
      }
    }
  });

  test(
    'Толь бичигт 3-9 үсэгтэй үг хангалттай байна, хоёр үгтэй хэллэг байхгүй',
    () {
      expect(dict.words.where((w) => w.length >= 3).length, greaterThan(50000));
      expect(dict.words.any((w) => w.contains(' ')), isFalse);
      expect(dict.words.any((w) => w != w.toLowerCase()), isFalse);
    },
  );

  test(
    'Шинэ самбар 500 удаа: 12 үсэг, эгшиг 5–6, нэг үсэг ≤3, id давхцахгүй',
    () {
      for (var seed = 0; seed < 500; seed++) {
        expectValidBoard(gen(seed).fillBoard([]), reason: 'seed $seed');
      }
    },
  );

  test('Хэсэгчлэн нөхөх: ямар ч үсгийг хасаад нөхсөн самбар хэвийн хэвээр', () {
    final rnd = Random(99);
    for (var seed = 0; seed < 300; seed++) {
      final g = gen(seed);
      var board = g.fillBoard([]);
      // 1-8 санамсаргүй хавтан хасна (өөр өөр үсгийн сан үүснэ)
      for (var round = 0; round < 4; round++) {
        final shuffled = [...board]..shuffle(rnd);
        final removeCount = 1 + rnd.nextInt(8);
        final removed = shuffled.take(removeCount).map((t) => t.id).toSet();
        board = board.where((t) => !removed.contains(t.id)).toList();
        board = g.fillBoard(board);
        expectValidBoard(board, reason: 'seed $seed round $round');
      }
    }
  });

  test('Үсгийн давтамж: түгээмэл үсэг ховор үсгээс олон гарна', () {
    final counts = <String, int>{};
    final g = gen(5);
    for (var i = 0; i < 400; i++) {
      for (final t in g.fillBoard([])) {
        counts[t.letter] = (counts[t.letter] ?? 0) + 1;
      }
    }
    expect(counts['а']!, greaterThan(counts['ф'] ?? 0));
    expect(counts['л']!, greaterThan(counts['п'] ?? 0));
    // ховор үсэг ч заримдаа гарна (бүх үсэгт боломж бий) — 'ж' гэх мэт дунд зэрэг
    expect(counts.containsKey('ж'), isTrue);
  });

  test('Үсгийн оноо: түгээмэл бага, ховор их, бүгд 1/2/3/5', () {
    expect(dict.letterPoints.values.toSet().difference({1, 2, 3, 5}), isEmpty);
    expect(dict.letterPoints['а'], 1);
    expect(dict.letterPoints['ф']!, greaterThanOrEqualTo(3));
  });

  test('Шинээр үүссэн самбарт үргэлж 3+ үсэгтэй үг бүтнэ (400 самбар)', () {
    var unplayable = 0;
    for (var seed = 0; seed < 400; seed++) {
      final g = gen(seed);
      if (!g.hasPlayableWord(g.fillBoard([]), dict.words)) unplayable++;
    }
    expect(unplayable, 0);
  });

  test(
    'findWord: толь бичигт байгаа, самбараас бүтдэг, ашиглаагүй үг өгнө',
    () {
      for (var seed = 0; seed < 150; seed++) {
        final g = gen(seed);
        final board = g.fillBoard([]);
        final used = <String>{};
        for (var k = 0; k < 4; k++) {
          final w = g.findWord(board, dict.words, exclude: used);
          expect(w, isNotNull, reason: 'seed $seed');
          expect(dict.words.contains(w), isTrue);
          expect(used.contains(w), isFalse);
          expect(w!.length, inInclusiveRange(GameConfig.minWordLength, 6));
          final have = <String, int>{};
          for (final t in board) {
            have[t.letter] = (have[t.letter] ?? 0) + 1;
          }
          for (final ch in w.split('')) {
            have[ch] = (have[ch] ?? 0) - 1;
            expect(
              have[ch]!,
              greaterThanOrEqualTo(0),
              reason: '"$w" самбараас бүтэхгүй (seed $seed)',
            );
          }
          used.add(w);
        }
      }
    },
  );

  test('findWord: хоосон самбарт null', () {
    expect(gen(1).findWord([], dict.words), isNull);
  });

  test('Үг шалгалт: толь бичгийн үгийг самбараас бүтээхэд зөв гэж таарна', () {
    final g = gen(3);
    final board = g.fillBoard([]);
    final w = g.findWord(board, dict.words)!;
    expect(dict.words.contains(w.toLowerCase()), isTrue);
    // том үсгээр ч таарна (WordValidator жижиг болгодог)
    expect(dict.words.contains(w.toUpperCase()), isFalse);
  });
}
