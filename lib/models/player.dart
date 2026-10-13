import 'dart:math';

/// Тоглогчийн баатар.
/// Анхаар: Flutter-т `Hero` гэсэн widget байдаг тул `Player` гэж нэрлэв.
class Player {
  Player({required this.maxHp}) : hp = maxHp;

  final int maxHp;
  int hp;

  bool get isDead => hp <= 0;

  void takeDamage(int amount) {
    hp = max(0, hp - amount);
  }
}
