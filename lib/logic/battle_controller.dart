import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/enemy.dart';
import '../models/letter_tile.dart';
import '../models/level.dart';
import '../models/player.dart';
import '../services/dictionary_service.dart';
import 'damage_calculator.dart';
import 'letter_generator.dart';
import 'word_validator.dart';

enum BattleEvent { hit, invalid, enemyAttack, victory, defeat }

enum BattleStatus { playerTurn, enemyTurn, enemyDefeated, won, lost }

/// Алгоритмын 2-р хэсэг: ТУЛААНЫ ДАВТАЛТ.
///
/// Бүх тоглоомын дүрэм энд байна. Дэлгэц (BattleScreen) зөвхөн
/// энэ классын төлөвийг харуулж, товч дарахад методыг нь дуудна.
class BattleController extends ChangeNotifier {
  BattleController({required this.level, required DictionaryService dictionary})
    : _dictionaryWords = dictionary.words,
      _validator = WordValidator(dictionary.words),
      _damage = DamageCalculator(dictionary.letterPoints),
      _generator = LetterGenerator(
        frequency: dictionary.letterFrequency,
        points: dictionary.letterPoints,
      );

  final Level level;
  final Set<String> _dictionaryWords;
  final WordValidator _validator;
  final DamageCalculator _damage;
  final LetterGenerator _generator;

  // ---------- Төлөв (дэлгэц эдгээрийг уншина) ----------
  late final List<Enemy> enemies;
  late final Player player;
  int waveIndex = 0;
  List<LetterTile> board = [];
  final List<LetterTile> selected = []; // дарсан дарааллаар
  BattleStatus status = BattleStatus.playerTurn;
  int timeLeft = GameConfig.turnSeconds;
  String? message;
  int? lastDamage;

  // ---------- Статистик (оноо тооцоход) ----------
  int combo = 0; // дараалан бүтээсэн зөв үгийн тоо
  int damageTotal = 0;
  int wordsCount = 0;
  String longestWord = '';

  /// Дуу/анимацийн дэлгэц сонсоно.
  void Function(BattleEvent event)? onEvent;
  int hitCount = 0; // цохилт бүрт нэмэгдэнэ (popup анимац)
  int invalidCount = 0; // буруу үг бүрт нэмэгдэнэ (сэгсрэх анимац)

  Timer? _timer;
  bool _disposed = false;

  Enemy get enemy => enemies[waveIndex];
  String get currentWord => selected.map((t) => t.letter).join();
  int get previewDamage =>
      currentWord.isEmpty ? 0 : _damage.calculate(currentWord, combo: combo);
  bool get canAct => status == BattleStatus.playerTurn;

  // =====================================================
  // ЭХЛЭХ
  // =====================================================
  void start() {
    enemies = level.createEnemies();
    player = Player(maxHp: GameConfig.playerMaxHp);
    waveIndex = 0;
    message = '${enemy.name} гарч ирлээ!';
    _newBoard();
    _startPlayerTurn();
  }

  // =====================================================
  // ТОГЛОГЧИЙН ҮЙЛДЛҮҮД
  // =====================================================
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

  /// "Довтлох" товч
  void attack() {
    if (!canAct || selected.isEmpty) return;
    final word = currentWord;

    // 1. Үг шалгах
    final result = _validator.check(word);
    if (result != WordCheck.ok) {
      message = switch (result) {
        WordCheck.tooShort =>
          'Хамгийн багадаа ${GameConfig.minWordLength} үсэг',
        WordCheck.alreadyUsed => '"$word" үгийг аль хэдийн ашигласан',
        WordCheck.notInDictionary => '"$word" гэсэн үг толь бичигт алга',
        WordCheck.ok => null,
      };
      clearSelection(notify: false); // ээлж алдахгүй
      combo = 0;
      invalidCount++;
      onEvent?.call(BattleEvent.invalid);
      _notify();
      return;
    }

    // 2. Хохирол
    final dmg = _damage.calculate(word, combo: combo);
    combo++;
    _validator.markUsed(word);
    enemy.takeDamage(dmg);
    lastDamage = dmg;
    hitCount++;
    onEvent?.call(BattleEvent.hit);
    damageTotal += dmg;
    wordsCount++;
    if (word.length > longestWord.length) longestWord = word;
    message = combo > 1
        ? '${word.toUpperCase()} → $dmg хохирол! (combo ×$combo)'
        : '${word.toUpperCase()} → $dmg хохирол!';

    // 3. Ашигласан үсгийг хасаад самбар нөхөх
    board.removeWhere((t) => t.isSelected);
    selected.clear();
    board = _generator.fillBoard(board);
    if (!_generator.hasPlayableWord(board, _dictionaryWords)) _newBoard();

    // 4. Дайсан үхсэн үү?
    if (enemy.isDead) {
      _onEnemyDefeated();
    } else {
      _enemyTurn();
    }
  }

