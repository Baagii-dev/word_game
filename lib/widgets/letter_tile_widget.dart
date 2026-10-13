import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/letter_tile.dart';

/// Нэг модон үсгийн хавтан. Баруун доод буланд оноо нь бичигдэнэ.
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
    return GestureDetector(
      onTap: hidden ? null : onTap,
      child: AnimatedOpacity(
        opacity: hidden ? 0.15 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.tile,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.tileBorder, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black38, offset: Offset(0, 3)),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  tile.letter.toUpperCase(),
                  style: TextStyle(
                    fontSize: size * 0.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 2,
                child: Text(
                  '${tile.points}',
                  style: TextStyle(fontSize: size * 0.2, color: AppColors.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
