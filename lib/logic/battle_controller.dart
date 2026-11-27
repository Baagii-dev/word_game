import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/chapter.dart';
import '../models/enemy.dart';
import '../models/letter_tile.dart';
import '../models/player.dart';
import '../services/dictionary_service.dart';
import 'damage_calculator.dart';
import 'letter_generator.dart';
import 'word_validator.dart';

enum BattleEvent { hit, heal, invalid, enemyAttack, curse, victory, defeat }

enum BattleStatus { playerTurn, enemyTurn, enemyDefeated, won, lost }

/// ТУЛААНЫ ДАВТАЛТ — бүх тоглоомын дүрэм энд.
///
/// Дэлгэц (BattleScreen) зөвхөн энэ классын төлөвийг харуулж, товч дарахад
/// методыг нь дуудна. Анимац/дууг тоолуур ([hitCount] г.м) болон [onEvent]-ээр
/// мэднэ.
class BattleController extends ChangeNotifier {
  /// [random] — тест дээр ижил үр дүн авахад (үгүй бол санамсаргүй).
  /// [bonuses] — алтан/эдгээх үсэг гаргах эсэх.
  BattleController({
    required this.chapter,
    required DictionaryService dictionary,
    Random? random,
    bool bonuses = true,
  }) : _random = random ?? Random(),
       _dictionaryWords = dictionary.words,
       _validator = WordValidator(dictionary.words),
       _damage = DamageCalculator(dictionary.letterPoints) {
    _generator = LetterGenerator(
      frequency: dictionary.letterFrequency,
      points: dictionary.letterPoints,
      bonuses: bonuses,
      random: _random,
    );
  }

  final Chapter chapter;
  final Random _random;
  final Set<String> _dictionaryWords;
  final WordValidator _validator;
  final DamageCalculator _damage;
  late final LetterGenerator _generator;

  // ---------- Төлөв (дэлгэц эдгээрийг уншина) ----------
  late final List<Enemy> enemies;
  late final Player player;
  int waveIndex = 0;
  List<LetterTile> board = [];
  final List<LetterTile> selected = []; // дарсан дарааллаар
  BattleStatus status = BattleStatus.playerTurn;
  int timeLeft = GameConfig.turnSeconds;
  String? message;

  /// Дайсны хэлсэн үг (гарч ирэх үед). Дэлгэц ярианы бөмбөлөгт харуулна.
  String? enemyQuote;
  int? lastDamage;
  int? lastHeal;

  // ---------- Статистик ----------
  int hintsLeft = GameConfig.hintsPerBattle;
  int enemyTurns = 0; // одоогийн дайсны хийсэн ээлж
  int combo = 0; // дараалан бүтээсэн зөв үгийн тоо
  int damageTotal = 0;
  int wordsCount = 0;
  String longestWord = '';

  /// Дуу/анимацийн дэлгэц сонсоно.
  void Function(BattleEvent event)? onEvent;
  int hitCount = 0; // баатар цохих бүрт (popup, дайсан сэгсрэх)
  int healCount = 0; // баатар эдгэрэх бүрт
  int invalidCount = 0; // буруу үг бүрт (үгийн мөр сэгсрэх)
  int enemyAttackCount = 0; // дайсан довтлох бүрт

  Timer? _timer;
  bool _disposed = false;
  bool _paused = false;

  Enemy get enemy => enemies[waveIndex];
  String get currentWord => selected.map((t) => t.letter).join();
  int get previewDamage =>
      selected.isEmpty ? 0 : _damage.calculateTiles(selected, combo: combo);
  bool get canAct => status == BattleStatus.playerTurn;
  bool get isOver => status == BattleStatus.won || status == BattleStatus.lost;

  /// Дараагийн ээлжинд дайсан тусгай чадвараа хэрэглэх эсэх.
  bool get specialIncoming =>
      enemy.hasSpecial && (enemyTurns + 1) % enemy.specialEvery == 0;

  /// Тусгай чадвар хүртэл үлдсэн ээлж (байхгүй бол null).
  int? get turnsUntilSpecial => enemy.hasSpecial
      ? enemy.specialEvery - (enemyTurns % enemy.specialEvery)
      : null;

  // =====================================================
  // ЭХЛЭХ
  // =====================================================
  void start() {
    enemies = chapter.createEnemies();
    player = Player(maxHp: chapter.playerHp);
    waveIndex = 0;
    _announceEnemy();
    _newBoard();
    _startPlayerTurn();
  }

  void _announceEnemy() {
    message = '${enemy.name} гарч ирлээ!';
    enemyQuote = enemy.intro.isEmpty ? null : enemy.intro;
  }

