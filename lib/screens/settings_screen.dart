import 'package:flutter/material.dart';

import '../widgets/ornament_strip.dart';
import '../widgets/steppe_background.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тохиргоо'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(18),
          child: OrnamentStrip(height: 18),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SteppeBackground(horizon: 0.8)),
          ListenableBuilder(
            listenable: settings,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.volume_up),
                        title: const Text('Дуу'),
                        value: settings.soundOn,
                        onChanged: settings.setSound,
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.vibration),
                        title: const Text('Чичиргээ'),
                        value: settings.hapticsOn,
                        onChanged: settings.setHaptics,
                      ),
                    ],
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
