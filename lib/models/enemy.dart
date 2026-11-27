import 'dart:math';

/// Дайсны төрөл — кодоор зурах дүрсийг (EnemyArt) сонгоно.
/// stories.json-д `"kind": "wolf"` гэх мэтээр нэрээр нь бичнэ.
enum EnemyKind {
  mouse, // Хулгана
  camel, // Тэмээ
  snake, // Могой
  wolf, // Чоно
  fox, // Үнэг
  bear, // Баавгай
  tiger, // Бар
  eagle, // Бүргэд
  swallow, // Хараацай
  sun, // Нар
  dragon, // Луу
  witch, // Шулам
  demon; // Мангас

  /// JSON-ы нэрээс төрөл олно. Танихгүй бол мангас болно.
  static EnemyKind parse(String? name) =>
      EnemyKind.values.asNameMap()[name] ?? EnemyKind.demon;
}

/// Дайсны тусгай чадвар — [Enemy.specialEvery] ээлж тутамд нэг удаа.
enum EnemySpecial {
  none,

  /// 2 дахин хүчтэй цохилт.
  strike,

  /// Энгийн цохилт + самбарын 2 үсгийг дараагийн ээлжинд хараална (ашиглаж болохгүй).
  curse,

  /// Энгийн цохилт + өөрийн амийн 25%-ийг нөхнө.
  heal;

  static EnemySpecial parse(String? name) =>
      EnemySpecial.values.asNameMap()[name] ?? EnemySpecial.none;

  /// Тулааны дэлгэц дээр харуулах тайлбар.
  String get label => switch (this) {
    EnemySpecial.none => '',
    EnemySpecial.strike => 'Хүчтэй цохилт',
    EnemySpecial.curse => 'Үсэг хараалах',
    EnemySpecial.heal => 'Шарх эдгээх',
  };
}

/// Дайсан. Зураг (`image`) байхгүй бол [kind]-аар кодоор зурсан дүрс харагдана.
class Enemy {
  Enemy({
    required this.name,
    required this.kind,
    required this.maxHp,
    required this.attack,
    this.special = EnemySpecial.none,
    this.specialEvery = 0,
    this.intro = '',
    this.image,
  }) : hp = maxHp;

  factory Enemy.fromJson(Map<String, dynamic> e) {
    final every = (e['specialEvery'] as num?)?.toInt() ?? 0;
    var special = EnemySpecial.parse(e['special'] as String?);
    // Хуучин бичлэг: зөвхөн specialEvery өгсөн бол хүчтэй цохилт гэж үзнэ.
    if (special == EnemySpecial.none && every > 0) {
      special = EnemySpecial.strike;
    }
    return Enemy(
      name: e['name'] as String,
      kind: EnemyKind.parse(e['kind'] as String?),
      maxHp: (e['maxHp'] as num).toInt(),
      attack: (e['attack'] as num).toInt(),
      special: special,
      specialEvery: special == EnemySpecial.none ? 0 : every,
      intro: e['intro'] as String? ?? '',
      image: e['image'] as String?,
    );
  }

  final String name;
  final EnemyKind kind;
  final int maxHp;
  final int attack; // нэг ээлжинд тоглогчоос хасах HP
  final EnemySpecial special;
  final int specialEvery; // N ээлж тутамд тусгай чадвар (0 = байхгүй)
  final String intro; // гарч ирэхдээ хэлэх үг
  final String? image; // сонголттой зураг: 'assets/images/characters/wolf.png'
  int hp;

  bool get isDead => hp <= 0;
  bool get hasSpecial => special != EnemySpecial.none && specialEvery > 0;

  void takeDamage(int amount) {
    hp = max(0, hp - amount);
  }

  void heal(int amount) {
    hp = min(maxHp, hp + amount);
  }

  /// Тулаан бүрт шинэ, бүтэн HP-тэй хуулбар үүсгэнэ.
  Enemy copy() => Enemy(
    name: name,
    kind: kind,
    maxHp: maxHp,
    attack: attack,
    special: special,
    specialEvery: specialEvery,
    intro: intro,
    image: image,
  );
}
