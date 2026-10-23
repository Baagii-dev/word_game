import 'dart:convert';

import 'package:flutter/services.dart';

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

  factory Level.fromJson(Map<String, dynamic> json) => Level(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    enemies: [
      for (final e in json['enemies'] as List)
        Enemy(
          name: e['name'] as String,
          emoji: e['emoji'] as String,
          maxHp: (e['maxHp'] as num).toInt(),
          attack: (e['attack'] as num).toInt(),
        ),
    ],
  );

  int get waveCount => _enemyTemplates.length;

  /// Тулаан эхлэх бүрт дайснуудын шинэ хуулбар авна
  /// (өмнөх тулаанд хасагдсан HP үлдэхгүй).
  List<Enemy> createEnemies() => _enemyTemplates.map((e) => e.copy()).toList();
}

/// assets/data/levels.json-оос түвшнүүдийг ачаална.
/// Файл уншигдахгүй бол доорх анхдагч түвшнүүд үлдэнэ.
Future<void> loadLevels() async {
  try {
    final raw = await rootBundle.loadString('assets/data/levels.json');
    final list = (jsonDecode(raw) as List)
        .map((e) => Level.fromJson(e as Map<String, dynamic>))
        .toList();
    if (list.isEmpty) return;
    kLevels
      ..clear()
      ..addAll(list);
  } catch (_) {
    // анхдагч түвшнүүдийг ашиглана
  }
}

/// Тоглоомын түвшнүүд (анхдагч). Монгол домгийн дайснуудыг levels.json-д нэмнэ.
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
