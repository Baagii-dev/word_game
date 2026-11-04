import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_battle/core/routes.dart';
import 'package:word_battle/design/theme.dart';
import 'package:word_battle/models/level.dart';
import 'package:word_battle/screens/result_screen.dart';
import 'package:word_battle/screens/settings_screen.dart';
import 'package:word_battle/services/settings_service.dart';
import 'package:word_battle/widgets/rules_dialog.dart';

/// Жижиг дэлгэц дээр overflow (хэт халих) алдаа гарахгүй эсэхийг шалгана.
void main() {
  const sizes = [Size(320, 568), Size(375, 667), Size(412, 915)];

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpAt(
    WidgetTester t,
    Size size,
    Widget home, {
    ThemeData? theme,
  }) async {
    t.view.physicalSize = size * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(theme: theme ?? AppTheme.light, home: home),
    );
    await t.pump(const Duration(milliseconds: 100));
  }

  for (final size in sizes) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('Ялалтын дэлгэц халихгүй ($label)', (t) async {
      await pumpAt(
        t,
        size,
        ResultScreen(
          level: kLevels.first,
          won: true,
          score: 120,
          stars: 3,
          wordsCount: 5,
          longestWord: 'цагаан',
        ),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('Ялагдлын дэлгэц халихгүй ($label)', (t) async {
      await pumpAt(
        t,
        size,
        ResultScreen(
          level: kLevels.last,
          won: false,
          score: 10,
          stars: 0,
          wordsCount: 0,
          longestWord: '',
        ),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('Тохиргооны дэлгэц ба Dark Mode ($label)', (t) async {
      await pumpAt(t, size, const SettingsScreen(), theme: AppTheme.dark);
      expect(find.text('Харанхуй горим'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('Зааврын цонх халихгүй ($label)', (t) async {
      await pumpAt(
        t,
        size,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showRulesDialog(context),
            child: const Text('open'),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('Хэрхэн тоглох вэ?'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }

  test('Dark Mode тохиргоо хадгалагдана', () async {
    SharedPreferences.setMockInitialValues({});
    final s = SettingsService.instance;
    await s.load();
    expect(s.darkMode, isFalse);
    await s.setDarkMode(true);
    expect(s.darkMode, isTrue);
    await s.setDarkMode(false);
  });

  test('Нэрлэсэн маршрутууд бүгд тодорхойлогдсон', () {
    for (final name in [
      Routes.splash,
      Routes.home,
      Routes.levels,
      Routes.settings,
    ]) {
      expect(Routes.onGenerate(RouteSettings(name: name)), isA<Route>());
    }
  });
}
