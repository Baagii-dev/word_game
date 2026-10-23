import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/logic/damage_calculator.dart';

void main() {
  final calc = DamageCalculator({'м': 2, 'о': 1, 'р': 1, 'ь': 3, 'а': 1});

  test('4 үсэгтэй үг үржвэргүй: морь = 2+1+1+3 = 7', () {
    expect(calc.calculate('морь'), 7);
  });

  test('Уртын үржвэр', () {
    expect(calc.multiplier(4), 1.0);
    expect(calc.multiplier(5), 1.5);
    expect(calc.multiplier(7), 2.0);
    expect(calc.multiplier(9), 3.0);
  });

  test('Жагсаалтад байхгүй үсэг 1 оноо', () {
    expect(calc.pointsOf('ф'), 1);
  });

  test('Combo бонус: өмнөх зөв үг бүрт +10%, 5-аас дээш нэмэгдэхгүй', () {
    expect(calc.comboMultiplier(0), 1.0);
    expect(calc.comboMultiplier(3), closeTo(1.3, 1e-9));
    expect(calc.comboMultiplier(9), closeTo(1.5, 1e-9));
    // морь = 7, combo 5 → 7 × 1.5 = 10.5 → 11
    expect(calc.calculate('морь', combo: 5), 11);
  });
}
