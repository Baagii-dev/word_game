import 'package:flutter/material.dart';

import 'theme.dart';

/// Тал нутаг, Ойн зах, Мангасын агуйн дэвсгэр (вектороор зурахгүй, цэвэр Flutter виджет).
/// Dark Mode болон түвшин бүрийн өнгийг автоматаар тохируулна.
class SteppeBackground extends StatelessWidget {
  const SteppeBackground({
    super.key,
    this.child,
    this.horizon = 0.62,
    this.showGer = true,
    this.showClouds = true,
    this.levelId = 1,
  });

  final Widget? child;
  final double horizon;
  final bool showGer;
  final bool showClouds;
  final int levelId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skyFlex = (horizon.clamp(0.2, 0.9) * 100).round();
    final groundFlex = 100 - skyFlex;

    final skyColors = switch (levelId) {
      2 => isDark
          ? const [Color(0xFF0B1924), Color(0xFF16323B), Color(0xFF234946)]
          : const [
              AppColors.forestSkyTop,
              Color(0xFF3E6B68),
              AppColors.forestSkyBottom,
            ],
      3 => const [
        AppColors.caveSkyTop,
        AppColors.caveSkyBottom,
        Color(0xFF7B2428),
      ],
      _ => isDark
          ? const [
              AppColors.nightSkyTop,
              AppColors.nightSkyMid,
              AppColors.nightSkyBottom,
            ]
          : const [AppColors.skyTop, AppColors.skyMid, AppColors.sky],
    };

    final groundColors = switch (levelId) {
      2 => const [
        Color(0xFF436F36),
        AppColors.forestGround,
        Color(0xFF1D3519),
      ],
      3 => const [
        Color(0xFF341C42),
        AppColors.caveRockNear,
        Color(0xFF100718),
      ],
      _ => isDark
          ? const [
              AppColors.nightGrassLight,
              AppColors.nightGrass,
              AppColors.nightGrassDark,
            ]
          : const [
              AppColors.grassLight,
              AppColors.grass,
              AppColors.grassDark,
            ],
    };

    final orbColor = levelId == 3
        ? AppColors.caveLava
        : (isDark ? AppColors.moon : AppColors.sun);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Тэнгэр ба газрын градиент
        Column(
          children: [
            Expanded(
              flex: skyFlex,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: skyColors,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Нар эсвэл Сар
                    Align(
                      alignment: const Alignment(0.65, -0.45),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: orbColor,
                          boxShadow: [
                            BoxShadow(
                              color: orbColor.withValues(alpha: 0.55),
                              blurRadius: 28,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Үүлс
                    if (showClouds && levelId != 3) ...[
                      Align(
                        alignment: const Alignment(-0.6, -0.55),
                        child: Icon(
                          Icons.cloud_rounded,
                          size: 54,
                          color: Colors.white.withValues(
                            alpha: isDark ? 0.22 : 0.78,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.05, -0.72),
                        child: Icon(
                          Icons.cloud_rounded,
                          size: 40,
                          color: Colors.white.withValues(
                            alpha: isDark ? 0.18 : 0.68,
                          ),
                        ),
                      ),
                    ],
                    // Тэнгэрийн хаяа дахь чимэглэл (Гэр / Ой / Агуй)
                    if (showGer)
                      Align(
                        alignment: const Alignment(-0.68, 1.0),
                        child: Text(
                          switch (levelId) {
                            2 => '🌲🌲',
                            3 => '🌋',
                            _ => '⛺',
                          },
                          style: const TextStyle(fontSize: 34, height: 1.0),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: groundFlex,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: groundColors,
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (child != null) child!,
      ],
    );
  }
}
