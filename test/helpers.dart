import 'dart:io';

import 'package:word_battle/models/chapter.dart';
import 'package:word_battle/models/enemy.dart';

/// Тестэд зориулсан нэг дайсантай бүлэг.
Chapter testChapter({
  List<Enemy>? enemies,
  int playerHp = 30,
  int id = 99,
}) => Chapter(
  id: id,
  title: 'тест',
  subtitle: '',
  scene: Scene.steppe,
  playerHp: playerHp,
  intro: const ['эхлэл'],
  outro: const ['төгсгөл'],
  moral: 'сургамж',
  enemies:
      enemies ??
      [Enemy(name: 'Хулгана', kind: EnemyKind.mouse, maxHp: 100, attack: 3)],
);

/// assets/data/stories.json-оос бодит бүлгүүдийг ачаалж kChapters-д хийнэ.
List<Chapter> loadRealChapters() {
  final list = parseChapters(
    File('assets/data/stories.json').readAsStringSync(),
  );
  kChapters
    ..clear()
    ..addAll(list);
  return list;
}
