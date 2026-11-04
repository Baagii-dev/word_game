import 'package:flutter/material.dart';

import '../design/theme.dart';

/// "26/26" гэх мэт гялгар 3D амийн мөр (HP bar).
class HpBar extends StatelessWidget {
  const HpBar({
    super.key,
    required this.current,
    required this.max,
    required this.color,
  });

  final int current;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = max == 0 ? 0.0 : (current / max).clamp(0.0, 1.0).toDouble();
    final topColor = Color.lerp(color, Colors.white, 0.28) ?? color;
    final botColor = Color.lerp(color, Colors.black, 0.22) ?? color;

    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.navyDeep.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 3),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: ratio, end: ratio),
                duration: AppDurations.normal,
                curve: Curves.easeOutCubic,
                builder: (context, val, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: val,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [topColor, color, botColor],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Дээд талын гялгар зурвас
            Positioned(
              top: 2,
              left: 4,
              right: 4,
              height: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Center(
              child: Text(
                '$current/$max',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
