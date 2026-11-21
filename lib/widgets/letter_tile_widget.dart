import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../models/letter_tile.dart';

/// Нэг үсгийн хавтан — цэвэр цагаан, зөөлөн сүүдэртэй.
/// Баруун доод буланд оноо нь бичигдэнэ.
class LetterTileWidget extends StatelessWidget {
  const LetterTileWidget({
    super.key,
    required this.tile,
    this.onTap,
    this.size = 48,
    this.hidden = false,
  });

  final LetterTile tile;
  final VoidCallback? onTap;
  final double size;
  final bool hidden; // сонгогдсон үед самбар дээр бүдэг үлдэнэ

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.26);
    return GestureDetector(
      onTap: hidden ? null : onTap,
      child: AnimatedOpacity(
        opacity: hidden ? 0.14 : 1,
        duration: AppDurations.fast,
        child: AnimatedScale(
          scale: hidden ? 0.9 : 1,
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFBF4), Color(0xFFF1E4D2)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
                BoxShadow(color: Color(0xFFCDB394), offset: Offset(0, 2)),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    tile.letter.toUpperCase(),
                    style: TextStyle(
                      fontSize: size * 0.46,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      height: 1.0,
                    ),
                  ),
                ),
                Positioned(
                  right: size * 0.1,
                  bottom: size * 0.06,
                  child: Text(
                    '${tile.points}',
                    style: TextStyle(
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.bronze,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
