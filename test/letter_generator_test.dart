import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/core/constants.dart';
import 'package:word_battle/logic/letter_generator.dart';
import 'package:word_battle/services/dictionary_service.dart';

void main() {
  final dict = DictionaryService()
    ..loadFromList(['морь', 'ус', 'ном', 'гэр', 'нар', 'сар', 'хонь', 'цагаан']);

  LetterGenerator makeGenerator(int seed) => LetterGenerator(
        frequency: dict.letterFrequency,
        points: dict.letterPoints,
        random: Random(seed),
      );

  test('Самбар 12 үсэгтэй, эгшиг 35–50%, нэг үсэг 3-аас ихгүй', () {
    // 100 өөр санамсаргүй самбар шалгана
    for (var seed = 0; seed < 100; seed++) {
      final board = makeGenerator(seed).fillBoard([]);
      expect(board.length, GameConfig.boardSize);

      final vowels = board.where((t) => kVowels.contains(t.letter)).length;
      expect(vowels, inInclusiveRange(5, 6));

      final counts = <String, int>{};
      for (final t in board) {
        counts[t.letter] = (counts[t.letter] ?? 0) + 1;
      }
      expect(counts.values.every((c) => c <= GameConfig.maxSameLetter), isTrue);

      expect(board.any((t) => kExcludedLetters.contains(t.letter)), isFalse);
    }
  });

  test('Ховор үсэг түгээмэл үсгээс их оноотой', () {
    expect(dict.letterPoints['ф']!, greaterThan(dict.letterPoints['а']!));
  });
}
