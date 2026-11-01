import 'package:flutter/material.dart';

import '../design/theme.dart';

/// "2/4" — хэд дэх дайсан (алтан хүрээтэй медальон).
class WaveIndicator extends StatelessWidget {
  const WaveIndicator({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [AppColors.navy, AppColors.navyDeep],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black38, offset: Offset(0, 3), blurRadius: 4),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚔️', style: TextStyle(fontSize: 11, height: 1.0)),
          Text(
            '$current/$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
