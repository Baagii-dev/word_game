import 'package:flutter/material.dart';

import '../screens/chapter_select_screen.dart';
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';

/// Нэрлэсэн маршрутууд. Үлгэр, тулаан, үр дүнгийн дэлгэц аргументтай тул
/// TaleFlow-оор нээгдэнэ.
class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String chapters = '/chapters';
  static const String history = '/history';
  static const String settings = '/settings';

  static Route<dynamic> onGenerate(RouteSettings s) {
    final Widget page = switch (s.name) {
      home => const HomeScreen(),
      chapters => const ChapterSelectScreen(),
      history => const HistoryScreen(),
      settings => const SettingsScreen(),
      _ => const SplashScreen(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: s);
  }
}
