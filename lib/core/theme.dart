import 'package:flutter/material.dart';

/// Аппын өнгөнүүд. Figma загвар гарсны дараа энд өнгөө солино.
class AppColors {
  static const Color sky = Color(0xFF8FD3F4);
  static const Color grass = Color(0xFF7CB342);
  static const Color wood = Color(0xFF6D4C41);
  static const Color woodDark = Color(0xFF4E342E);
  static const Color tile = Color(0xFFF3DDB3);
  static const Color tileBorder = Color(0xFFB08850);
  static const Color text = Color(0xFF3E2723);
  static const Color playerHp = Color(0xFF43A047);
  static const Color enemyHp = Color(0xFFE53935);
  static const Color accent = Color(0xFFFFB300);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.wood),
        scaffoldBackgroundColor: AppColors.sky,
      );
}
