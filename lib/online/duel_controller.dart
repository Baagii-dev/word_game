import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../logic/damage_calculator.dart';
import '../logic/letter_generator.dart';
import '../logic/word_validator.dart';
import '../models/letter_tile.dart';
import '../services/dictionary_service.dart';
import 'online_models.dart';

/// 1v1 тулааны дүрэм (тоглогч талын). Тоглогч бүр ижил `seed`-ээс эхлэх
/// самбартай, ээлжгүйгээр зэрэг үг бүтээж өрсөлдөгчийн HP-г бууруулна.
///
/// `BattleController`-ын хэсгүүдийг (самбар, үг шалгах, хохирол) дахин ашиглана;
/// HP, ялагчийг сервер (DuelSession) тогтооно — энд зөвхөн дүрсэлнэ.
class DuelController extends ChangeNotifier {
  DuelController({
    required this.session,
    required DictionaryService dictionary,
    Random? random,
  }) : _words = dictionary.words,
       _validator = WordValidator(dictionary.words),
       _damage = DamageCalculator(dictionary.letterPoints),
       _generator = LetterGenerator(
         frequency: dictionary.letterFrequency,
         points: dictionary.letterPoints,
         // Ижил seed → хоёр тоглогч ижил эхний самбар авна
         random: random ?? Random(session.seed),
       ) {
    snapshot = session.current;
    timeLeft = session.duration.inSeconds;
    board = _generator.fillBoard([]);
    _sub = session.updates.listen(_onSnapshot);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (snapshot.finished || _disposed) return;
      if (timeLeft > 0) timeLeft--;
      if (timeLeft == 0) session.timeUp();
      _notify();
    });
  }

  final DuelSession session;
  final Set<String> _words;
  final WordValidator _validator;
  final DamageCalculator _damage;
  final LetterGenerator _generator;

  late DuelSnapshot snapshot;
  late int timeLeft;
  List<LetterTile> board = [];
  final List<LetterTile> selected = [];
  int combo = 0;
  int wordsCount = 0;
  int damageDealt = 0;
  String longestWord = '';
  String? message;
  int hitCount = 0; // миний цохилтын тоо (анимац)
  int invalidCount = 0; // буруу үг (сэгсрэх анимац)
  int lastDamage = 0;

  StreamSubscription<DuelSnapshot>? _sub;
  Timer? _ticker;
  bool _disposed = false;

  bool get canAct => !snapshot.finished;
  String get currentWord => selected.map((t) => t.letter).join();
  int get previewDamage =>
      currentWord.isEmpty ? 0 : _damage.calculate(currentWord, combo: combo);

  void _onSnapshot(DuelSnapshot s) {
    final before = snapshot;
    snapshot = s;
    if (s.opponentHits > before.opponentHits && s.opponentLastWord != null) {
      message = '${s.opponentName}: ${s.opponentLastWord!.toUpperCase()}';
    }
    if (s.finished) _ticker?.cancel();
    _notify();
  }

  void selectTile(LetterTile tile) {
    if (!canAct || tile.isSelected) return;
    tile.isSelected = true;
    selected.add(tile);
    _notify();
  }

  void deselectTile(LetterTile tile) {
    if (!canAct) return;
    tile.isSelected = false;
    selected.remove(tile);
    _notify();
  }

  void clearSelection({bool notify = true}) {
    for (final t in selected) {
      t.isSelected = false;
    }
    selected.clear();
    if (notify) _notify();
  }

  /// "Довтлох": зөв үг бол өрсөлдөгчийн HP-г бууруулна.
  void attack() {
    if (!canAct || selected.isEmpty) return;
    final word = currentWord;
    final result = _validator.check(word);
    if (result != WordCheck.ok) {
      message = switch (result) {
        WordCheck.tooShort =>
          'Хамгийн багадаа ${GameConfig.minWordLength} үсэг',
        WordCheck.alreadyUsed => '"$word" үгийг аль хэдийн ашигласан',
        WordCheck.notInDictionary => '"$word" гэсэн үг толь бичигт алга',
        WordCheck.ok => null,
      };
      clearSelection(notify: false);
      combo = 0;
      invalidCount++;
      _notify();
      return;
    }

    final dmg = _damage.calculate(word, combo: combo);
    combo++;
    _validator.markUsed(word);
    wordsCount++;
    damageDealt += dmg;
    lastDamage = dmg;
    hitCount++;
    if (word.length > longestWord.length) longestWord = word;
    message = combo > 1
        ? '${word.toUpperCase()} → $dmg хохирол! (combo ×$combo)'
        : '${word.toUpperCase()} → $dmg хохирол!';

    board.removeWhere((t) => t.isSelected);
    selected.clear();
    board = _generator.fillBoard(board);
    if (!_generator.hasPlayableWord(board, _words)) {
      board = _generator.fillBoard([]);
    }
    session.hit(dmg, word);
    _notify();
  }

  /// "Холих": шинэ самбар (ээлж алдахгүй, гэхдээ combo тасарна).
  void shuffle() {
    if (!canAct) return;
    clearSelection(notify: false);
    combo = 0;
    board = _generator.fillBoard([]);
    message = 'Үсэг солигдлоо — combo тасарлаа';
    _notify();
  }

  /// Тулаанаас гарах.
  Future<void> leave() => session.leave();

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// Тулааны дүнгийн оноо (онооны жагсаалтад нэмэгдэнэ).
  int get finalScore {
    final s = snapshot;
    final bonus = s.iWon ? 50 + s.myHp * 2 : 0;
    return damageDealt + bonus;
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    _sub?.cancel();
    session.dispose();
    super.dispose();
  }
}
