import 'dart:math';

/// Дайсны төрөл — кодоор зурах дүрсийг (EnemyArt) сонгоно.
/// levels.json-д `"kind": "wolf"` гэх мэтээр нэрээр нь бичнэ.
enum EnemyKind {
  mouse, // Хулгана
  snake, // Могой
  wolf, // Чоно
  fox, // Үнэг
  bear, // Баавгай
  tiger, // Бар
  eagle, // Хар шувуу
  dragon, // Луу
  witch, // Шулам
  demon; // Мангас

  /// JSON-ы нэрээс төрөл олно. Танихгүй бол мангас болно.
  static EnemyKind parse(String? name) =>
      EnemyKind.values.asNameMap()[name] ?? EnemyKind.demon;
}

/// Дайсан. Зураг (`image`) байхгүй бол [kind]-аар кодоор зурсан дүрс харагдана.
class Enemy {
  Enemy({
    required this.name,
    required this.kind,
    required this.maxHp,
    required this.attack,
    this.specialEvery = 0,
    this.image,
  }) : hp = maxHp;

  final String name;
  final EnemyKind kind;
  final int maxHp;
  final int attack; // нэг ээлжинд тоглогчоос хасах HP
  final String? image; // сонголттой зураг: 'assets/images/characters/wolf.png'
  final int specialEvery; // N ээлж тутамд 2× хүчтэй цохилт (0 = байхгүй)
  int hp;

  bool get isDead => hp <= 0;

  void takeDamage(int amount) {
    hp = max(0, hp - amount);
  }

  /// Түвшин бүрт шинэ, бүтэн HP-тэй хуулбар үүсгэнэ.
  Enemy copy() => Enemy(
    name: name,
    kind: kind,
    maxHp: maxHp,
    attack: attack,
    specialEvery: specialEvery,
    image: image,
  );
}
