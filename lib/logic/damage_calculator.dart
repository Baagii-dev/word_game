/// Алгоритмын 5-р хэсэг: үгийн хохирол тооцох.
///
/// хохирол = (үсгүүдийн онооны нийлбэр) × (уртын үржвэр)
class DamageCalculator {
  DamageCalculator(this.letterPoints);

  final Map<String, int> letterPoints;

  int pointsOf(String letter) => letterPoints[letter] ?? 1;

  double multiplier(int length) {
    if (length >= 9) return 3.0;
    if (length >= 7) return 2.0;
    if (length >= 5) return 1.5;
    return 1.0;
  }

  int calculate(String word) {
    final base = word.split('').fold<int>(0, (sum, ch) => sum + pointsOf(ch));
    return (base * multiplier(word.length)).round();
  }
}
