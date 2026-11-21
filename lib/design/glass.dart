import 'dart:ui';

import 'package:flutter/material.dart';

import 'theme.dart';

/// Орчин үеийн "glass" самбар: ар талыг бүдгэрүүлж (blur), тунгалаг өнгө,
/// нарийн цагаан хүрээтэй. Дэвсгэр зургийн дээр текст тод харагдуулна.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppSizes.radiusLg,
    this.tint = AppColors.ink,
    this.opacity = 0.42,
    this.borderColor = AppColors.inkLine,
    this.blur = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color tint;
  final double opacity;
  final Color borderColor;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AnimatedContainer(
          duration: AppDurations.normal,
          padding: padding,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: opacity),
            borderRadius: r,
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Дугуй glass товч (тохиргоо, буцах гэх мэт жижиг үйлдэлд).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 44,
    this.color = Colors.white,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final button = GlassPanel(
      padding: EdgeInsets.zero,
      radius: size / 2,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: size * 0.5,
              color: onPressed == null ? color.withValues(alpha: 0.4) : color,
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Дэвсгэрийн дээгүүр зөөлөн бараан градиент — текстийн уншигдах байдлыг сайжруулна.
class ScrimOverlay extends StatelessWidget {
  const ScrimOverlay({super.key, this.top = 0.35, this.bottom = 0.55});

  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.ink.withValues(alpha: top),
              AppColors.ink.withValues(alpha: 0.0),
              AppColors.ink.withValues(alpha: bottom),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}
