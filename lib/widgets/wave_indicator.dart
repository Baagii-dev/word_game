import 'package:flutter/material.dart';

import '../core/theme.dart';

/// "2/4" — хэд дэх дайсан.
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
        color: AppColors.woodDark,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        '$current/$total',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
