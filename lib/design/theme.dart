import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════════════════════
///  ДИЗАЙНЫ ТОХИРГОО — өнгө, хэмжээ, хугацаа нэг дор.
///  Дизайн өөрчлөхдөө эхлээд энэ файлыг засна.
/// ══════════════════════════════════════════════════════════════
class AppColors {
  // ---- Тэнгэр / тал (Өдөр) ----
  static const Color skyTop = Color(0xFF1E5FA8);
  static const Color skyMid = Color(0xFF56A8E8);
  static const Color sky = Color(0xFFB5E3FA);
  static const Color mountainFar = Color(0xFF6B8FB8);
  static const Color mountainMid = Color(0xFF4F759B);
  static const Color mountainSnow = Color(0xFFF4F9FC);
  static const Color grass = Color(0xFF72A83A);
  static const Color grassLight = Color(0xFF97C956);
  static const Color grassDark = Color(0xFF3E681E);
  static const Color hillFar = Color(0xFF88B653); // алс толгод
  static const Color sun = Color(0xFFFFE07D);

  // ---- Шөнийн тал нутаг (Dark Mode) ----
  static const Color nightSkyTop = Color(0xFF071124);
  static const Color nightSkyMid = Color(0xFF122647);
  static const Color nightSkyBottom = Color(0xFF1E3B63);
  static const Color nightMountainFar = Color(0xFF1C3352);
  static const Color nightMountainMid = Color(0xFF14263E);
  static const Color nightGrassLight = Color(0xFF284F3A);
  static const Color nightGrass = Color(0xFF1D3B2B);
  static const Color nightGrassDark = Color(0xFF11241A);
  static const Color nightSurface = Color(0xFF152642);
  static const Color moon = Color(0xFFFFF3C4);

  // ---- Ойн зах (Түвшин 2) ----
  static const Color forestSkyTop = Color(0xFF1B3B48);
  static const Color forestSkyBottom = Color(0xFFD98A5C);
  static const Color forestTreeFar = Color(0xFF2D5A4C);
  static const Color forestTreeNear = Color(0xFF1B3F33);
  static const Color forestGround = Color(0xFF32562A);

  // ---- Мангасын агуй (Түвшин 3) ----
  static const Color caveSkyTop = Color(0xFF160B24);
  static const Color caveSkyBottom = Color(0xFF4A182F);
  static const Color caveRockFar = Color(0xFF2B1738);
  static const Color caveRockNear = Color(0xFF1A0E24);
  static const Color caveLava = Color(0xFFFF5722);

  // ---- Хөх самбар (товч, дээд/доод хэсэг) ----
  static const Color navy = Color(0xFF1F5FA8);
  static const Color navyDark = Color(0xFF14335F);
  static const Color navyDeep = Color(0xFF0B2347); // үг бүтээх мөрийн дотор

  // ---- Үсгийн хавтан ----
  static const Color tile = Color(0xFFFFF1D0);
  static const Color tileBottom = Color(0xFFE6C88C);
  static const Color tileBorder = Color(0xFFC9962B);
  static const Color tileShadow = Color(0xFF8C6214);

  // ---- Текст, тодотгол ----
  static const Color cream = Color(0xFFFFF8E7);
  static const Color text = Color(0xFF2B1D14);
  static const Color red = Color(0xFFC8312B);
  static const Color accent = Color(0xFFE8B33A); // алт
  static const Color accentLight = Color(0xFFFFDF85);
  static const Color warning = Color(0xFFFFEB3B); // яарах (цаг бага)
  static const Color danger = Color(
    0xFFFF8A80,
  ); // дайсны хүчтэй цохилтын анхааруулга

  // ---- Амь (HP) ----
  static const Color playerHp = Color(0xFF43A047);
  static const Color enemyHp = Color(0xFFE53935);

  // ---- Баатар (зурагдсан дүр) ----
  static const Color heroDeel = Color(0xFF235FA4); // дээл
  static const Color heroDeelDark = Color(0xFF163F73);
  static const Color heroSash = Color(0xFFC8312B); // бүс
  static const Color heroSkin = Color(0xFFF2C9A0);
  static const Color heroHat = Color(0xFFB3261E);
  static const Color heroBoots = Color(0xFF3B2A20);
  static const Color heroBlade = Color(0xFFE6EEF8);
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
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.light,
      primary: AppColors.navy,
      secondary: AppColors.accent,
    ),
    scaffoldBackgroundColor: AppColors.sky,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navyDark,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.4,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cream,
      elevation: 4,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.tileBorder, width: 2),
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

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.dark,
      primary: AppColors.accent,
      secondary: AppColors.accentLight,
      surface: AppColors.nightSurface,
    ),
    scaffoldBackgroundColor: AppColors.nightSkyTop,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navyDeep,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.4,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.nightSurface,
      elevation: 6,
      shadowColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.accent, width: 1.8),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.nightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.accent, width: 2),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.accent : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.accent.withValues(alpha: 0.4)
            : null,
      ),
    ),
  );
}
