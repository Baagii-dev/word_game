import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:word_battle/core/constants.dart';
import 'package:word_battle/logic/damage_calculator.dart';
import 'package:word_battle/main.dart' as app;
import 'package:word_battle/services/dictionary_service.dart';
import 'package:word_battle/widgets/letter_grid.dart';
import 'package:word_battle/widgets/letter_tile_widget.dart';

/// Бодит төхөөрөмж/simulator дээр апп-ыг эхнээс нь дуустал тоглоно
/// (splash, нүүр, түвшин, тулаан, үр дүн, дараагийн түвшин ...).
/// Ажиллуулах: `flutter test integration_test/play_through_test.dart -d DEVICE`
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester t, int ms) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<bool> waitFor(WidgetTester t, Finder f, {int seconds = 20}) async {
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 100));
      if (f.evaluate().isNotEmpty) return true;
    }
    return false;
  }

  void check(WidgetTester t, String where) {
    final e = t.takeException();
    if (e != null) fail('АЛДАА ($where): $e');
  }

  testWidgets('Бүх түвшинг эхнээс нь дуустал тоглох', (t) async {
    app.main();
    await t.pump(const Duration(seconds: 2));
    final dict = DictionaryService.instance;
    final calc = DamageCalculator(dict.letterPoints);
    final log = <String>[];

    /// Нэг түвшний тулааныг үр дүнгийн дэлгэц гартал тоглож, ялсан эсэхийг буцаана.
    Future<bool> playBattle(int level) async {
      var attacks = 0;
      var shuffles = 0;
      final used = <String>{};
      var lastEnemyMsg = '';
      final resultFinder = find.text('Бүтээсэн үг');
      final deadline = DateTime.now().add(const Duration(minutes: 8));

      while (resultFinder.evaluate().isEmpty &&
          DateTime.now().isBefore(deadline)) {
        await t.pump(const Duration(milliseconds: 200));
        check(t, 'тулаан $level');

        final grid = find.descendant(
          of: find.byType(LetterGrid),
          matching: find.byType(LetterTileWidget),
        );
        final tiles = grid
            .evaluate()
            .map((e) => e.widget as LetterTileWidget)
            .toList();
        if (tiles.length < GameConfig.boardSize ||
            find.textContaining('Таны ээлж').evaluate().isEmpty) {
          await wait(t, 300); // дайсны ээлж / шилжилт
          continue;
        }

        // Шинэ дайсан гарч ирэхэд ашигласан үгсийг цэвэрлэнэ
        final appeared = find.textContaining('гарч ирлээ');
        if (appeared.evaluate().isNotEmpty) {
          final msg = (appeared.evaluate().first.widget as Text).data ?? '';
          if (msg != lastEnemyMsg) {
            used.clear();
            lastEnemyMsg = msg;
          }
        }

        // Хамгийн их хохирол өгөх үгийг сонгоно
        final have = <String, int>{};
        for (final w in tiles) {
          have[w.tile.letter] = (have[w.tile.letter] ?? 0) + 1;
        }
        String? best;
        var bestDmg = -1;
        for (final w in dict.words) {
          if (w.length < GameConfig.minWordLength || w.length > 9) continue;
          if (used.contains(w)) continue;
          final need = <String, int>{};
          var ok = true;
          for (final ch in w.split('')) {
            need[ch] = (need[ch] ?? 0) + 1;
            if (need[ch]! > (have[ch] ?? 0)) {
              ok = false;
              break;
            }
          }
          if (!ok) continue;
          final d = calc.calculate(w);
          if (d > bestDmg) {
            bestDmg = d;
            best = w;
          }
        }
        if (best == null) {
          shuffles++;
          await t.tap(find.text('Холих'));
          await wait(t, 1500);
          continue;
        }

        final taken = <int>{};
        for (final ch in best.split('')) {
          final w = tiles.firstWhere(
            (x) => x.tile.letter == ch && !taken.contains(x.tile.id),
          );
          taken.add(w.tile.id);
          // Widget дахин үүсдэг тул id-ний түлхүүрээр дахин хайна
          await t.tap(
            find.descendant(
              of: find.byType(LetterGrid),
              matching: find.byKey(ValueKey(w.tile.id)),
            ),
          );
          await t.pump(const Duration(milliseconds: 120));
        }
        await t.tap(find.text('Довтлох'));
        attacks++;
        used.add(best);
        await wait(t, 2200); // дайсны ээлж, анимац дуустал
        check(t, 'довтолсны дараа');
      }

      expect(
        resultFinder.evaluate().isNotEmpty,
        isTrue,
        reason: 'түвшин $level 8 минутад дуусаагүй',
      );
      final won = find.text('Ялалт!').evaluate().isNotEmpty;
      log.add(
        'түвшин $level: ${won ? "ЯЛСАН" : "ЯЛАГДСАН"} '
        '(довтолгоо $attacks, холих $shuffles)',
      );
      await binding.takeScreenshot('result_level_$level');
      check(t, 'үр дүнгийн дэлгэц $level');
      return won;
    }

    // ---- Splash → нүүр ----
    expect(await waitFor(t, find.text('Тоглох'), seconds: 10), isTrue);
    check(t, 'нүүр');

    // ---- Заавар, тохиргоо ----
    await t.tap(find.text('Заавар'));
    await wait(t, 700);
    expect(find.text('Хэрхэн тоглох вэ?'), findsOneWidget);
    await t.drag(find.byType(ListView).last, const Offset(0, -2000));
    await wait(t, 500);
    check(t, 'заавар');
    await t.tap(find.text('Ойлголоо'));
    await wait(t, 600);
    await t.tap(find.text('Тохиргоо'));
    await wait(t, 700);
    check(t, 'тохиргоо');
    await t.pageBack();
    await wait(t, 600);

    // ---- Тоглох → 1-р түвшин ----
    await t.tap(find.text('Тоглох'));
    await wait(t, 800);
    await t.tap(find.textContaining('1. '));
    await wait(t, 900);
    check(t, 'түвшин 1 эхлэл');
    var won = await playBattle(1);

    for (var level = 2; level <= 3 && won; level++) {
      await t.tap(find.text('Дараагийн түвшин'));
      await wait(t, 1000);
      check(t, 'түвшин $level эхлэл');
      won = await playBattle(level);
    }

    await t.tap(find.text('Түвшин сонгох'));
    await wait(t, 800);
    check(t, 'түвшин сонгох руу буцсан');

    // ignore: avoid_print
    print('PLAYTHROUGH: ${log.join(' | ')}');
    expect(log, isNotEmpty);
  });
}
