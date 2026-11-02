import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:word_battle/main.dart' as app;
import 'package:word_battle/services/storage_service.dart';

/// Бүх түвшинд ЯЛАГДАХ замыг төхөөрөмж дээр шалгана: тоглогч юу ч хийлгүй
/// "Холих" дарж ээлж алдсаар HP нь дуусна → ялагдлын дэлгэц → дахин тоглох /
/// түвшин сонгох.
/// Ажиллуулах: `flutter test integration_test/lose_through_test.dart -d DEVICE`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('Бүх түвшинд ялагдах', (t) async {
    app.main();
    await t.pump(const Duration(seconds: 2));
    // Бүх түвшнийг нээж өгнө (өмнөх тоглолтоос үл хамаарна)
    await StorageService.instance.saveResult(levelId: 1, score: 1, stars: 1);
    await StorageService.instance.saveResult(levelId: 2, score: 1, stars: 1);
    final log = <String>[];

    Future<void> loseBattle(String label) async {
      var shuffles = 0;
      final result = find.text('Бүтээсэн үг');
      final deadline = DateTime.now().add(const Duration(minutes: 5));
      while (result.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
        await t.pump(const Duration(milliseconds: 200));
        check(t, 'тулаан ($label)');
        if (find.textContaining('Таны ээлж').evaluate().isEmpty) continue;
        await t.tap(find.text('Холих'));
        shuffles++;
        await wait(t, 1400);
      }
      expect(result.evaluate().isNotEmpty, isTrue, reason: '$label дуусаагүй');
      expect(
        find.text('Ялагдал'),
        findsOneWidget,
        reason: '$label ялагдал биш',
      );
      expect(find.text('Дараагийн түвшин'), findsNothing);
      check(t, 'ялагдлын дэлгэц ($label)');
      log.add('$label: ЯЛАГДСАН (холих $shuffles)');
    }

    expect(await waitFor(t, find.text('Тоглох'), seconds: 10), isTrue);
    await t.tap(find.text('Тоглох'));
    await wait(t, 800);

    for (var level = 1; level <= 3; level++) {
      await t.tap(find.textContaining('$level. '));
      await wait(t, 900);
      await loseBattle('түвшин $level');

      if (level == 1) {
        // "Дахин тоглох" → шинэ тулаан эхэлж, дахин ялагдана
        await t.tap(find.text('Дахин тоглох'));
        await wait(t, 900);
        await loseBattle('түвшин 1 (дахин)');
      }
      await t.tap(find.text('Түвшин сонгох'));
      await wait(t, 800);
      check(t, 'жагсаалт руу буцсан ($level)');
      expect(find.textContaining('$level. '), findsOneWidget);
    }

    // Ялагдсан ч өмнөх ахиц (од, түвшин) алдагдаагүй
    final p = StorageService.instance.progress;
    expect(p.unlockedLevel, greaterThanOrEqualTo(3));
    // ignore: avoid_print
    print('LOSE-THROUGH: ${log.join(' | ')}');
  });
}
