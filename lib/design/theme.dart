import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════════════════════
///  ДИЗАЙНЫ ТОХИРГОО — өнгө, хэмжээ, хугацаа нэг дор.
///  Дизайн өөрчлөхдөө эхлээд энэ файлыг засна.
/// ══════════════════════════════════════════════════════════════
class AppColors {
  // ---- Тэнгэр / тал ----
  static const Color skyTop = Color(0xFF2E7BC4);
  static const Color sky = Color(0xFF9ED8F5);
  static const Color grass = Color(0xFF6E9B3A);
  static const Color grassDark = Color(0xFF4F7A2B);
  static const Color hillFar = Color(0xFF8DB85A); // алс толгод
  static const Color sun = Color(0xFFFFD66B);

  // ---- Хөх самбар (товч, дээд/доод хэсэг) ----
  static const Color navy = Color(0xFF1F5FA8);
  static const Color navyDark = Color(0xFF14335F);
  static const Color navyDeep = Color(0xFF0B2347); // үг бүтээх мөрийн дотор

  // ---- Үсгийн хавтан ----
  static const Color tile = Color(0xFFFFF1D0);
  static const Color tileBorder = Color(0xFFC9962B);

  // ---- Текст, тодотгол ----
  static const Color cream = Color(0xFFFFF8E7);
  static const Color text = Color(0xFF2B1D14);
  static const Color red = Color(0xFFC8312B);
  static const Color accent = Color(0xFFE8B33A); // алт
  static const Color warning = Color(0xFFFFEB3B); // яарах (цаг бага)
  static const Color danger = Color(
    0xFFFF8A80,
  ); // дайсны хүчтэй цохилтын анхааруулга

  // ---- Амь (HP) ----
  static const Color playerHp = Color(0xFF43A047);
  static const Color enemyHp = Color(0xFFE53935);

  // ---- Баатар (зурагдсан дүр) ----
  static const Color heroDeel = Color(0xFF2A6FC0); // дээл
  static const Color heroSash = Color(0xFFC8312B); // бүс
  static const Color heroSkin = Color(0xFFF2C9A0);
  static const Color heroHat = Color(0xFFB3261E);
  static const Color heroBoots = Color(0xFF3B2A20);
  static const Color heroBlade = Color(0xFFDDE6F0);
  static const Color heroBrim = Color(0xFF2B1D14); // малгайн хар хүрээ
}

/// Дахин давтагдах хэмжээ, радиус.
class AppSizes {
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double screenPadding = 16;
  static const double minTouch = 44; // хуруугаар дарах хамгийн бага хэмжээ
}

/// Анимацийн хугацаа.
class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
      secondary: AppColors.accent,
    ),
    scaffoldBackgroundColor: AppColors.sky,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navyDark,
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
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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
