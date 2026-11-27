import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/chapter.dart';
import '../models/letter_tile.dart';
import '../models/tale_path.dart';
import '../services/dictionary_service.dart';
import 'letter_generator.dart';

enum PathStatus {
  /// Баатар текстийн мөрөн дээгүүр алхаж байна.
  walking,

  /// Саадтай тулсан — үг бүтээх ээлж (цаг явна).
  facing,

  /// Саадыг давлаа — богино анимацийн дараа алхаж эхэлнэ.
  cleared,

  /// Хуудасны төгсгөлд хүрлээ — дараагийн хуудас руу шилжиж байна.
  pageTurn,

  /// Бүх замыг туулсан.
  finished,

  /// Бүх зүрх дууссан.
  failed,
}

/// ҮЛГЭРИЙН ЗАМ — тулааны өмнөх адал явдал.
///
/// Баатар үлгэрийн өгүүлбэр дээгүүр зүүнээс баруун тийш алхана. Саадтай
/// тулахад зогсож, тухайн саадыг давах үгийг (текстэд `[үг]` гэж сануулсан)
/// самбарын үсгээр бүтээнэ. Хугацаа дуусвал нэг зүрх алдана.
class PathController extends ChangeNotifier {
  PathController({
    required this.chapter,
    required DictionaryService dictionary,
    Random? random,
  }) : _random = random ?? Random() {
    _generator = LetterGenerator(
      frequency: dictionary.letterFrequency,
      points: dictionary.letterPoints,
      bonuses: false,
      random: _random,
    );
  }

  static const Duration tick = Duration(milliseconds: 40);
  static const double _approach = 0.1; // саадаас хэр зайнд зогсох

  final Chapter chapter;
  final Random _random;
  late final LetterGenerator _generator;

  // ---------- Төлөв ----------
  int segmentIndex = 0;
  int obstacleIndex = 0; // одоогийн хуудасны дараагийн давагдаагүй саад
  double heroPos = 0.02; // 0..1, мөрийн дагуу
  PathStatus status = PathStatus.walking;
  int hearts = GameConfig.pathHearts;
  double timeLeft = GameConfig.pathObstacleSeconds.toDouble();
  int score = 0;
  String? message;
  List<LetterTile> board = [];
  final List<LetterTile> selected = [];

  // Анимацийн тоолуурууд
  int clearCount = 0; // саад давах бүрт
  int hurtCount = 0; // зүрх алдах бүрт
  int invalidCount = 0; // буруу үг бүрт

  Timer? _timer;
  double _cooldown = 0;
  bool _paused = false;
  bool _disposed = false;
  int _tileId = 100000;

  List<PathSegment> get segments => chapter.path;
  PathSegment get segment => segments[segmentIndex];
  bool get isOver =>
      status == PathStatus.finished || status == PathStatus.failed;
  bool get canAct => status == PathStatus.facing;
  String get currentWord => selected.map((t) => t.letter).join();

  /// Баатрын тулж буй (эсвэл дараагийн) саад.
  PathObstacle? get obstacle => obstacleIndex < segment.obstacles.length
      ? segment.obstacles[obstacleIndex]
      : null;

  /// Одоогийн хуудасны [i]-р саад давагдсан эсэх.
  bool isCleared(int i) => i < obstacleIndex;

  int get totalObstacles =>
      segments.fold(0, (s, seg) => s + seg.obstacles.length);

  // =====================================================
  void start() {
    if (segments.isEmpty) {
      status = PathStatus.finished;
      _notify();
      return;
    }
    status = PathStatus.walking;
    _timer?.cancel();
    _timer = Timer.periodic(tick, (_) => _onTick());
    _notify();
  }

  void pause() => _paused = true;
  void resume() => _paused = false;

  void _onTick() {
    if (_paused || _disposed) return;
    const dt = 0.04;
    switch (status) {
      case PathStatus.walking:
        final o = obstacle;
        final target = o == null ? 0.98 : o.at - _approach;
        heroPos = min(target, heroPos + GameConfig.pathWalkSpeed * dt);
        if (heroPos >= target) {
          o == null ? _endSegment() : _face();
        }
      case PathStatus.facing:
        timeLeft = max(0, timeLeft - dt);
        if (timeLeft <= 0) _hurt();
      case PathStatus.cleared:
        _cooldown -= dt;
        if (_cooldown <= 0) status = PathStatus.walking;
      case PathStatus.pageTurn:
        _cooldown -= dt;
        if (_cooldown <= 0) {
          segmentIndex++;
          obstacleIndex = 0;
          heroPos = 0.02;
          message = null;
          status = PathStatus.walking;
        }
      case PathStatus.finished || PathStatus.failed:
        _timer?.cancel();
    }
    _notify();
  }

  void _face() {
    status = PathStatus.facing;
    timeLeft = GameConfig.pathObstacleSeconds.toDouble();
    message = '${obstacle!.name} замыг хаалаа! Юу хэрэгтэй вэ?';
    _newBoard();
  }

  /// Саадын үгийн үсгүүд заавал орсон, бусад нь санамсаргүй самбар.
  void _newBoard() {
    selected.clear();
    final word = obstacle!.word;
    final tiles = [
      for (final ch in word.split(''))
        LetterTile(id: _tileId++, letter: ch, points: 1),
    ];
    final size = max(GameConfig.pathBoardSize, word.length + 3);
    board = _generator.fillBoard(tiles, size: size)..shuffle(_random);
  }

  void _hurt() {
    hearts--;
    hurtCount++;
    if (hearts <= 0) {
      status = PathStatus.failed;
      message = '${obstacle!.name} баатрыг буцаалаа...';
      _timer?.cancel();
      return;
    }
    timeLeft = GameConfig.pathObstacleSeconds.toDouble();
    message =
        'Хугацаа дууслаа! Нэг зүрх алдлаа. Үлгэрийн текстийг сайн уншаарай.';
    _newBoard();
  }

  void _endSegment() {
    if (segmentIndex >= segments.length - 1) {
      status = PathStatus.finished;
      message = 'Замыг туулж, мангасын үүдэнд хүрлээ!';
      _timer?.cancel();
    } else {
      status = PathStatus.pageTurn;
      _cooldown = 0.8;
    }
  }

  // ---------- Тоглогчийн үйлдэл ----------
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

  void undo() {
    if (canAct && selected.isNotEmpty) deselectTile(selected.last);
  }

  void clearSelection() {
    for (final t in selected) {
      t.isSelected = false;
    }
    selected.clear();
    _notify();
  }

  /// "Ашиглах" товч — бүтээсэн үгээ саадад хэрэглэнэ.
  void submit() {
    if (!canAct || selected.isEmpty) return;
    final o = obstacle!;
    final word = currentWord;
    if (word == o.word) {
      final bonus = timeLeft.ceil() * 2;
      score += 10 + bonus;
      clearCount++;
      message = '${word.toUpperCase()}! ${o.name} давагдлаа (+${10 + bonus})';
      obstacleIndex++;
      selected.clear();
      board = [];
      status = PathStatus.cleared;
      _cooldown = 0.7;
    } else {
      invalidCount++;
      timeLeft = max(0, timeLeft - GameConfig.pathWrongPenalty);
      message =
          '"${word.toUpperCase()}" энд тус болохгүй (−${GameConfig.pathWrongPenalty} сек)';
      clearSelection();
    }
    _notify();
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
