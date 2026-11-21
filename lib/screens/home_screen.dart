import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../design/characters/enemy_art.dart';
import '../design/characters/hero_art.dart';
import '../design/glass.dart';
import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../models/enemy.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../widgets/game_button.dart';
import '../widgets/rules_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: SteppeBackground(horizon: 0.78)),
          const Positioned.fill(child: ScrimOverlay(top: 0.25, bottom: 0.65)),
          SafeArea(
            child: Column(
              children: [
                // Дээд мөр: Өдөр / Шөнийн горим солих товч
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ListenableBuilder(
                      listenable: settings,
                      builder: (context, _) => GlassIconButton(
                        tooltip: settings.darkMode
                            ? 'Өдрийн горим'
                            : 'Харанхуй горим',
                        icon: settings.darkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        onPressed: () =>
                            settings.setDarkMode(!settings.darkMode),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _Emblem(),
                            const SizedBox(height: 18),
                            const Text(
                              'Үгийн Тулаан',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.8,
                                height: 1.05,
                                shadows: [
                                  Shadow(
                                    color: Color(0x66000000),
                                    blurRadius: 18,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            GlassPanel(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              radius: 20,
                              opacity: 0.3,
                              child: const Text(
                                'Монгол үгээр мангасыг ял!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            GameButton(
                              label: 'Тоглох',
                              icon: Icons.play_arrow_rounded,
                              height: 62,
                              onPressed: () =>
                                  Navigator.pushNamed(context, Routes.levels),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _MenuTile(
                                    icon: Icons.history_rounded,
                                    label: 'Түүх',
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      Routes.history,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _MenuTile(
                                    icon: Icons.menu_book_rounded,
                                    label: 'Заавар',
                                    onTap: () => showRulesDialog(context),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _MenuTile(
                                    icon: Icons.tune_rounded,
                                    label: 'Тохиргоо',
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      Routes.settings,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Баатар ба Луу — гэрэлтсэн glass дугуйн дээр.
class _Emblem extends StatelessWidget {
  const _Emblem();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bronze, AppColors.primaryEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bronze.withValues(alpha: 0.55),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          const Positioned(left: 26, bottom: 4, child: HeroArt(size: 92)),
          const Positioned(
            right: 22,
            bottom: 6,
            child: EnemyArt(kind: EnemyKind.dragon, size: 86),
          ),
        ],
      ),
    );
  }
}

/// Нүүр хуудасны жижиг glass цэс (дүрс + нэр).
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      opacity: 0.38,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            AudioService.instance.play(Sfx.tap);
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
