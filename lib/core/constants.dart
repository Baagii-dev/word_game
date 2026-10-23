/// Тоглоомын бүх тоон тохиргоо нэг дор.
/// Тоглоомыг хүндрүүлэх/хөнгөвчлөх бол зөвхөн энд өөрчилнө.
class GameConfig {
  static const int boardSize = 12; // самбар дээрх үсгийн тоо
  static const int minWordLength = 2; // хамгийн богино зөвшөөрөгдөх үг
  static const int turnSeconds = 30; // нэг ээлжийн хугацаа
  static const int maxSameLetter = 3; // нэг үсэг самбарт хамгийн ихдээ хэд байх
  static const double minVowelRatio = 0.35; // эгшиг багадаа 35%
  static const double maxVowelRatio = 0.50; // эгшиг ихдээ 50%
  static const int playerMaxHp = 30;
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
