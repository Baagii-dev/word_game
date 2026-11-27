import 'enemy.dart';

/// Үлгэрийн замын саад: мод, хад, гол, мангасын зарц...
/// Баатар түүнд тулахад [word]-ийг үсгээр бүтээж давна. Тухайн үг замын
/// текстэд `[үг]` гэж тэмдэглэгдсэн байдаг (уншсан хүн сэжүүрийг олно).
class PathObstacle {
  const PathObstacle({
    required this.name,
    required this.word,
    required this.at,
    this.emoji,
    this.kind,
  });

  factory PathObstacle.fromJson(Map<String, dynamic> j) => PathObstacle(
    name: j['name'] as String,
    word: (j['word'] as String).toLowerCase(),
    at: ((j['at'] as num?)?.toDouble() ?? 0.5).clamp(0.15, 0.95),
    emoji: j['emoji'] as String?,
    kind: j['kind'] == null ? null : EnemyKind.parse(j['kind'] as String?),
  );

  final String name;

  /// Саадыг давах үг (жижиг үсгээр).
  final String word;

  /// Мөрийн хаана байрлах (0 = эхлэл, 1 = төгсгөл).
  final double at;

  /// Дүрс: emoji эсвэл кодоор зурсан дайсан ([kind]).
  final String? emoji;
  final EnemyKind? kind;
}

/// Замын нэг хуудас: нэг өгүүлбэр (баатар түүн дээгүүр алхана) ба саадууд.
class PathSegment {
  PathSegment({required this.text, required List<PathObstacle> obstacles})
    : obstacles = List.unmodifiable(
        [...obstacles]..sort((a, b) => a.at.compareTo(b.at)),
      );

  factory PathSegment.fromJson(Map<String, dynamic> j) => PathSegment(
    text: j['text'] as String,
    obstacles: [
      for (final o in (j['obstacles'] as List? ?? const []))
        PathObstacle.fromJson(o as Map<String, dynamic>),
    ],
  );

  /// `[үг]` тэмдэглэгээтэй текст.
  final String text;
  final List<PathObstacle> obstacles;

  /// Тэмдэглэгээг арилгасан цэвэр текст.
  String get plainText => text.replaceAll('[', '').replaceAll(']', '');

  /// Текстийг энгийн / тодотгосон хэсгүүдэд хуваана.
  List<({String text, bool marked})> get spans {
    final out = <({String text, bool marked})>[];
    final re = RegExp(r'\[([^\]]+)\]');
    var last = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) {
        out.add((text: text.substring(last, m.start), marked: false));
      }
      out.add((text: m.group(1)!, marked: true));
      last = m.end;
    }
    if (last < text.length) {
      out.add((text: text.substring(last), marked: false));
    }
    return out;
  }

  /// Текстэд тэмдэглэгдсэн үгс (жижиг үсгээр).
  Set<String> get markedWords => {
    for (final s in spans)
      if (s.marked) s.text.toLowerCase(),
  };
}
