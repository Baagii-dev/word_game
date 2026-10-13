import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'screens/home_screen.dart';

class WordBattleApp extends StatelessWidget {
  const WordBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Үгийн Тулаан',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
