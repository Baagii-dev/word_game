import 'package:flutter/material.dart';

/// "26/26" гэх мэт амийн мөр.
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

    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio,
                child: Container(color: color),
              ),
            ),
            Center(
              child: Text(
                '$current/$max',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
