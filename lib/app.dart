import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'core/routes.dart';

class WordBattleApp extends StatelessWidget {
  const WordBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Үгийн Тулаан',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Routes.splash,
      onGenerateRoute: Routes.onGenerate,
    );
  }
}
