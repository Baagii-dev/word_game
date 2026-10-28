import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Баатар эсвэл дайсны дүр + нэрийн самбар + анимац.
///
/// Анимац нь тоолуурын өөрчлөлтөөр (hitCount, attackCount) нэг удаа тоглогдоно:
///  • idle   — тайван байхдаа аажим дээш доош найгана
///  • attack — довтлоход өрсөлдөгч тийш шидэгдэнэ ([lunge] px)
///  • hit    — цохилт авахад сэгсэрч, улаан болно
///  • dead   — үхэхэд живж, бүдгэрнэ
class CharacterSprite extends StatefulWidget {
  const CharacterSprite({
    super.key,
    required this.art,
    required this.name,
    required this.size,
    this.hitCount = 0,
    this.attackCount = 0,
    this.isDead = false,
    this.lunge = 28,
  });

  /// Дүрсний зураг (HeroArt / EnemyArt г.м).
  final Widget art;
  final String name;

  /// Дүрсний өндөр (px). Нэрийн самбар үүнээс гадна нэмэгдэнэ.
  final double size;

  /// Энэ дүр цохилт авах бүрт нэмэгдэх тоолуур.
  final int hitCount;

  /// Энэ дүр довтлох бүрт нэмэгдэх тоолуур.
  final int attackCount;
  final bool isDead;

  /// Довтлоход хөдлөх зай: баруун тийш (+), зүүн тийш (−).
  final double lunge;

  @override
  State<CharacterSprite> createState() => _CharacterSpriteState();
}

class _CharacterSpriteState extends State<CharacterSprite>
    with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);
  late final AnimationController _hit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final AnimationController _attack = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _death = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
  );

  @override
  void initState() {
    super.initState();
    if (widget.isDead) _death.value = 1;
  }

  @override
  void didUpdateWidget(CharacterSprite old) {
    super.didUpdateWidget(old);
    if (widget.hitCount != old.hitCount) _hit.forward(from: 0);
    if (widget.attackCount != old.attackCount) _attack.forward(from: 0);
    if (widget.isDead != old.isDead) {
      widget.isDead ? _death.forward() : _death.reverse();
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _hit.dispose();
    _attack.dispose();
    _death.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: Listenable.merge([_idle, _hit, _attack, _death]),
      builder: (context, _) {
        final bob = -4 * Curves.easeInOut.transform(_idle.value);
        final lunge = widget.lunge * sin(pi * _attack.value);
        final shake = _hit.isAnimating
            ? sin(_hit.value * pi * 6) * 7 * (1 - _hit.value)
            : 0.0;
        final flash = _hit.isAnimating ? (1 - _hit.value) * 0.6 : 0.0;
        final d = Curves.easeIn.transform(_death.value);

        Widget art = widget.art;
        if (flash > 0) {
          art = ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.red.withValues(alpha: flash),
              BlendMode.srcATop,
            ),
            child: art,
          );
        }

        return Opacity(
          opacity: 1 - d,
          child: SizedBox(
            width: size * 1.35,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: size + 10,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Газар дээрх сүүдэр (дүр дээш гарахад жижгэрнэ)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: size * 0.8 * (1 + bob / 60),
                          height: size * 0.14,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(size),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        child: Transform.translate(
                          offset: Offset(lunge + shake, bob + 16 * d),
                          child: Transform.scale(
                            scale: 1 - 0.3 * d,
                            child: art,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navyDark,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
