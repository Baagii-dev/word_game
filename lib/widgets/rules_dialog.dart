import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import 'game_button.dart';
import 'letter_tile_widget.dart';
import '../models/letter_tile.dart';
import 'ornament_strip.dart';

/// "Хэрхэн тоглох вэ?" — хэсэг хэсгээр, жишээтэй заавар.
Future<void> showRulesDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _RulesDialog(),
  );
}

class _RulesDialog extends StatelessWidget {
  const _RulesDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.woodDark,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: const Text(
                'Хэрхэн тоглох вэ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const OrnamentStrip(height: 16, background: AppColors.wood),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                shrinkWrap: true,
                children: const [
                  _Section(
                    icon: '🎯',
                    title: 'Зорилго',
                    lines: [
                      'Монгол үг бүтээж дайсны амийг (HP) тэглэ.',
                      'Түвшний бүх дайсныг ялбал түвшин давна.',
                    ],
                  ),
                  _Section(
                    icon: '✍️',
                    title: 'Үг бүтээх',
                    lines: [
                      '1. Доорх самбараас үсэг дарж сонгоно — сонгосон үсэг дээд мөрөнд гарна.',
                      '2. Буруу дарсан үсгээ дахин дарвал буцна, ⌫ товч бүгдийг арилгана.',
                      '3. Үгээ бүтээчихээд "Довтлох" дарна.',
                      '4. Үг зөв бол дайсанд хохирол учирч, ашигласан үсэг шинэчлэгдэнэ.',
                    ],
                  ),
                  _DamageExample(),
                  _Section(
                    icon: '🔥',
                    title: 'Combo',
                    lines: [
                      'Дараалан зөв үг бүтээх бүрт хохирол +10% нэмэгдэнэ (дээд тал нь +50%).',
                      'Буруу үг, "Холих", хугацаа дуусах — combo тасарна.',
                    ],
                  ),
                  _Section(
                    icon: '⏱',
                    title: 'Ээлж ба дайсан',
                    lines: [
                      'Ээлж бүр ${GameConfig.turnSeconds} секунд. Хугацаа дуусвал үг бүтээгээгүй ч дайсан довтолно.',
                      'Таны довтолгооны дараа дайсан амьд байвал тэр довтолж, таны HP-ийг хасна.',
                      '⚡ Зарим дайсан хэдэн ээлж тутамд 2× хүчтэй цохино. Дэлгэц дээр хэдэн ээлжийн дараа болохыг харуулна.',
                    ],
                  ),
                  _Section(
                    icon: '💡',
                    title: 'Тусламж',
                    lines: [
                      'Санамж: тулаан бүрт ${GameConfig.hintsPerBattle} удаа. Бүтэх нэг үгийн эхний үсэг, уртыг харуулна. Ээлж алдахгүй.',
                      'Холих: бүх үсэг солигдоно, гэхдээ ээлж алдана.',
                    ],
                  ),
                  _Section(
                    icon: '⭐',
                    title: 'Од',
                    lines: [
                      'Түвшин давахад үлдсэн HP-ээр од авна: 70%-аас дээш — 3 од, 30%-аас дээш — 2 од, бусад — 1 од.',
                    ],
                  ),
                  _Section(
                    icon: '📖',
                    title: 'Анхаарах',
                    lines: [
                      'Үг хамгийн багадаа ${GameConfig.minWordLength} үсэгтэй байна.',
                      'Толь бичгийн үндсэн хэлбэр л зөвшөөрөгдөнө (жишээ: "морь" — зөв, "моринд" — буруу).',
                      'Нэг дайсантай тулалдахдаа ижил үгийг давтаж болохгүй.',
                      'Буруу үг бол ээлж алдахгүй, зөвхөн сонголт арилна.',
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: GameButton(
                label: 'Ойлголоо',
                color: AppColors.red,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.lines,
  });

  final String icon;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$icon  $title',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.woodDark,
            ),
          ),
          const SizedBox(height: 4),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                line,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.text,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Хохирол хэрхэн тооцогдохыг жишээгээр харуулна.
class _DamageExample extends StatelessWidget {
  const _DamageExample();

  @override
  Widget build(BuildContext context) {
    // Жишээ: үсэг бүрийн оноо тоглоомд хавтан бүр дээр бичигдсэн байдаг.
    const letters = [('м', 2), ('о', 1), ('р', 1), ('ь', 3)];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.tileBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚔️  Хохирол хэрхэн тооцогдох вэ?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.woodDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Хавтан бүрийн баруун доод буланд оноо бичигтэй. '
              'Түгээмэл үсэг бага (1–2), ховор үсэг их (3–5) оноотой.',
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < letters.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: LetterTileWidget(
                      tile: LetterTile(
                        id: i,
                        letter: letters[i].$1,
                        points: letters[i].$2,
                      ),
                      size: 44,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Жишээ: 2 + 1 + 1 + 3 = 7 хохирол',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Урт үг илүү хүчтэй — нийлбэрийг үржүүлнэ:',
              style: TextStyle(fontSize: 14, color: AppColors.text),
            ),
            const SizedBox(height: 4),
            const Text(
              '• 3–4 үсэг: ×1\n• 5–6 үсэг: ×1.5\n• 7–8 үсэг: ×2\n• 9+ үсэг: ×3',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
