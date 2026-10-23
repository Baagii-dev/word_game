import 'package:flutter/material.dart';

/// "-12" гэсэн тоо дээш хөөрч бүдгэрнэ. [event] өөрчлөгдөх бүрт дахин тоглоно.
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
      builder: (context, t, _) => Opacity(
        opacity: (1 - t).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, -60 * t),
          child: Text(
            '-$amount',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.redAccent,
              shadows: [Shadow(color: Colors.white, blurRadius: 6)],
            ),
          ),
        ),
      ),
    );
  }
}
