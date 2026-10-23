import 'package:flutter/material.dart';

/// Аппын өнгөнүүд — "Тал нутаг" загвар: хөх тэнгэр, ногоон тал,
/// алтлаг хээ, улаан тодотгол.
class AppColors {
  // Тэнгэр / тал
  static const Color skyTop = Color(0xFF2E7BC4);
  static const Color sky = Color(0xFF9ED8F5);
  static const Color grass = Color(0xFF6E9B3A);
  static const Color grassDark = Color(0xFF4F7A2B);

  // Хөх самбар (өмнөх "wood" нэрээр хэрэглэгдэж байсан)
  static const Color wood = Color(0xFF1F5FA8);
  static const Color woodDark = Color(0xFF14335F);

  // Үсгийн хавтан
  static const Color tile = Color(0xFFFFF1D0);
  static const Color tileBorder = Color(0xFFC9962B);

  static const Color cream = Color(0xFFFFF8E7);
  static const Color text = Color(0xFF2B1D14);
  static const Color red = Color(0xFFC8312B);
  static const Color accent = Color(0xFFE8B33A); // алт

  static const Color playerHp = Color(0xFF43A047);
  static const Color enemyHp = Color(0xFFE53935);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.wood,
      primary: AppColors.wood,
      secondary: AppColors.accent,
    ),
    scaffoldBackgroundColor: AppColors.sky,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.woodDark,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cream,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.tileBorder, width: 1.5),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.tileBorder, width: 2),
      ),
    ),
  );
}
