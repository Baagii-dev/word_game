import 'package:flutter/material.dart';

import 'core/constants.dart';
import 'core/routes.dart';
import 'design/theme.dart';
import 'services/settings_service.dart';

class TaleHeroApp extends StatelessWidget {
  const TaleHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: kAppTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: Routes.splash,
        onGenerateRoute: Routes.onGenerate,
      ),
    );
  }
}
