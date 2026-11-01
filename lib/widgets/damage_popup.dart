import 'package:flutter/material.dart';

import '../design/theme.dart';

/// "-12" гэсэн тоо томорч, дээш хөөрч бүдгэрнэ. [event] өөрчлөгдөх бүрт дахин тоглоно.
class DamagePopup extends StatelessWidget {
  const DamagePopup({super.key, required this.event, required this.amount});

  final int event; // цохилт бүрийн дугаар
  final int? amount;

  @override
  Widget build(BuildContext context) {
    if (amount == null) return const SizedBox.shrink();
    return TweenAnimationBuilder<double>(
      key: ValueKey(event),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, t, _) {
        final scale = t < 0.25
            ? 0.7 + (t / 0.25) * 0.55
            : 1.25 - (t - 0.25) * 0.25;
        return Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -64 * t),
            child: Transform.scale(
              scale: scale,
              child: Text(
                '-$amount',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: AppColors.warning,
                  shadows: [
                    Shadow(
                      color: AppColors.red,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                    Shadow(
                      color: AppColors.navyDeep,
                      offset: Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
