import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../design/characters/enemy_art.dart';
import '../design/characters/hero_art.dart';
import '../design/ornament_strip.dart';
import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../services/settings_service.dart';
import '../widgets/game_button.dart';
import '../widgets/rules_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showRules(BuildContext context) => showRulesDialog(context);

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: SteppeBackground(horizon: 0.78)),
          Positioned(
            top: MediaQuery.paddingOf(context).top,
            left: 0,
            right: 0,
            child: const OrnamentStrip(),
          ),
          // Баруун дээд буланд Өдөр / Шөнийн горим (Dark Mode) хурдан солих товч
          Positioned(
            top: MediaQuery.paddingOf(context).top + 28,
            right: 16,
            child: ListenableBuilder(
              listenable: settings,
              builder: (context, _) => Material(
                color: AppColors.navyDeep.withValues(alpha: 0.65),
                shape: CircleBorder(
                  side: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  tooltip: settings.darkMode
                      ? 'Өдрийн горим'
                      : 'Харанхуй горим',
                  onPressed: () => settings.setDarkMode(!settings.darkMode),
                  icon: Icon(
                    settings.darkMode ? Icons.light_mode : Icons.dark_mode,
                    color: AppColors.accentLight,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Баатар ба Луугийн сүлдэт чимэглэл
                    SizedBox(
                      height: 92,
                      width: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [
                                  AppColors.accentLight,
                                  AppColors.accent,
                                  AppColors.tileShadow,
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.navyDeep,
                                width: 2.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const Positioned(
                            left: 18,
                            bottom: 2,
                            child: HeroArt(size: 78),
                          ),
                          const Positioned(
                            right: 14,
                            bottom: 4,
                            child: EnemyArt(emoji: '🐉', size: 74),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Үгийн Тулаан',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentLight,
                        letterSpacing: 0.6,
                        shadows: [
                          Shadow(
                            color: AppColors.navyDeep,
                            offset: Offset(0, 3),
                          ),
                          Shadow(color: AppColors.navyDeep, blurRadius: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navyDeep.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.65),
                        ),
                      ),
                      child: const Text(
                        'Монгол үгээр мангасыг ял!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    GameButton(
                      label: 'Тоглох',
                      icon: Icons.play_arrow,
                      color: AppColors.red,
                      onPressed: () =>
                          Navigator.pushNamed(context, Routes.levels),
                    ),
                    const SizedBox(height: 10),
                    GameButton(
                      label: 'Түүх',
                      icon: Icons.history,
                      color: AppColors.navy,
                      onPressed: () =>
                          Navigator.pushNamed(context, Routes.history),
                    ),
                    const SizedBox(height: 10),
                    GameButton(
                      label: 'Заавар',
                      icon: Icons.help_outline,
                      color: AppColors.accent,
                      foreground: AppColors.text,
                      onPressed: () => _showRules(context),
                    ),
                    const SizedBox(height: 10),
                    GameButton(
                      label: 'Тохиргоо',
                      icon: Icons.settings,
                      color: AppColors.navyDark,
                      onPressed: () =>
                          Navigator.pushNamed(context, Routes.settings),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: OrnamentStrip(),
          ),
        ],
      ),
    );
  }
}
