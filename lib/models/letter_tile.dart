/// Самбар дээрх нэг үсгийн хавтан.
class LetterTile {
  LetterTile({
    required this.id,
    required this.letter,
    required this.points,
    this.isSelected = false,
  });

  final int id; // ижил үсэг 2 байсан ч ялгах дугаар
  final String letter; // жижиг үсгээр: 'а', 'ө' ...
  final int points; // 1, 2, 3, 5
  bool isSelected; // үгийн мөрөнд орсон эсэх
}
