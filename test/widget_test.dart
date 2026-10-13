import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_battle/screens/home_screen.dart';

void main() {
  testWidgets('Нүүр дэлгэц гарчиг, товчнуудыг харуулна', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Үгийн Тулаан'), findsOneWidget);
    expect(find.text('Тоглох'), findsOneWidget);
    expect(find.text('Заавар'), findsOneWidget);
  });

  testWidgets('Заавар товч дарахад дүрэм гарна', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.text('Заавар'));
    await tester.pumpAndSettle();

    expect(find.text('Хэрхэн тоглох вэ?'), findsOneWidget);
  });
}
