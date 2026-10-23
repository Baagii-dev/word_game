import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/routes.dart';
import '../widgets/game_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showRules(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Хэрхэн тоглох вэ?'),
        content: const Text(
          '• Үсэг дээр дарж монгол үг бүтээнэ.\n'
          '• "Довтлох" дарахад үг зөв бол дайсанд хохирол учруулна.\n'
          '• Урт үг, ховор үсэг (ф, ю, п...) их хохирол өгнө.\n'
          '• Зөвхөн толь бичгийн үндсэн хэлбэр (ном, морь) зөвшөөрөгдөнө.\n'
          '• Ээлж бүр 30 секунд. Хугацаа дуусвал дайсан довтолно.\n'
          '• "Холих" — бүх үсэг солигдоно, гэхдээ ээлж алдана.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ойлголоо'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚔️📜', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 12),
                const Text(
                  'Үгийн Тулаан',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.woodDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Монгол үгээр мангасыг ял!',
                  style: TextStyle(fontSize: 16, color: AppColors.text),
                ),
                const SizedBox(height: 40),
                GameButton(
                  label: 'Тоглох',
                  icon: Icons.play_arrow,
                  onPressed: () => Navigator.pushNamed(context, Routes.levels),
                ),
                const SizedBox(height: 14),
                GameButton(
                  label: 'Заавар',
                  icon: Icons.help_outline,
                  color: AppColors.tileBorder,
                  onPressed: () => _showRules(context),
                ),
                const SizedBox(height: 14),
                GameButton(
                  label: 'Тохиргоо',
                  icon: Icons.settings,
                  color: AppColors.woodDark,
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.settings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