  /// "Холих" товч — бүх үсэг шинэчлэгдэнэ, ээлж алдана.
  void shuffle() {
    if (!canAct) return;
    clearSelection(notify: false);
    combo = 0;
    _newBoard();
    message = 'Үсэг солигдлоо — ээлж алдлаа';
    _enemyTurn();
  }

  // =====================================================
  // ДОТООД ЛОГИК
  // =====================================================
  void _startPlayerTurn() {
    status = BattleStatus.playerTurn;
    timeLeft = GameConfig.turnSeconds;
    _startTicker();
    _notify();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      timeLeft--;
      if (timeLeft <= 0) {
        message = 'Хугацаа дууслаа!';
        combo = 0;
        clearSelection(notify: false);
        _enemyTurn();
        return;
      }
      _notify();
    });
  }

  /// Апп далд ороход ээлжийн цаг зогсоно.
  void pause() {
    if (status == BattleStatus.playerTurn) _timer?.cancel();
  }

  /// Буцаж ирэхэд үлдсэн цагаас үргэлжилнэ.
  void resume() {
    if (status == BattleStatus.playerTurn && !_disposed) _startTicker();
  }

  void _enemyTurn() {
    _timer?.cancel();
    // давхар ээлж гарахаас сэргийлнэ
    if (status != BattleStatus.playerTurn) return;
    status = BattleStatus.enemyTurn;
    _notify();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (_disposed) return;
      player.takeDamage(enemy.attack);
      onEvent?.call(BattleEvent.enemyAttack);
      lastDamage = null;
      if (player.isDead) {
        status = BattleStatus.lost;
        message = 'Та ялагдлаа...';
        onEvent?.call(BattleEvent.defeat);
        _notify();
      } else {
        _startPlayerTurn();
      }
    });
  }

  void _onEnemyDefeated() {
    _timer?.cancel();
    status = BattleStatus.enemyDefeated;
    _notify();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_disposed) return;
      if (waveIndex < enemies.length - 1) {
        waveIndex++; // дараагийн дайсан
        _validator.reset();
        lastDamage = null;
        message = '${enemy.name} гарч ирлээ!';
        _newBoard();
        _startPlayerTurn();
      } else {
        status = BattleStatus.won;
        message = 'Ялалт!';
        onEvent?.call(BattleEvent.victory);
        _notify();
      }
    });
  }

  /// Шинэ самбар. Үг бүтэхгүй самбар гарвал 5 хүртэл удаа дахин үүсгэнэ.
  void _newBoard() {
    for (var i = 0; i < 5; i++) {
      board = _generator.fillBoard([]);
      if (_generator.hasPlayableWord(board, _dictionaryWords)) return;
    }
  }

  // =====================================================
  // ОНОО (алгоритмын 7-р хэсэг)
  // =====================================================
  int get finalScore {
    if (status != BattleStatus.won) return damageTotal;
    return damageTotal + player.hp * 10 + longestWord.length * 5;
  }

  int get stars {
    if (status != BattleStatus.won) return 0;
    final ratio = player.hp / player.maxHp;
    if (ratio >= 0.7) return 3;
    if (ratio >= 0.3) return 2;
    return 1;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
