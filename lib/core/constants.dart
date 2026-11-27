/// Апп-ын нэр нэг дор.
const String kAppTitle = 'Үлгэрийн Баатар';

/// Тоглоомын бүх тоон тохиргоо нэг дор.
/// Тоглоомыг хүндрүүлэх/хөнгөвчлөх бол зөвхөн энд өөрчилнө.
class GameConfig {
  static const int boardSize = 12; // самбар дээрх үсгийн тоо (6 × 2)
  static const int minWordLength = 2; // хамгийн богино зөвшөөрөгдөх үг
  static const int turnSeconds = 40; // нэг ээлжийн хугацаа
  static const int maxSameLetter = 3; // нэг үсэг самбарт хамгийн ихдээ хэд байх
  static const double minVowelRatio = 0.35; // эгшиг багадаа 35%
  static const double maxVowelRatio = 0.50; // эгшиг ихдээ 50%
  static const int hintsPerBattle = 3; // тулаан бүрт санамжийн тоо

  // ---- Тусгай үсэг ----
  static const double goldTileChance = 0.07; // шинэ үсэг алтан байх магадлал
  static const double healTileChance = 0.05; // шинэ үсэг эдгээх байх магадлал
  static const int healTileAmount = 4; // эдгээх үсэг нэг бүр хэдэн амь нөхөх

  // ---- Дайсны тусгай чадвар ----
  static const int curseTiles = 2; // хараал хэдэн үсгийг түгжих
  static const int enemyHealPercent = 25; // дайсан амийнхаа хэдэн хувийг нөхөх

  // ---- Үлгэрийн зам ----
  static const int pathHearts = 3; // замд алдаж болох удаа
  static const int pathObstacleSeconds = 15; // нэг саадад өгөх хугацаа
  static const int pathWrongPenalty = 2; // буруу үгэнд хасагдах секунд
  static const double pathWalkSpeed = 0.2; // мөрийн хэдэн хувийг секундэд алхах
  static const int pathBoardSize = 10; // саадын үсгийн самбар
}

/// Монгол кирилл цагаан толгой (35 үсэг)
const String kAlphabet = 'абвгдеёжзийклмноөпрстуүфхцчшщъыьэюя';

/// Эгшиг үсгүүд
const Set<String> kVowels = {
  'а',
  'э',
  'и',
  'о',
  'ө',
  'у',
  'ү',
  'е',
  'ё',
  'ю',
  'я',
  'ы',
};

/// Хэт ховор тул самбарт гаргахгүй үсгүүд
const Set<String> kExcludedLetters = {'щ', 'ъ'};
