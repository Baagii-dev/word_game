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

  // ---- Орчин үеийн UI — дулаан хүрэн (савхи, кофе, карамель) ----
  static const Color ink = Color(0xFF1C140F); // хамгийн бараан (эспрессо)
  static const Color inkSoft = Color(0xFF2B2018); // самбарын гадаргуу
  static const Color inkLine = Color(0x24FFE9D2); // нарийн хүрээ
  static const Color glass = Color(0x2EFFE9D2); // тунгалаг гадаргуу
  static const Color glassStrong = Color(0x47FFE9D2);
  static const Color primary = Color(0xFFE09A4F); // үндсэн товч (карамель)
  static const Color primaryEnd = Color(0xFFB4532A); // зэвэрсэн улбар
  static const Color bronze = Color(0xFF9A6B45); // хүрэл хүрэн
  static const Color bronzeDeep = Color(0xFF5E3B22);
  static const Color mint = Color(0xFF8BC34A); // амь (өвсний ногоон)
  static const Color textMuted = Color(0xFFC2AC93);
  static const Color lightSurface = Color(0xFFF6EFE6);

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
  static const double radiusLg = 20;
  static const double radiusXl = 28;
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
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final surface = isDark ? AppColors.inkSoft : const Color(0xFFFFFAF3);
    final onSurface = isDark ? Colors.white : AppColors.ink;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.bronze,
      brightness: b,
      primary: isDark ? AppColors.accent : AppColors.bronze,
      onPrimary: isDark ? AppColors.ink : Colors.white,
      secondary: AppColors.primary,
      surface: surface,
      onSurface: onSurface,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    const buttonText = TextStyle(fontWeight: FontWeight.w700, fontSize: 15);

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.ink : AppColors.lightSurface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface.withValues(alpha: isDark ? 0.86 : 0.92),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          side: BorderSide(
            color: isDark ? AppColors.inkLine : const Color(0x14000000),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
      ),
      listTileTheme: ListTileThemeData(shape: shape),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: buttonPadding,
          textStyle: buttonText,
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: buttonPadding,
          textStyle: buttonText,
          shape: shape,
          side: BorderSide(color: onSurface.withValues(alpha: 0.18)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: buttonText, shape: shape),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.mint : null,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerTheme: DividerThemeData(
        color: onSurface.withValues(alpha: 0.08),
        space: 1,
      ),
    );
  }
}
