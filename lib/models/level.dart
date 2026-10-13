import 'enemy.dart';

/// Нэг түвшин = хэд хэдэн дайсан (wave).
class Level {
  Level({
    required this.id,
    required this.name,
    required this.description,
    required List<Enemy> enemies,
  }) : _enemyTemplates = enemies;

  final int id;
  final String name;
  final String description;
  final List<Enemy> _enemyTemplates;

  int get waveCount => _enemyTemplates.length;

  /// Тулаан эхлэх бүрт дайснуудын шинэ хуулбар авна
  /// (өмнөх тулаанд хасагдсан HP үлдэхгүй).
  List<Enemy> createEnemies() => _enemyTemplates.map((e) => e.copy()).toList();
}

/// Тоглоомын түвшнүүд. Монгол домгийн дайснуудыг энд нэмнэ.
final List<Level> kLevels = [
  Level(
    id: 1,
    name: 'Тал нутаг',
    description: 'Эхлэлийн түвшин',
    enemies: [
      Enemy(name: 'Хулгана', emoji: '🐭', maxHp: 12, attack: 2),
      Enemy(name: 'Могой', emoji: '🐍', maxHp: 16, attack: 3),
      Enemy(name: 'Чоно', emoji: '🐺', maxHp: 22, attack: 4),
    ],
  ),
  Level(
    id: 2,
    name: 'Ойн зах',
    description: 'Дайснууд хүчирхэгжинэ',
    enemies: [
      Enemy(name: 'Үнэг', emoji: '🦊', maxHp: 20, attack: 4),
      Enemy(name: 'Баавгай', emoji: '🐻', maxHp: 30, attack: 5),
      Enemy(name: 'Бар', emoji: '🐯', maxHp: 32, attack: 5),
      Enemy(name: 'Хар шувуу', emoji: '🦅', maxHp: 28, attack: 6),
    ],
  ),
  Level(
    id: 3,
    name: 'Мангасын агуй',
    description: 'Эцсийн тулаан',
    enemies: [
      Enemy(name: 'Луу', emoji: '🐉', maxHp: 40, attack: 6),
      Enemy(name: 'Шулам', emoji: '🧟', maxHp: 45, attack: 7),
      Enemy(name: 'Мангас', emoji: '👹', maxHp: 65, attack: 8),
    ],
  ),
];
