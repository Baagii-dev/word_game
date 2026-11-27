import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../services/audio_service.dart';

/// Орчин үеийн градиент товч: зөөлөн өнгөт гэрэлтэлт (glow), дарахад жижгэрнэ,
/// дуу гаргана. [glass] = true бол тунгалаг хоёрдогч товч болно.
class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.colors = const [AppColors.primary, AppColors.primaryEnd],
    this.foreground = Colors.white,
    this.glass = false,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final List<Color> colors;
  final Color foreground;
  final bool glass;
  final double height;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final r = BorderRadius.circular(AppSizes.radiusLg);

    final decoration = widget.glass
        ? BoxDecoration(
            color: AppColors.glass,
            borderRadius: r,
            border: Border.all(color: AppColors.glassStrong),
          )
        : BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
            ),
            borderRadius: r,
            boxShadow: _down || !enabled
                ? null
                : [
                    BoxShadow(
                      color: widget.colors.last.withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: enabled
            ? () {
                AudioService.instance.play(Sfx.tap);
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          child: AnimatedOpacity(
            opacity: enabled ? 1 : 0.45,
            duration: AppDurations.fast,
            child: AnimatedContainer(
              duration: AppDurations.fast,
              width: double.infinity,
              height: widget.height,
              padding: EdgeInsets.symmetric(
                horizontal: widget.height < 50 ? 10 : 20,
              ),
              decoration: decoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.foreground, size: 22),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    // Нарийн товчинд бичиг таслагдахгүй, жижгэрнэ
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        style: TextStyle(
                          color: widget.foreground,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
