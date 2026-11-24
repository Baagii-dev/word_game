import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../wallet/wallet_service.dart';
import '../theme.dart';

/// Баатрын дүрс: `AppAssets.heroImage` тохируулбал PNG зураг,
/// үгүй бол вектороор зурахгүйгээр бэлэн виджет/эможи харуулна.
class HeroArt extends StatelessWidget {
  const HeroArt({super.key, required this.size});

  final double size;

  /// Дэлгүүрээс сонгосон баатрын дүр (emoji).
  String get heroEmoji => WalletService.instance.heroEmoji;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF4285D6), AppColors.heroDeel, AppColors.navyDeep],
        ),
        border: Border.all(color: AppColors.accent, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: FittedBox(
        child: Text(
          heroEmoji,
          style: const TextStyle(fontSize: 80, height: 1.1),
        ),
      ),
    );

    final image = AppAssets.heroImage;
    if (image == null || image.isEmpty) return badge;

    return Image.asset(
      image,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => badge,
    );
  }
}