  // =====================================================
  // ТОГЛОГЧИЙН ҮЙЛДЛҮҮД
  // =====================================================
  void selectTile(LetterTile tile) {
    if (!canAct || tile.isSelected) return;
    if (tile.cursed) {
      message =
          '"${tile.letter.toUpperCase()}" үсэг хараагдсан — энэ ээлжинд ашиглах боломжгүй';
      _notify();
      return;
    }
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

  /// Сүүлд сонгосон үсгийг буцаана.
  void undo() {
    if (!canAct || selected.isEmpty) return;
    deselectTile(selected.last);
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
    enemyQuote = null;

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

    // 2. Хохирол (алтан үсэг тооцно)
    final dmg = _damage.calculateTiles(selected, combo: combo);
    combo++;
    _validator.markUsed(word);
    enemy.takeDamage(dmg);
    lastDamage = dmg;
    hitCount++;
    onEvent?.call(BattleEvent.hit);
    damageTotal += dmg;
    wordsCount++;
    if (word.length > longestWord.length) longestWord = word;
    final parts = <String>[
      combo > 1
          ? '${word.toUpperCase()} → $dmg хохирол! (combo ×$combo)'
          : '${word.toUpperCase()} → $dmg хохирол!',
    ];

    // 3. Эдгээх үсэг
    final healTiles = selected.where((t) => t.bonus == TileBonus.heal).length;
    if (healTiles > 0) {
      final healed = player.heal(healTiles * GameConfig.healTileAmount);
      if (healed > 0) {
        lastHeal = healed;
        healCount++;
        onEvent?.call(BattleEvent.heal);
        parts.add('+$healed амь');
      }
    }
    message = parts.join('  ');

    // 4. Ашигласан үсгийг хасаад самбар нөхөх
    board.removeWhere((t) => t.isSelected);
    selected.clear();
    board = _generator.fillBoard(board);
    if (!_generator.hasPlayableWord(board, _dictionaryWords)) _newBoard();

    // 5. Дайсан үхсэн үү?
    if (enemy.isDead) {
      _onEnemyDefeated();
    } else {
      _enemyTurn();
    }
  }

  /// "Санамж" товч — самбараас бүтэх нэг үгийн эхний үсэг, уртыг харуулна.
  /// Ээлж алдахгүй, гэхдээ тулаан бүрт хязгаартай.
  void hint() {
    if (!canAct || hintsLeft <= 0) return;
    final word = _generator.findWord(
      board,
      _dictionaryWords,
      exclude: _validator.usedWords,
    );
    if (word == null) {
      message = 'Санамж олдсонгүй — "Холих" дарж үзээрэй';
    } else {
      hintsLeft--;
      message =
          'Санамж: ${word[0].toUpperCase()}${'·' * (word.length - 1)} '
          '(${word.length} үсэг)';
    }
    _notify();
  }

  /// "Холих" товч — бүх үсэг шинэчлэгдэнэ, ээлж алдана.
  void shuffle() {
    if (!canAct) return;
    clearSelection(notify: false);
    combo = 0;
    enemyQuote = null;
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
    if (_paused) return; // pause үед цаг явахгүй (resume() эхлүүлнэ)
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

  /// Апп далд орох / цонх нээгдэхэд ээлжийн цаг зогсоно.
  void pause() {
    _paused = true;
    _timer?.cancel();
  }

  /// Буцаж ирэхэд үлдсэн цагаас үргэлжилнэ.
  void resume() {
    _paused = false;
    if (status == BattleStatus.playerTurn && !_disposed) _startTicker();
  }

  void _enemyTurn() {
    _timer?.cancel();
    if (status != BattleStatus.playerTurn) return; // давхар ээлжээс сэргийлнэ
    status = BattleStatus.enemyTurn;
    // Хараал зөвхөн нэг ээлж үйлчилнэ
    for (final t in board) {
      t.cursed = false;
    }
    _notify();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (_disposed) return;
      final special = specialIncoming;
      enemyTurns++;
      enemyAttackCount++;
      lastDamage = null;
      lastHeal = null;

      var damage = enemy.attack;
      if (special) {
        switch (enemy.special) {
          case EnemySpecial.strike:
            damage *= 2;
            message = '${enemy.name} хүчтэй цохилт хийлээ!';
          case EnemySpecial.curse:
            _curseTiles();
            message = '${enemy.name} үсгүүдийг хараалав!';
            onEvent?.call(BattleEvent.curse);
          case EnemySpecial.heal:
            final amount = max(
              1,
              enemy.maxHp * GameConfig.enemyHealPercent ~/ 100,
            );
            enemy.heal(amount);
            message = '${enemy.name} шархаа эдгээв! (+$amount)';
          case EnemySpecial.none:
            break;
        }
      }
      player.takeDamage(damage);
      onEvent?.call(BattleEvent.enemyAttack);

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

  /// Самбарын санамсаргүй [GameConfig.curseTiles] үсгийг хараална.
  void _curseTiles() {
    final pool = board.toList()..shuffle(_random);
    for (final t in pool.take(GameConfig.curseTiles)) {
      t.cursed = true;
    }
  }

  void _onEnemyDefeated() {
    _timer?.cancel();
    status = BattleStatus.enemyDefeated;
    enemyQuote = null;
    _notify();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_disposed) return;
      if (waveIndex < enemies.length - 1) {
        waveIndex++; // дараагийн дайсан
        enemyTurns = 0;
        _validator.reset();
        lastDamage = null;
        lastHeal = null;
        _announceEnemy();
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
  // ОНОО
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
