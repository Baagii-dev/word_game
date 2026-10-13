import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/constants.dart';

/// Толь бичиг ачаалах, үсгийн давтамж/оноо тооцоолох (алгоритмын 3, 4-р хэсэг).
class DictionaryService {
  DictionaryService();

  /// Апп даяар нэг л толь бичиг ашиглана.
  static final DictionaryService instance = DictionaryService();

  final Set<String> words = {}; // Set → үг шалгах O(1)
  final Map<String, double> letterFrequency = {}; // үсэг → давтамж (0..1)
  final Map<String, int> letterPoints = {}; // үсэг → 1/2/3/5 оноо

  /// assets/data/words.txt файлаас ачаална (мөр бүрт нэг үг).
  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/words.txt');
    loadFromList(const LineSplitter().convert(raw));
  }

  /// Тест болон бусад эх сурвалжаас үгийн жагсаалт өгөхөд ашиглана.
  void loadFromList(Iterable<String> lines) {
    words.clear();
    for (final line in lines) {
      final word = line.trim().toLowerCase();
      // хоосон мөр, '#' тайлбар, хоёр үгтэй хэллэгийг алгасна
      if (word.isEmpty || word.startsWith('#') || word.contains(' ')) continue;
      words.add(word);
    }
    _computeLetterStats();
  }

  /// Толь бичгийн бүх үсгийг тоолж давтамж, оноог гаргана.
  void _computeLetterStats() {
    final counts = <String, int>{for (final l in kAlphabet.split('')) l: 0};
    var total = 0;

    for (final word in words) {
      for (final ch in word.split('')) {
        if (counts.containsKey(ch)) {
          counts[ch] = counts[ch]! + 1;
          total++;
        }
      }
    }

    letterFrequency.clear();
    letterPoints.clear();
    for (final entry in counts.entries) {
      // +1 (Laplace smoothing): толь бичигт огт гараагүй үсэг 0 давтамжтай болохгүй
      final freq = (entry.value + 1) / (total + counts.length);
      letterFrequency[entry.key] = freq;
      letterPoints[entry.key] = pointsForFrequency(freq);
    }
  }

  /// Түгээмэл үсэг → бага оноо, ховор үсэг → их оноо.
  static int pointsForFrequency(double freq) {
    if (freq >= 0.06) return 1;
    if (freq >= 0.03) return 2;
    if (freq >= 0.01) return 3;
    return 5;
  }
}
