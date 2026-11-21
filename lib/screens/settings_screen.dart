import 'package:flutter/material.dart';

import '../design/glass.dart';
import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Тохиргоо')),
      body: Stack(
        children: [
          const Positioned.fill(child: SteppeBackground(horizon: 0.8)),
          const Positioned.fill(child: ScrimOverlay(top: 0.55, bottom: 0.4)),
          SafeArea(
            child: ListenableBuilder(
              listenable: settings,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  GlassPanel(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    opacity: 0.55,
                    child: Theme(
                      // Glass дээр текст үргэлж цагаан
                      data: Theme.of(context).copyWith(
                        listTileTheme: const ListTileThemeData(
                          textColor: Colors.white,
                          iconColor: Colors.white,
                        ),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Column(
                          children: [
                            _tile(
                              icon: Icons.volume_up_rounded,
                              title: 'Дуу',
                              value: settings.soundOn,
                              onChanged: settings.setSound,
                            ),
                            const Divider(indent: 64, color: AppColors.inkLine),
                            _tile(
                              icon: Icons.vibration_rounded,
                              title: 'Чичиргээ',
                              value: settings.hapticsOn,
                              onChanged: settings.setHaptics,
                            ),
                            const Divider(indent: 64, color: AppColors.inkLine),
                            _tile(
                              icon: settings.darkMode
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              title: 'Харанхуй горим',
                              value: settings.darkMode,
                              onChanged: settings.setDarkMode,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      value: value,
      onChanged: onChanged,
    );
  }
}
