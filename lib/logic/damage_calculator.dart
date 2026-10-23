/// Алгоритмын 5-р хэсэг: үгийн хохирол тооцох.
///
/// хохирол = (үсгүүдийн онооны нийлбэр) × (уртын үржвэр) × (combo бонус)
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

  /// Дараалсан зөв үгийн бонус: combo бүрт +10%, хамгийн ихдээ +50%.
  double comboMultiplier(int combo) => 1 + 0.1 * combo.clamp(0, 5);

  /// [combo] — энэ үгийн өмнө дараалан бүтээсэн зөв үгийн тоо.
  int calculate(String word, {int combo = 0}) {
    final base = word.split('').fold<int>(0, (sum, ch) => sum + pointsOf(ch));
    return (base * multiplier(word.length) * comboMultiplier(combo)).round();
  }
}
