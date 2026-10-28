import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_battle/design/theme.dart';
import 'package:word_battle/models/level.dart';
import 'package:word_battle/screens/battle_screen.dart';
import 'package:word_battle/screens/home_screen.dart';
import 'package:word_battle/screens/level_select_screen.dart';
import 'package:word_battle/services/dictionary_service.dart';

/// Тулаан, нүүр, түвшин сонгох дэлгэц жижиг утсан дээр халахгүй эсэх.
void main() {
  const sizes = [Size(320, 568), Size(375, 667), Size(412, 915)];

  setUpAll(() {
    DictionaryService.instance.loadFromList(
      File('assets/data/words.txt').readAsLinesSync(),
    );
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpAt(WidgetTester t, Size size, Widget home) async {
    t.view.physicalSize = size * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: home));
    await t.pump(const Duration(milliseconds: 200));
  }

  // Тест дэх Ahem фонт жинхэнэ фонтоос өргөн тул зөвхөн босоо (bottom)
  // халилтыг алдаа гэж үзнэ — энэ нь бодит layout-ын асуудал.
  void expectNoVerticalOverflow(WidgetTester t, String where) {
    final e = t.takeException();
    if (e == null) return;
    expect(e.toString(), isNot(contains('on the bottom')), reason: where);
  }

  for (final size in sizes) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';

    for (final level in kLevels) {
      testWidgets('Тулааны дэлгэц түвшин ${level.id} ($label)', (t) async {
        await pumpAt(t, size, BattleScreen(level: level));
        expectNoVerticalOverflow(t, 'эхлэл');

        // Санамж дарахад мессеж өөрчлөгдөж, самбар халихгүй
        await t.tap(find.byIcon(Icons.lightbulb));
        await t.pump(const Duration(milliseconds: 300));
        expectNoVerticalOverflow(t, 'санамж');

        // Дүр, самбар, товчнууд харагдаж байна
        expect(find.text('Баатар'), findsOneWidget);
        expect(find.text('Холих'), findsOneWidget);

        // Таймер, анимацийг цэвэрлэнэ
        await t.pumpWidget(const SizedBox());
      });
    }

    testWidgets('Нүүр дэлгэц ($label)', (t) async {
      await pumpAt(t, size, const HomeScreen());
      expectNoVerticalOverflow(t, 'нүүр');
    });

    testWidgets('Түвшин сонгох дэлгэц ($label)', (t) async {
      await pumpAt(t, size, const LevelSelectScreen());
      expectNoVerticalOverflow(t, 'түвшин');
    });
  }
}
