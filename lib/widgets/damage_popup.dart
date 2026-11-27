import 'package:flutter/material.dart';

import '../design/theme.dart';

/// "-12" (хохирол) эсвэл "+4" (эдгэрэлт) гэсэн тоо томорч, дээш хөөрч бүдгэрнэ.
/// [event] өөрчлөгдөх бүрт дахин тоглоно.
class DamagePopup extends StatelessWidget {
  const DamagePopup({
    super.key,
    required this.event,
    required this.amount,
    this.heal = false,
  });

  final int event; // үйлдэл бүрийн дугаар
  final int? amount;
  final bool heal;

  @override
  Widget build(BuildContext context) {
    if (amount == null || event == 0) return const SizedBox.shrink();
    final glow = heal ? AppColors.mint : AppColors.primaryEnd;
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
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
                  heal ? '+$amount' : '-$amount',
                  style: TextStyle(
                    fontSize: heal ? 30 : 38,
                    fontWeight: FontWeight.w900,
                    color: heal ? const Color(0xFFDDFFD0) : Colors.white,
                    letterSpacing: -1,
                    shadows: [
                      Shadow(color: glow, blurRadius: 16),
                      const Shadow(
                        color: AppColors.ink,
                        offset: Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
