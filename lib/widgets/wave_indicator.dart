import 'package:flutter/material.dart';

import '../design/theme.dart';

/// "2/4" — хэд дэх дайсан (жижиг pill chip).
class WaveIndicator extends StatelessWidget {
  const WaveIndicator({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inkLine),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ДАЙСАН',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              height: 1.1,
            ),
          ),
          Text(
            '$current/$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
