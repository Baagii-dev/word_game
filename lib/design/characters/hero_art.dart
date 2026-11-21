import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../theme.dart';

/// Баатрын дүрс: `AppAssets.heroImage` тохируулбал PNG зураг,
/// үгүй бол кодоор зурсан баатар (монгол малгайтай, амьд нүдтэй, анивчдаг).
class HeroArt extends StatelessWidget {
  const HeroArt({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final drawn = _DrawnHero(size: size);

    final image = AppAssets.heroImage;
    if (image == null || image.isEmpty) return drawn;

    return Image.asset(
      image,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => drawn,
    );
  }
}

class _DrawnHero extends StatefulWidget {
  const _DrawnHero({required this.size});

  final double size;

  @override
  State<_DrawnHero> createState() => _DrawnHeroState();
}

class _DrawnHeroState extends State<_DrawnHero>
    with SingleTickerProviderStateMixin {
  // Анивчих хөдөлгөөн (0→1 богино хугацаанд). Хооронд нь Timer хүлээнэ —
  // тасралтгүй давтагдах анимаци биш тул тестийн pumpAndSettle гацахгүй.
  late final AnimationController _blink =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 220),
      )..addStatusListener((s) {
        if (s == AnimationStatus.completed) _scheduleBlink();
      });
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleBlink();
  }

  void _scheduleBlink() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 3600), () {
      if (mounted) _blink.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: ClipOval(
        child: RepaintBoundary(
          child: CustomPaint(painter: _HeroPainter(_blink)),
        ),
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  _HeroPainter(this.blink) : super(repaint: blink);

  final Animation<double> blink;

  static const _iris = Color(0xFF5A3418); // хүрэн нүд
  static const _pupil = Color(0xFF1A0F08);
  static const _brow = Color(0xFF2B1A10);
  static const _fur = Color(0xFF4A3020); // малгайн үслэг хүрээ

  /// 1 = нээлттэй, 0 = аньсан. Анивчих үед хаагдаад буцаж нээгдэнэ.
  double get _openness {
    final t = blink.value;
    if (t == 0 || t == 1) return 1;
    return (2 * t - 1).abs();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width;
    Offset p(double x, double y) => Offset(x * u, y * u);
    final fill = Paint()..isAntiAlias = true;

    // ---- Дэвсгэр: дулаан хүрэн радиал ----
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.3),
          colors: [AppColors.primary, AppColors.bronze, AppColors.bronzeDeep],
          stops: [0.0, 0.55, 1.0],
        ).createShader(Offset.zero & size),
    );

    // ---- Дээл (мөр) ба алтан энгэр ----
    canvas.drawOval(
      Rect.fromCenter(center: p(0.5, 1.04), width: 0.92 * u, height: 0.5 * u),
      fill..color = AppColors.heroDeel,
    );
    final collar = Path()
      ..moveTo(0.40 * u, 0.80 * u)
      ..quadraticBezierTo(0.5 * u, 0.90 * u, 0.62 * u, 0.80 * u);
    canvas.drawPath(
      collar,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.035 * u
        ..strokeCap = StrokeCap.round,
    );

    // ---- Хүзүү, чих, нүүр ----
    canvas.drawRect(
      Rect.fromLTWH(0.44 * u, 0.70 * u, 0.12 * u, 0.1 * u),
      fill..color = const Color(0xFFE2B48A),
    );
    fill.color = AppColors.heroSkin;
    canvas.drawCircle(p(0.285, 0.56), 0.045 * u, fill);
    canvas.drawCircle(p(0.715, 0.56), 0.045 * u, fill);
    canvas.drawOval(
      Rect.fromCenter(center: p(0.5, 0.56), width: 0.44 * u, height: 0.46 * u),
      fill,
    );

    // ---- Хацрын улайлт ----
    fill.color = const Color(0xFFE8826A).withValues(alpha: 0.35);
    canvas.drawCircle(p(0.365, 0.645), 0.038 * u, fill);
    canvas.drawCircle(p(0.635, 0.645), 0.038 * u, fill);

    // ---- Монгол малгай: улаан орой, үслэг хүрээ, алтан товч ----
    final dome = Path()
      ..moveTo(0.27 * u, 0.36 * u)
      ..cubicTo(0.28 * u, 0.16 * u, 0.42 * u, 0.09 * u, 0.5 * u, 0.09 * u)
      ..cubicTo(0.58 * u, 0.09 * u, 0.72 * u, 0.16 * u, 0.73 * u, 0.36 * u)
      ..close();
    canvas.drawPath(dome, fill..color = AppColors.heroHat);
    // Орой дээрх гялбаа
    canvas.drawPath(
      Path()
        ..moveTo(0.36 * u, 0.30 * u)
        ..quadraticBezierTo(0.38 * u, 0.17 * u, 0.48 * u, 0.13 * u),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.025 * u
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0.23 * u, 0.32 * u, 0.77 * u, 0.42 * u),
        Radius.circular(0.05 * u),
      ),
      fill..color = _fur,
    );
    canvas.drawCircle(p(0.5, 0.085), 0.04 * u, fill..color = AppColors.accent);

    // ---- Нүд ----
    final open = _openness;
    _eye(canvas, p(0.405, 0.55), u, open);
    _eye(canvas, p(0.595, 0.55), u, open);

    // ---- Шийдэмгий хөмсөг (дотор үзүүр нь доош) ----
    final brow = Paint()
      ..color = _brow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.026 * u
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(0.34, 0.47), p(0.45, 0.49), brow);
    canvas.drawLine(p(0.66, 0.47), p(0.55, 0.49), brow);

    // ---- Хамар, инээмсэглэл ----
    final line = Paint()
      ..color = const Color(0xFFB07850)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.018 * u
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: p(0.5, 0.6), width: 0.05 * u, height: 0.03 * u),
      0.2,
      2.7,
      false,
      line,
    );
    canvas.drawArc(
      Rect.fromCenter(center: p(0.5, 0.665), width: 0.12 * u, height: 0.07 * u),
      0.35,
      2.45,
      false,
      line..color = const Color(0xFF8A4A2E),
    );
  }

  /// Бүйлсэн хэлбэрийн нүд: цагаан, хүрэн солонгон бүрхэвч, хүүхэн хараа,
  /// гялбаа. [open] нь 0 болоход зовхи аньж, зураас болно.
  void _eye(Canvas canvas, Offset c, double u, double open) {
    final w = 0.125 * u;
    final h = 0.1 * u * open;

    if (open < 0.15) {
      canvas.drawLine(
        c.translate(-w / 2, 0),
        c.translate(w / 2, 0),
        Paint()
          ..color = _brow
          ..strokeWidth = 0.018 * u
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    final eyeRect = Rect.fromCenter(center: c, width: w, height: h);
    final shape = Path()..addOval(eyeRect);
    canvas.save();
    canvas.clipPath(shape);
    canvas.drawRect(eyeRect, Paint()..color = Colors.white);
    // Дайсан руу (баруун тийш) бага зэрэг харна
    final look = c.translate(0.008 * u, 0.003 * u);
    canvas.drawCircle(look, 0.04 * u, Paint()..color = _iris);
    canvas.drawCircle(look, 0.021 * u, Paint()..color = _pupil);
    canvas.drawCircle(
      look.translate(-0.01 * u, -0.012 * u),
      0.012 * u,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      look.translate(0.011 * u, 0.01 * u),
      0.005 * u,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
    canvas.restore();

    // Дээд зовхины зураас — нүдийг тод болгоно
    canvas.drawArc(
      eyeRect,
      3.4,
      2.6,
      false,
      Paint()
        ..color = _brow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.016 * u
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_HeroPainter old) => false;
}
