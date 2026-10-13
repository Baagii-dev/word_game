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
}
