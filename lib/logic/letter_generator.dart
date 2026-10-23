import 'dart:math';

import '../core/constants.dart';
import '../models/letter_tile.dart';

/// Алгоритмын 6-р хэсэг: үсгийн самбар үүсгэх, нөхөх.
///
/// - Түгээмэл үсэг илүү олон гарна (давтамжаар жинлэсэн санамсаргүй сонголт)
/// - Эгшгийн хувь 35–50% хооронд байна
/// - Нэг үсэг 3-аас олон удаа гарахгүй
class LetterGenerator {
  LetterGenerator({
    required this.frequency,
    required this.points,
    Random? random,
  }) : _random = random ?? Random() {
    final allowed = frequency.keys.where((l) => !kExcludedLetters.contains(l));
    _vowels = allowed.where(kVowels.contains).toList();
    _consonants = allowed.where((l) => !kVowels.contains(l)).toList();
    _all = [..._vowels, ..._consonants];
  }

  final Map<String, double> frequency;
  final Map<String, int> points;
  final Random _random;

  late final List<String> _vowels;
  late final List<String> _consonants;
  late final List<String> _all;
  int _nextId = 0;

  /// Самбарыг [GameConfig.boardSize] хүртэл нөхнө. Хоосон жагсаалт өгвөл шинэ самбар.
  List<LetterTile> fillBoard(List<LetterTile> board) {
    final result = List<LetterTile>.from(board);
    final size = GameConfig.boardSize;
    final minVowels = (size * GameConfig.minVowelRatio).ceil();
    final maxVowels = (size * GameConfig.maxVowelRatio).floor();

    var guard = 0; // хязгааргүй давталтаас хамгаална
    while (result.length < size && guard < 1000) {
      guard++;
      final vowelCount = result.where((t) => kVowels.contains(t.letter)).length;
      final remaining = size - result.length;

      List<String> pool;
      if (vowelCount + remaining <= minVowels) {
        pool = _vowels; // эгшиг дутуу → заавал эгшиг
      } else if (vowelCount >= maxVowels) {
        pool = _consonants; // эгшиг хэтэрсэн → заавал гийгүүлэгч
      } else {
        pool = _all;
      }

      final letter = _weightedPick(pool);
      final sameCount = result.where((t) => t.letter == letter).length;
      if (sameCount >= GameConfig.maxSameLetter) continue;

      result.add(
        LetterTile(id: _nextId++, letter: letter, points: points[letter] ?? 1),
      );
    }
    return result;
  }

  /// Давтамжаар жинлэсэн санамсаргүй сонголт.
  /// Жишээ: 'а' 10%, 'ф' 0.5% бол 'а' 20 дахин олон гарна.
  String _weightedPick(List<String> pool) {
    final total = pool.fold<double>(0, (s, l) => s + (frequency[l] ?? 0.001));
    var r = _random.nextDouble() * total;
    for (final letter in pool) {
      r -= frequency[letter] ?? 0.001;
      if (r <= 0) return letter;
    }
    return pool.last;
  }

  /// Самбараас [minLength]+ үсэгтэй дор хаяж нэг үг бүтэх эсэх.
  bool hasPlayableWord(
    List<LetterTile> board,
    Set<String> dictionary, {
    int minLength = 3,
  }) {
    final available = <String, int>{};
    for (final t in board) {
      available[t.letter] = (available[t.letter] ?? 0) + 1;
    }
    for (final word in dictionary) {
      if (word.length < minLength || word.length > board.length) continue;
      if (_canBuild(word, available)) return true;
    }
    return false;
  }

  bool _canBuild(String word, Map<String, int> available) {
    final need = <String, int>{};
    for (final ch in word.split('')) {
      need[ch] = (need[ch] ?? 0) + 1;
      if (need[ch]! > (available[ch] ?? 0)) return false;
    }
    return true;
  }
}
