import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../design/characters/hero_art.dart';
import '../design/glass.dart';
import '../design/scene_background.dart';
import '../design/theme.dart';

/// Нээлтийн дэлгэц: лого томорч харагдаад нүүр хуудас руу шилжинэ.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.pushReplacementNamed(context, Routes.home);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: SceneBackground(horizon: 0.76)),
          const Positioned.fill(child: ScrimOverlay(top: 0.3, bottom: 0.6)),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.elasticOut,
              builder: (context, scale, child) => Opacity(
                opacity: scale.clamp(0.0, 1.0),
                child: Transform.scale(scale: scale, child: child),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeroArt(size: 110),
                  SizedBox(height: 12),
                  Text(
                    kAppTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.8,
                      shadows: [
                        Shadow(color: AppColors.bronze, blurRadius: 24),
                        Shadow(
                          color: Color(0x66000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Монгол ардын үлгэрийн үгийн тулаан',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
