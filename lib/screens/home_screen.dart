import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/routes.dart';
import '../widgets/game_button.dart';
import '../widgets/ornament_strip.dart';
import '../widgets/steppe_background.dart';

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
          '• "Холих" — бүх үсэг солигдоно, гэхдээ ээлж алдана.\n'
          '• 💡 Санамж: тулаан бүрт 3 удаа, ээлж алдахгүй.\n'
          '• Зарим дайсан N ээлж тутамд 2× хүчтэй цохино — дэлгэц дээр анхааруулна.\n'
          '• Дараалан зөв үг бүтээвэл combo: үг бүрт +10% (дээд тал нь +50%). Буруу үг, холих, хугацаа дуусвал combo тасрана.',
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
      body: Stack(
        children: [
          const Positioned.fill(child: SteppeBackground(horizon: 0.87)),
          Positioned(
            top: MediaQuery.paddingOf(context).top,
            left: 0,
            right: 0,
            child: const OrnamentStrip(),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚔️📜', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 8),
                    Text(
                      'Үгийн Тулаан',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                        shadows: const [
                          Shadow(
                            color: AppColors.woodDark,
                            offset: Offset(0, 3),
                          ),
                          Shadow(color: AppColors.woodDark, blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Монгол үгээр мангасыг ял!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: AppColors.woodDark, blurRadius: 6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    GameButton(
                      label: 'Тоглох',
                      icon: Icons.play_arrow,
                      color: AppColors.red,
                      onPressed: () =>
                          Navigator.pushNamed(context, Routes.levels),
                    ),
                    const SizedBox(height: 14),
                    GameButton(
                      label: 'Заавар',
                      icon: Icons.help_outline,
                      color: AppColors.accent,
                      foreground: AppColors.text,
                      onPressed: () => _showRules(context),
                    ),
                    const SizedBox(height: 14),
                    GameButton(
                      label: 'Тохиргоо',
                      icon: Icons.settings,
                      color: AppColors.wood,
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
