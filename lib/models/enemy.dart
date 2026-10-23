import 'dart:math';

/// Дайсан. Зураг бэлэн болтол emoji-гоор түр дүрсэлнэ.
class Enemy {
  Enemy({
    required this.name,
    required this.emoji,
    required this.maxHp,
    required this.attack,
  }) : hp = maxHp;

  final String name;
  final String
  emoji; // дараа нь 'assets/images/enemies/chono.png' болгож солино
  final int maxHp;
  final int attack; // нэг ээлжинд тоглогчоос хасах HP
  int hp;

  bool get isDead => hp <= 0;

  void takeDamage(int amount) {
    hp = max(0, hp - amount);
  }

  /// Түвшин бүрт шинэ, бүтэн HP-тэй хуулбар үүсгэнэ.
  Enemy copy() => Enemy(name: name, emoji: emoji, maxHp: maxHp, attack: attack);
}
