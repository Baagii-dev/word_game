import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_battle/design/theme.dart';
import 'package:word_battle/screens/battle_screen.dart';
import 'package:word_battle/screens/chapter_select_screen.dart';
import 'package:word_battle/screens/home_screen.dart';
import 'package:word_battle/screens/path_screen.dart';
import 'package:word_battle/screens/story_screen.dart';
import 'package:word_battle/services/dictionary_service.dart';

import 'helpers.dart';

/// Тулаан, үлгэр, нүүр, үлгэрийн ном дэлгэц жижиг утсан дээр халихгүй эсэх.
void main() {
  const sizes = [Size(320, 568), Size(375, 667), Size(412, 915)];
  final chapters = loadRealChapters();

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

    for (final chapter in chapters) {
      testWidgets('Тулааны дэлгэц үлгэр ${chapter.id} ($label)', (t) async {
        await pumpAt(t, size, BattleScreen(chapter: chapter));
        expectNoVerticalOverflow(t, 'эхлэл');

        // Санамж дарахад мессеж өөрчлөгдөж, самбар халихгүй
        await t.tap(find.byIcon(Icons.lightbulb));
        await t.pump(const Duration(milliseconds: 300));
        expectNoVerticalOverflow(t, 'санамж');

        expect(find.text('Баатар'), findsWidgets);
        expect(find.text('Холих'), findsOneWidget);

        // Таймер, анимацийг цэвэрлэнэ
        await t.pumpWidget(const SizedBox());
      });
    }

    testWidgets('Үлгэрийн хуудас: дарж уншаад тулаанд орно ($label)', (
      t,
    ) async {
      var finished = false;
      final chapter = chapters.first;
      await pumpAt(
        t,
        size,
        StoryScreen(
          chapter: chapter,
          outro: false,
          onFinished: (_) => finished = true,
        ),
      );
      expectNoVerticalOverflow(t, 'үлгэр');
      expect(find.text(chapter.title), findsOneWidget);

      for (var i = 0; i < chapter.intro.length; i++) {
        await t.tap(find.byType(GestureDetector).first); // бүтэн текст
        await t.pump();
        await t.tap(find.byType(GestureDetector).first); // дараагийн хуудас
        await t.pump();
        expectNoVerticalOverflow(t, 'хуудас $i');
      }
      expect(finished, isTrue);
    });

    testWidgets('Үлгэрийн төгсгөл сургамжтай ($label)', (t) async {
      final chapter = chapters.last;
      await pumpAt(
        t,
        size,
        StoryScreen(chapter: chapter, outro: true, onFinished: (_) {}),
      );
      for (var i = 1; i < chapter.outro.length; i++) {
        await t.tap(find.text('Цааш'));
        await t.pump();
        await t.tap(find.text('Цааш'));
        await t.pump();
      }
      await t.pumpAndSettle();
      expect(find.textContaining(chapter.moral), findsOneWidget);
      expectNoVerticalOverflow(t, 'төгсгөл');
    });

    for (final chapter in chapters) {
      testWidgets('Үлгэрийн зам ${chapter.id} ($label)', (t) async {
        await pumpAt(
          t,
          size,
          PathScreen(chapter: chapter, onFinished: (_, _) {}),
        );
        expectNoVerticalOverflow(t, 'алхаж байна');
        expect(find.textContaining('Үлгэрийн зам'), findsOneWidget);

        // Баатар саадтай тулахад үсгийн самбар гарна
        for (
          var i = 0;
          i < 60 && find.text('Ашиглах').evaluate().isEmpty;
          i++
        ) {
          await t.pump(const Duration(milliseconds: 100));
        }
        for (var i = 0; i < 80; i++) {
          await t.pump(const Duration(milliseconds: 100));
          if (find.byKey(const Key('obstacle-name')).evaluate().isNotEmpty) {
            break;
          }
        }
        expect(find.byKey(const Key('obstacle-name')), findsOneWidget);
        expectNoVerticalOverflow(t, 'саадтай тулсан');

        await t.pumpWidget(const SizedBox());
      });
    }

    testWidgets('Нүүр дэлгэц ($label)', (t) async {
      await pumpAt(t, size, const HomeScreen());
      expectNoVerticalOverflow(t, 'нүүр');
    });

    testWidgets('Үлгэрийн ном дэлгэц ($label)', (t) async {
      await pumpAt(t, size, const ChapterSelectScreen());
      expectNoVerticalOverflow(t, 'үлгэрийн ном');
      expect(find.text(chapters.first.title), findsOneWidget);
    });
  }
}
