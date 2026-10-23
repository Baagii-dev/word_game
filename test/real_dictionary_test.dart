import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/logic/letter_generator.dart';
import 'package:word_battle/services/dictionary_service.dart';

void main() {
  final lines = File('assets/data/words.txt').readAsLinesSync();
  final dict = DictionaryService()..loadFromList(lines);

  test('Бодит толь бичиг ачаалагдана, үндсэн үгс байна', () {
    expect(dict.words.length, greaterThan(50000));
    for (final w in ['морь', 'ном', 'гэр', 'хонь', 'луу']) {
      expect(dict.words.contains(w), isTrue, reason: w);
    }
    expect(dict.words.contains('анэу'), isFalse); // товчлол хасагдсан
    expect(dict.letterPoints.values.toSet(), isNotEmpty);
  });

  test('Самбарт үг бүтэх эсэх шалгалт хурдан (100 самбар < 3 сек)', () {
    final gen = LetterGenerator(
      frequency: dict.letterFrequency,
      points: dict.letterPoints,
      random: Random(1),
    );
    final sw = Stopwatch()..start();
    var playable = 0;
    for (var i = 0; i < 100; i++) {
      if (gen.hasPlayableWord(gen.fillBoard([]), dict.words)) playable++;
    }
    sw.stop();
    expect(playable, greaterThan(95));
    expect(sw.elapsedMilliseconds, lessThan(3000));
  });
}
