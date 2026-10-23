import 'dart:async';

import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../core/theme.dart';

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
      body: Center(
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
              Text('⚔️📜', style: TextStyle(fontSize: 88)),
              SizedBox(height: 12),
              Text(
                'Үгийн Тулаан',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: AppColors.woodDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
