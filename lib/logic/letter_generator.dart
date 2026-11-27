import 'dart:math';

import '../core/constants.dart';
import '../models/letter_tile.dart';

/// Үсгийн самбар үүсгэх, нөхөх.
///
/// - Түгээмэл үсэг илүү олон гарна (давтамжаар жинлэсэн санамсаргүй сонголт)
/// - Эгшгийн хувь 35–50% хооронд байна
/// - Нэг үсэг 3-аас олон удаа гарахгүй
/// - [bonuses] бол шинэ үсэг заримдаа алтан эсвэл эдгээх болно
///   (самбарт тус бүр хамгийн ихдээ нэг)
class LetterGenerator {
  LetterGenerator({
    required this.frequency,
    required this.points,
    this.bonuses = true,
    Random? random,
  }) : _random = random ?? Random() {
    final allowed = frequency.keys.where((l) => !kExcludedLetters.contains(l));
    _vowels = allowed.where(kVowels.contains).toList();
    _consonants = allowed.where((l) => !kVowels.contains(l)).toList();
    _all = [..._vowels, ..._consonants];
  }

  final Map<String, double> frequency;
  final Map<String, int> points;
  final bool bonuses;
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

      if (pool.isEmpty) pool = kAlphabet.split('');

      final letter = _weightedPick(pool);
      final sameCount = result.where((t) => t.letter == letter).length;
      if (sameCount >= GameConfig.maxSameLetter) continue;

      result.add(
        LetterTile(
          id: _nextId++,
          letter: letter,
          points: points[letter] ?? 1,
          bonus: _rollBonus(result),
        ),
      );
    }
    return result;
  }

  /// Шинэ үсгийн тусгай шинж. Самбарт ижил шинжтэй үсэг байвал давхардуулахгүй.
  TileBonus _rollBonus(List<LetterTile> board) {
    if (!bonuses) return TileBonus.none;
    final r = _random.nextDouble();
    TileBonus pick;
    if (r < GameConfig.goldTileChance) {
      pick = TileBonus.gold;
    } else if (r < GameConfig.goldTileChance + GameConfig.healTileChance) {
      pick = TileBonus.heal;
    } else {
      return TileBonus.none;
    }
    return board.any((t) => t.bonus == pick) ? TileBonus.none : pick;
  }

  /// Давтамжаар жинлэсэн санамсаргүй сонголт.
  /// Жишээ: 'а' 10%, 'ф' 0.5% бол 'а' 20 дахин олон гарна.
  String _weightedPick(List<String> pool) {
    if (pool.isEmpty) return 'а';
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
    int minLength = GameConfig.minWordLength,
  }) {
    final available = _counts(board);
    for (final word in dictionary) {
      if (word.length < minLength || word.length > board.length) continue;
      if (_canBuild(word, available)) return true;
    }
    return false;
  }

  List<String>? _wordList;
  Set<String>? _wordListSource;

  /// Set-ийг жагсаалт болгож нэг удаа хадгална (санамж бүрт дахин хөрвүүлэхгүй).
  List<String> _listOf(Set<String> dictionary) {
    if (!identical(_wordListSource, dictionary) || _wordList == null) {
      _wordList = dictionary.toList(growable: false);
      _wordListSource = dictionary;
    }
    return _wordList ?? const [];
  }

  /// Санамжид: самбараас бүтэх, ашиглагдаагүй санамсаргүй нэг үг.
  /// Богино-дунд урттай (2..[maxLength]) үгийг сонгоно.
  ///
  /// Толь бичгийг санамсаргүй цэгээс эхлэн шалгаад [sample] үг олдмогц зогсоно
  /// (бүх толь бичгийг бүтнээр нь гүйлгэхгүй тул утсан дээр удаан биш).
  String? findWord(
    List<LetterTile> board,
    Set<String> dictionary, {
    Set<String> exclude = const {},
    int minLength = GameConfig.minWordLength,
    int maxLength = 6,
    int sample = 25,
  }) {
    final available = _counts(board);
    final list = _listOf(dictionary);
    if (list.isEmpty) return null;
    final start = _random.nextInt(list.length);
    final candidates = <String>[];
    for (var i = 0; i < list.length && candidates.length < sample; i++) {
      final word = list[(start + i) % list.length];
      if (word.length < minLength || word.length > maxLength) continue;
      if (exclude.contains(word)) continue;
      if (_canBuild(word, available)) candidates.add(word);
    }
    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }

  /// Ашиглах боломжтой (хараагдаагүй) үсгүүдийн тоо.
  Map<String, int> _counts(List<LetterTile> board) {
    final available = <String, int>{};
    for (final t in board) {
      if (t.cursed) continue;
      available[t.letter] = (available[t.letter] ?? 0) + 1;
    }
    return available;
  }

  bool _canBuild(String word, Map<String, int> available) {
    final need = <String, int>{};
    for (final ch in word.split('')) {
      final count = (need[ch] ?? 0) + 1;
      need[ch] = count;
      if (count > (available[ch] ?? 0)) return false;
    }
    return true;
  }
}
