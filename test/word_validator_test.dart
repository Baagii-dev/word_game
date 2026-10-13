import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/logic/word_validator.dart';

void main() {
  late WordValidator validator;

  setUp(() {
    validator = WordValidator({'морь', 'ус', 'ном'});
  });

  test('Толь бичигт байгаа үг зөв', () {
    expect(validator.check('морь'), WordCheck.ok);
  });

  test('Том үсгээр бичсэн ч зөв', () {
    expect(validator.check('МОРЬ'), WordCheck.ok);
  });

  test('1 үсэгтэй үг хэт богино', () {
    expect(validator.check('а'), WordCheck.tooShort);
  });

  test('Толь бичигт байхгүй үг', () {
    expect(validator.check('хххх'), WordCheck.notInDictionary);
  });

  test('Ашигласан үгийг давтаж болохгүй, reset хийвэл болно', () {
    validator.markUsed('ном');
    expect(validator.check('ном'), WordCheck.alreadyUsed);
    validator.reset();
    expect(validator.check('ном'), WordCheck.ok);
  });
}
