import '../core/constants.dart';

/// Үг шалгалтын үр дүн
enum WordCheck { ok, tooShort, alreadyUsed, notInDictionary }

/// Алгоритмын 3-р хэсэг: үг зөв эсэхийг шалгана.
class WordValidator {
  WordValidator(this.dictionary);

  final Set<String> dictionary;
  final Set<String> usedWords = {}; // нэг дайсантай тулалдахад давтахгүй

  WordCheck check(String rawWord) {
    final word = rawWord.toLowerCase();
    if (word.length < GameConfig.minWordLength) return WordCheck.tooShort;
    if (usedWords.contains(word)) return WordCheck.alreadyUsed;
    if (!dictionary.contains(word)) return WordCheck.notInDictionary;
    return WordCheck.ok;
  }

  void markUsed(String word) => usedWords.add(word.toLowerCase());

  void reset() => usedWords.clear();
}
