/// Үсгийн хавтангийн тусгай шинж.
enum TileBonus {
  none,

  /// Алтан үсэг — оноо нь 3 дахин тооцогдоно.
  gold,

  /// Эдгээх үсэг — зөв үгэнд орвол баатрын амь нэмэгдэнэ.
  heal,
}

/// Самбар дээрх нэг үсгийн хавтан.
class LetterTile {
  LetterTile({
    required this.id,
    required this.letter,
    required this.points,
    this.bonus = TileBonus.none,
    this.isSelected = false,
    this.cursed = false,
  });

  final int id; // ижил үсэг 2 байсан ч ялгах дугаар
  final String letter; // жижиг үсгээр: 'а', 'ө' ...
  final int points; // 1, 2, 3, 5
  final TileBonus bonus;
  bool isSelected; // үгийн мөрөнд орсон эсэх
  bool cursed; // дайсан хараасан — энэ ээлжинд ашиглах боломжгүй

  /// Хохиролд нэмэгдэх оноо (алтан үсэг 3×).
  int get value => bonus == TileBonus.gold ? points * 3 : points;
}
