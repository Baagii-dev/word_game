import 'package:flutter/material.dart';

import 'theme.dart';

/// Дэлгэцийн дээд/доод ирмэгийг чимэх алтан хүрээтэй тууз (вектороор зурахгүй).
class OrnamentStrip extends StatelessWidget {
  const OrnamentStrip({
    super.key,
    this.height = 22,
    this.background = AppColors.navyDark,
    this.color = AppColors.accent,
  });

  final double height;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        border: Border.symmetric(
          horizontal: BorderSide(color: color, width: 1.6),
        ),
      ),
      alignment: Alignment.center,
      child: ClipRect(
        child: Text(
          '❖  ' * 40,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          style: TextStyle(
            color: color.withValues(alpha: 0.85),
            fontSize: height * 0.48,
            height: 1.0,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
