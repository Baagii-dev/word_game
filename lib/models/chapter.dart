import 'dart:convert';

import 'package:flutter/services.dart';

import 'enemy.dart';
import 'tale_path.dart';

/// Бүлгийн дэвсгэр (SceneBackground) — үлгэр бүр өөр орчинд өрнөнө.
enum Scene {
  steppe, // тал нутаг
  desert, // говь, халуун нар
  winter, // өвлийн ой
  mountain, // Алтай хангай, шөнө
  cave; // мангасын агуй

  static Scene parse(String? name) =>
      Scene.values.asNameMap()[name] ?? Scene.steppe;
}

/// Нэг бүлэг = нэг монгол үлгэр: эхлэлийн хуудсууд → үлгэрийн зам (саадуудыг
/// үгээр давах) → тулаан (хэд хэдэн дайсан) → төгсгөлийн хуудсууд + сургамж.
class Chapter {
  Chapter({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.scene,
    required this.playerHp,
    required this.intro,
    required this.outro,
    required this.moral,
    required List<Enemy> enemies,
    this.path = const [],
  }) : _enemyTemplates = enemies;

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String,
    subtitle: json['subtitle'] as String? ?? '',
    scene: Scene.parse(json['scene'] as String?),
    playerHp: (json['playerHp'] as num?)?.toInt() ?? 30,
    intro: _strings(json['intro']),
    outro: _strings(json['outro']),
    moral: json['moral'] as String? ?? '',
    path: [
      for (final p in (json['path'] as List? ?? const []))
        PathSegment.fromJson(p as Map<String, dynamic>),
    ],
    enemies: [
      for (final e in json['enemies'] as List)
        Enemy.fromJson(e as Map<String, dynamic>),
    ],
  );

  static List<String> _strings(dynamic raw) =>
      raw is List ? raw.whereType<String>().toList() : const [];

  final int id;
  final String title;
  final String subtitle;
  final Scene scene;
  final int playerHp;
  final List<String> intro;
  final List<String> outro;
  final String moral;

  /// Тулааны өмнөх үлгэрийн зам (хоосон бол шууд тулаан).
  final List<PathSegment> path;
  final List<Enemy> _enemyTemplates;

  int get waveCount => _enemyTemplates.length;

  /// Бүлгийн дайснууд (загвар). Тулаанд `createEnemies()` ашиглана.
  List<Enemy> get enemies => List.unmodifiable(_enemyTemplates);

  /// Сүүлчийн (хамгийн хүчтэй) дайсан.
  Enemy get boss => _enemyTemplates.last;

  /// Тулаан эхлэх бүрт дайснуудын шинэ хуулбар авна.
  List<Enemy> createEnemies() => _enemyTemplates.map((e) => e.copy()).toList();
}

/// Ачаалагдсан бүлгүүд (id-аар эрэмбэлсэн).
final List<Chapter> kChapters = [];

/// [id]-тай бүлэг, байхгүй бол null.
Chapter? chapterById(int id) {
  for (final c in kChapters) {
    if (c.id == id) return c;
  }
  return null;
}

/// JSON текстээс бүлгүүдийг уншина (тест ч ашиглана).
List<Chapter> parseChapters(String raw) {
  final list =
      (jsonDecode(raw) as List)
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .where((c) => c.waveCount > 0)
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));
  return list;
}

/// assets/data/stories.json-оос бүлгүүдийг ачаална.
Future<void> loadChapters() async {
  final raw = await rootBundle.loadString('assets/data/stories.json');
  kChapters
    ..clear()
    ..addAll(parseChapters(raw));
}
