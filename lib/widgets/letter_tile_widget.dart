import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../models/letter_tile.dart';

/// Нэг сийлбэртэй модон/ясан үсгийн хавтан. Баруун доод буланд оноо нь бичигдэнэ.
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
        opacity: hidden ? 0.16 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, AppColors.tile, AppColors.tileBottom],
              stops: [0.0, 0.72, 1.0],
            ),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.tileBorder, width: 2),
            boxShadow: const [
              BoxShadow(color: AppColors.tileShadow, offset: Offset(0, 3)),
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Дээд ирмэгийн дотор гялбаа
              Positioned(
                top: 2,
                left: 4,
                right: 4,
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Center(
                child: Text(
                  tile.letter.toUpperCase(),
                  style: TextStyle(
                    fontSize: size * 0.48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                    shadows: const [
                      Shadow(color: Colors.white70, offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 2,
                child: Text(
                  '${tile.points}',
                  style: TextStyle(
                    fontSize: size * 0.21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tileShadow,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
