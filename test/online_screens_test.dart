import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_battle/design/theme.dart';
import 'package:word_battle/online/local_online_service.dart';
import 'package:word_battle/online/online_models.dart';
import 'package:word_battle/online/online_service.dart';
import 'package:word_battle/screens/duel_lobby_screen.dart';
import 'package:word_battle/screens/duel_screen.dart';
import 'package:word_battle/screens/home_screen.dart';
import 'package:word_battle/screens/leaderboard_screen.dart';
import 'package:word_battle/services/dictionary_service.dart';

/// Онлайн дэлгэцүүд (жагсаалт, хайлт, 1v1) жижиг утсан дээр халахгүй, ажиллана.
void main() {
  const sizes = [Size(320, 568), Size(375, 667), Size(412, 915)];

  setUpAll(() {
    DictionaryService.instance.loadFromList(
      File('assets/data/words.txt').readAsLinesSync(),
    );
  });

  late LocalOnlineService service;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = LocalOnlineService(
      searchDelay: const Duration(seconds: 1),
      botMinHit: const Duration(hours: 1),
      duelDuration: const Duration(seconds: 20),
    );
    OnlineServices.use(service);
  });

  Future<void> pumpAt(WidgetTester t, Size size, Widget home) async {
    t.view.physicalSize = size * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: home));
    await t.pump(const Duration(milliseconds: 200));
  }

  void noVerticalOverflow(WidgetTester t, String where) {
    final e = t.takeException();
    if (e == null) return;
    expect(e.toString(), isNot(contains('on the bottom')), reason: where);
  }

  Future<DuelSession> startSession(WidgetTester t) async {
    await service.signIn('Тест');
    final search = service.findDuel();
    DuelSession? session;
    search.result.then((v) => session = v);
    await t.pump(const Duration(seconds: 2));
    return session!;
  }

  for (final size in sizes) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('Жагсаалт: нэвтрээгүй үед ник авах карт ($label)', (t) async {
      await pumpAt(t, size, const LeaderboardScreen());
      await t.pump(const Duration(milliseconds: 100));
      expect(find.text('Жагсаалтад орох'), findsOneWidget);
      expect(find.text('Хангай'), findsOneWidget); // жишиг тоглогч
      noVerticalOverflow(t, 'жагсаалт');
    });

    testWidgets('Жагсаалт: нэвтэрсэн үед байр харагдана ($label)', (t) async {
      await service.signIn('Баатар');
      await service.submitResult(score: 9000, won: true);
      await pumpAt(t, size, const LeaderboardScreen());
      await t.pump(const Duration(milliseconds: 100));
      expect(find.text('Таны байр: 1'), findsOneWidget);
      expect(find.text('Баатар (та)'), findsOneWidget);
      noVerticalOverflow(t, 'жагсаалт (нэвтэрсэн)');
    });

    testWidgets('1v1 дэлгэц: тоглож, холиж, дуусгана ($label)', (t) async {
      final session = await startSession(t);
      await pumpAt(t, size, DuelScreen(session: session));
      noVerticalOverflow(t, 'эхлэл');
      expect(find.text('Холих'), findsOneWidget);
      expect(find.text('Та'), findsWidgets);

      await t.tap(find.text('Холих'));
      await t.pump(const Duration(milliseconds: 300));
      noVerticalOverflow(t, 'холих');

      // Хугацаа дуусч, HP тэнцсэн → тэнцлээ цонх гарна
      await t.pump(const Duration(seconds: 21));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('Тэнцлээ'), findsOneWidget);
      noVerticalOverflow(t, 'дүн');

      await t.tap(find.text('Гарах'));
      await t.pumpAndSettle();
    });
  }

  testWidgets('Хайлтын дэлгэц: ник асууж, өрсөлдөгч олдоод 1v1 рүү орно', (
    t,
  ) async {
    await pumpAt(t, const Size(375, 667), const DuelLobbyScreen());
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Ник нэрээ оруулна уу'), findsOneWidget);

    await t.enterText(find.byType(TextField), 'Тэмүүжин');
    await t.pump();
    await t.tap(find.text('Үргэлжлүүлэх'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Өрсөлдөгч хайж байна…'), findsOneWidget);
    expect(service.profile?.name, 'Тэмүүжин');

    await t.pump(const Duration(seconds: 2)); // өрсөлдөгч олдоно
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byType(DuelScreen), findsOneWidget);
    noVerticalOverflow(t, 'lobby → duel');

    await t.pumpWidget(const SizedBox()); // цэвэрлэнэ
  });

  testWidgets('Хайлтыг цуцлахад өмнөх дэлгэц рүү буцна', (t) async {
    await service.signIn('Тест');
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DuelLobbyScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 100));
    expect(find.byType(DuelLobbyScreen), findsOneWidget);
    expect(find.text('Өрсөлдөгч хайж байна…'), findsOneWidget);
    await t.tap(find.text('Цуцлах'));
    await t.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
    await t.pump(
      const Duration(seconds: 3),
    ); // хайлт цуцлагдсан тул дэлгэц солигдохгүй
    expect(find.byType(DuelScreen), findsNothing);
  });

  testWidgets('Нүүр дэлгэцэд шинэ товчнууд байна', (t) async {
    await pumpAt(t, const Size(375, 667), const HomeScreen());
    expect(find.text('Онлайн 1v1'), findsOneWidget);
    expect(find.text('Жагсаалт'), findsOneWidget);
    expect(find.text('Түүх'), findsOneWidget);
    noVerticalOverflow(t, 'нүүр');
  });

  testWidgets('1v1 дууссаны дараа "Гарах" дарахад өмнөх дэлгэц рүү буцна', (
    t,
  ) async {
    final session = await startSession(t);
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DuelScreen(session: session)),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pump(const Duration(milliseconds: 500));
    await t.pump(const Duration(milliseconds: 100));
    expect(find.byType(DuelScreen), findsOneWidget);

    // Хугацаа дуусгаж тулааныг төгсгөнө
    await t.pump(const Duration(seconds: 21));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Гарах'), findsOneWidget);
    await t.tap(find.text('Гарах'));
    await t.pump(const Duration(milliseconds: 100));
    await t.pump(const Duration(seconds: 1));

    expect(find.byType(DuelScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets(
    'Тулаанаас өөрөө гарвал ("Тийм") ялагдлын цонхны "Гарах" буцаана',
    (t) async {
      final session = await startSession(t);
      await t.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DuelScreen(session: session),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pump(const Duration(milliseconds: 600));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byType(DuelScreen), findsOneWidget);

      await t.tap(find.byIcon(Icons.flag_circle));
      await t.pump(const Duration(milliseconds: 400));
      await t.tap(find.text('Тийм'));
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('Ялагдал'), findsOneWidget);

      await t.tap(find.text('Гарах'));
      await t.pump(const Duration(milliseconds: 100));
      await t.pump(const Duration(seconds: 1));
      expect(find.byType(DuelScreen), findsNothing);
      expect(find.text('open'), findsOneWidget);
    },
  );
}
