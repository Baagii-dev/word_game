import 'package:flutter/material.dart';

import '../design/theme.dart';

/// Нарийн, орчин үеийн амийн мөр (HP bar). Дээр нь нэр ба "26/26" тоо.
class HpBar extends StatelessWidget {
  const HpBar({
    super.key,
    required this.current,
    required this.max,
    required this.color,
    this.label,
    this.alignEnd = false,
  });

  final int current;
  final int max;
  final Color color;
  final String? label;

  /// Баруун талын (дайсны) мөрийг баруунаас зүүн тийш дүүргэнэ.
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final ratio = max == 0 ? 0.0 : (current / max).clamp(0.0, 1.0).toDouble();
    final light = Color.lerp(color, Colors.white, 0.35) ?? color;

    final caption = Row(
      children: [
        if (label != null)
          Expanded(
            child: Text(
              label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: alignEnd ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          )
        else
          const Spacer(),
      ],
    );

    final value = Text(
      '$current/$max',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: alignEnd
              ? [value, const SizedBox(width: 6), Expanded(child: caption)]
              : [Expanded(child: caption), const SizedBox(width: 6), value],
        ),
        const SizedBox(height: 5),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: ratio, end: ratio),
            duration: AppDurations.normal,
            curve: Curves.easeOutCubic,
            builder: (context, val, _) => FractionallySizedBox(
              alignment: alignEnd
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              widthFactor: val,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: alignEnd ? [color, light] : [light, color],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.55),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
