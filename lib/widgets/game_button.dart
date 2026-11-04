import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../services/audio_service.dart';

/// Алтан хүрээтэй, 3D товгор загварын нэгдсэн товч. Дарахад жижгэрч, дуу гаргана.
class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.navy,
    this.foreground = Colors.white,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final Color foreground;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final topColor = Color.lerp(widget.color, Colors.white, 0.22) ?? widget.color;
    final botColor = Color.lerp(widget.color, Colors.black, 0.18) ?? widget.color;
    final shadowColor =
        Color.lerp(widget.color, Colors.black, 0.55) ?? Colors.black54;

    return GestureDetector(
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
        scale: _down ? 0.96 : 1,
        duration: const Duration(milliseconds: 90),
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [topColor, widget.color, botColor],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent, width: 2.2),
              boxShadow: _down
                  ? null
                  : [
                      BoxShadow(color: shadowColor, offset: const Offset(0, 4)),
                      const BoxShadow(
                        color: Colors.black38,
                        offset: Offset(0, 6),
                        blurRadius: 6,
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: widget.foreground, size: 24),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
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
