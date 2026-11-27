import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/enemy.dart';
import '../theme.dart';
import 'character_frame.dart';

/// Дайсны дүрс: зураг (`image`) байвал PNG зургийг,
/// үгүй бол [kind]-д тохирох кодоор зурсан толгойг дугуй хүрээнд харуулна.
class EnemyArt extends StatelessWidget {
  const EnemyArt({
    super.key,
    required this.kind,
    this.image,
    required this.size,
  });

  final EnemyKind kind;
  final String? image; // жишээ: 'assets/images/characters/wolf.png'
  final double size;

  @override
  Widget build(BuildContext context) => imageOrDrawn(
    image: image,
    size: size,
    drawn: CharacterFrame(size: size, painter: _EnemyPainter(kind)),
  );
}

class _EnemyPainter extends CustomPainter {
  const _EnemyPainter(this.kind);

  final EnemyKind kind;

  static const _white = Color(0xFFFFFBF2);
  static const _black = Color(0xFF1A1418);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Дэвсгэр: бараан улаан радиал (дайсных гэдэг нь тод)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.2),
          colors: [Color(0xFF6B232B), Color(0xFF3B1219), AppColors.navyDeep],
          stops: [0.0, 0.6, 1.0],
        ).createShader(rect),
    );

    final d = _Draw(canvas, size.width);
    switch (kind) {
      case EnemyKind.mouse:
        _mouse(d);
      case EnemyKind.snake:
        _snake(d);
      case EnemyKind.wolf:
        _wolf(d);
      case EnemyKind.fox:
        _fox(d);
      case EnemyKind.bear:
        _bear(d);
      case EnemyKind.tiger:
        _tiger(d);
      case EnemyKind.eagle:
        _eagle(d);
      case EnemyKind.dragon:
        _dragon(d);
      case EnemyKind.witch:
        _witch(d);
      case EnemyKind.demon:
        _demon(d);
    }
  }

  void _mouse(_Draw d) {
    const grey = Color(0xFF9EA7B3);
    const greyDark = Color(0xFF6F7884);
    const pink = Color(0xFFF2A0B5);
    d.circle(0.27, 0.33, 0.15, greyDark, both: true);
    d.circle(0.27, 0.33, 0.09, pink, both: true);
    d.oval(0.5, 0.6, 0.5, 0.46, grey);
    d.oval(0.5, 0.69, 0.26, 0.18, const Color(0xFFD5DAE0));
    d.bead(0.41, 0.55, 0.04);
    d.circle(0.5, 0.65, 0.032, pink);
    d.line(
      'M 0.40 0.67 L 0.22 0.63 M 0.40 0.70 L 0.22 0.72',
      _white,
      0.008,
      both: true,
    );
    d.fill('M 0.475 0.72 L 0.525 0.72 L 0.525 0.76 L 0.475 0.76 Z', _white);
  }

  void _snake(_Draw d) {
    const green = Color(0xFF5BAA3C);
    const dark = Color(0xFF3B7A26);
    d.line('M 0.12 0.92 Q 0.5 0.66 0.88 0.92', dark, 0.16);
    d.line('M 0.12 0.92 Q 0.5 0.66 0.88 0.92', green, 0.11);
    d.oval(0.5, 0.68, 0.2, 0.3, green);
    d.oval(0.5, 0.45, 0.5, 0.36, green);
    d.circle(0.38, 0.35, 0.03, dark, both: true);
    d.circle(0.5, 0.31, 0.035, dark);
    d.eye(0.39, 0.44, 0.055, const Color(0xFFF5D33B), slit: true, brow: dark);
    d.circle(0.46, 0.53, 0.012, dark, both: true);
    d.line('M 0.38 0.56 Q 0.5 0.62 0.62 0.56', dark, 0.014);
    d.line(
      'M 0.5 0.6 L 0.5 0.72 L 0.46 0.77 M 0.5 0.72 L 0.54 0.77',
      const Color(0xFFE5393B),
      0.018,
    );
  }

  void _wolf(_Draw d) {
    const grey = Color(0xFF7D8794);
    const dark = Color(0xFF4E5662);
    d.fill('M 0.24 0.40 L 0.30 0.12 L 0.45 0.30 Z', dark, both: true);
    d.fill(
      'M 0.29 0.34 L 0.32 0.19 L 0.40 0.30 Z',
      const Color(0xFFC98A8A),
      both: true,
    );
    d.fill('M 0.22 0.48 L 0.13 0.70 L 0.34 0.66 Z', grey, both: true);
    d.oval(0.5, 0.5, 0.56, 0.5, grey);
    d.oval(0.5, 0.66, 0.3, 0.26, const Color(0xFFDCE1E6));
    d.eye(0.38, 0.47, 0.05, const Color(0xFFF3C33A), brow: dark);
    d.oval(0.5, 0.59, 0.1, 0.07, _black);
    d.line(
      'M 0.5 0.62 L 0.5 0.69 Q 0.46 0.73 0.42 0.71',
      dark,
      0.014,
      both: true,
    );
    d.fill('M 0.44 0.715 L 0.455 0.77 L 0.47 0.72 Z', _white, both: true);
  }

  void _fox(_Draw d) {
    const orange = Color(0xFFE8782A);
    const dark = Color(0xFF3A2418);
    d.fill('M 0.20 0.42 L 0.26 0.10 L 0.44 0.30 Z', orange, both: true);
    d.fill('M 0.26 0.36 L 0.28 0.18 L 0.38 0.30 Z', dark, both: true);
    d.fill(
      'M 0.16 0.42 Q 0.5 0.16 0.84 0.42 Q 0.74 0.66 0.5 0.80 '
      'Q 0.26 0.66 0.16 0.42 Z',
      orange,
    );
    d.fill(
      'M 0.17 0.45 Q 0.34 0.56 0.5 0.62 L 0.5 0.80 Q 0.28 0.68 0.17 0.45 Z',
      _white,
      both: true,
    );
    d.eye(0.37, 0.47, 0.045, const Color(0xFFF1B83A), slit: true, brow: dark);
    d.circle(0.5, 0.74, 0.035, dark);
  }

  void _bear(_Draw d) {
    const brown = Color(0xFF8B5A2B);
    const dark = Color(0xFF5E3A1A);
    d.circle(0.28, 0.30, 0.11, brown, both: true);
    d.circle(0.28, 0.30, 0.06, dark, both: true);
    d.oval(0.5, 0.56, 0.62, 0.56, brown);
    d.oval(0.5, 0.68, 0.3, 0.24, const Color(0xFFD2A46E));
    d.bead(0.38, 0.50, 0.035);
    d.line('M 0.32 0.42 L 0.43 0.46', dark, 0.025, both: true);
    d.oval(0.5, 0.62, 0.12, 0.08, const Color(0xFF241509));
    d.line(
      'M 0.5 0.66 L 0.5 0.71 Q 0.47 0.74 0.44 0.72',
      dark,
      0.016,
      both: true,
    );
  }

  void _tiger(_Draw d) {
    const orange = Color(0xFFF08A24);
    d.circle(0.25, 0.30, 0.1, orange, both: true);
    d.circle(0.25, 0.30, 0.05, const Color(0xFFFFE3C4), both: true);
    d.oval(0.5, 0.55, 0.66, 0.58, orange);
    d.oval(0.42, 0.68, 0.2, 0.16, _white, both: true);
    d.oval(0.5, 0.76, 0.14, 0.08, _white);
    d.line('M 0.42 0.29 Q 0.45 0.34 0.43 0.38', _black, 0.025, both: true);
    d.line('M 0.5 0.27 L 0.5 0.36', _black, 0.025);
    d.line(
      'M 0.18 0.52 L 0.29 0.55 M 0.19 0.62 L 0.29 0.62',
      _black,
      0.025,
      both: true,
    );
    d.eye(0.39, 0.49, 0.05, const Color(0xFF9BD34A), brow: _black);
    d.fill('M 0.45 0.62 L 0.55 0.62 L 0.5 0.67 Z', const Color(0xFFE07A86));
    d.line(
      'M 0.5 0.67 L 0.5 0.70 Q 0.46 0.74 0.42 0.71',
      _black,
      0.016,
      both: true,
    );
  }

  void _eagle(_Draw d) {
    const body = Color(0xFF2C2F3A);
    const beak = Color(0xFFF2B233);
    const beakDark = Color(0xFFC07F12);
    d.fill('M 0.36 0.28 L 0.28 0.13 L 0.46 0.23 Z', body, both: true);
    d.fill('M 0.45 0.24 L 0.5 0.10 L 0.55 0.24 Z', body);
    d.oval(0.5, 0.52, 0.6, 0.6, body);
    d.fill(
      'M 0.2 0.56 Q 0.3 0.74 0.5 0.80 L 0.5 0.70 Q 0.32 0.66 0.2 0.56 Z',
      const Color(0xFF454A5A),
      both: true,
    );
    d.eye(
      0.38,
      0.46,
      0.055,
      const Color(0xFFFF8A2A),
      brow: const Color(0xFF0E1014),
    );
    d.fill('M 0.41 0.54 Q 0.5 0.49 0.59 0.54 L 0.5 0.76 Z', beak);
    d.line('M 0.44 0.62 L 0.5 0.66 L 0.56 0.62', beakDark, 0.012);
    d.circle(0.46, 0.555, 0.01, beakDark, both: true);
  }

  void _dragon(_Draw d) {
    const green = Color(0xFF2FA37A);
    const dark = Color(0xFF1C6B4F);
    d.fill(
      'M 0.32 0.32 Q 0.22 0.16 0.16 0.08 Q 0.32 0.14 0.42 0.28 Z',
      const Color(0xFFF3E2B3),
      both: true,
    );
    d.oval(0.5, 0.48, 0.54, 0.44, green);
    d.fill('M 0.45 0.28 L 0.5 0.18 L 0.55 0.28 Z', dark);
    d.oval(0.5, 0.68, 0.44, 0.28, green);
    d.oval(0.5, 0.73, 0.3, 0.13, const Color(0xFFB8E6A0));
    d.oval(0.43, 0.63, 0.04, 0.03, dark, both: true);
    d.eye(0.38, 0.47, 0.06, const Color(0xFFFFD23F), slit: true, brow: dark);
    d.line('M 0.32 0.75 Q 0.5 0.80 0.68 0.75', dark, 0.015);
    d.fill('M 0.36 0.76 L 0.39 0.81 L 0.42 0.775 Z', _white, both: true);
  }

  void _witch(_Draw d) {
    const skin = Color(0xFF8FBF6A);
    const skinDark = Color(0xFF5E8A44);
    const hat = Color(0xFF2A1838);
    d.fill(
      'M 0.26 0.40 Q 0.14 0.70 0.24 0.88 L 0.36 0.70 Z',
      const Color(0xFF4A3A5A),
      both: true,
    );
    d.oval(0.5, 0.58, 0.42, 0.48, skin);
    d.oval(0.5, 0.38, 0.80, 0.12, hat);
    d.fill('M 0.30 0.38 Q 0.40 0.20 0.52 0.04 Q 0.60 0.14 0.70 0.38 Z', hat);
    d.fill(
      'M 0.31 0.32 L 0.69 0.32 L 0.70 0.37 L 0.30 0.37 Z',
      const Color(0xFF7B3FA0),
    );
    d.eye(0.41, 0.54, 0.045, const Color(0xFFE53935), brow: hat);
    d.fill('M 0.5 0.55 Q 0.56 0.66 0.52 0.70 L 0.47 0.68 Z', skinDark);
    d.circle(0.535, 0.64, 0.012, skinDark);
    d.line('M 0.40 0.74 Q 0.5 0.80 0.60 0.73', hat, 0.018);
    d.fill('M 0.46 0.765 L 0.48 0.80 L 0.50 0.772 Z', _white);
  }

  void _demon(_Draw d) {
    const red = Color(0xFFD13A2E);
    const dark = Color(0xFF8A1E18);
    const hair = Color(0xFF2A1210);
    d.fill(
      'M 0.30 0.34 Q 0.20 0.20 0.24 0.06 Q 0.34 0.22 0.42 0.28 Z',
      const Color(0xFFF1E3C0),
      both: true,
    );
    d.oval(0.5, 0.55, 0.6, 0.6, red);
    d.fill(
      'M 0.27 0.38 Q 0.36 0.22 0.5 0.26 Q 0.64 0.22 0.73 0.38 '
      'Q 0.6 0.32 0.5 0.36 Q 0.4 0.32 0.27 0.38 Z',
      hair,
    );
    d.eye(0.39, 0.50, 0.06, const Color(0xFFFFE14D), brow: hair);
    d.oval(0.5, 0.62, 0.12, 0.08, dark);
    d.fill(
      'M 0.34 0.70 Q 0.5 0.84 0.66 0.70 Q 0.5 0.76 0.34 0.70 Z',
      const Color(0xFF3A0E0C),
    );
    d.fill('M 0.38 0.72 L 0.40 0.65 L 0.43 0.735 Z', _white, both: true);
  }

  @override
  bool shouldRepaint(_EnemyPainter old) => old.kind != kind;
}

/// Жижиг зурах туслах: бүх координат 0..1 (дүрсний өргөнд харьцуулсан).
/// Замыг 'M x y L x y Q cx cy x y C … Z' гэсэн богино бичлэгээр өгнө.
/// `both: true` бол зүүн талыг зураад баруун талд толин тусгалаар давтана.
class _Draw {
  _Draw(this.canvas, this.u);

  final Canvas canvas;
  final double u;

  Paint _fill(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true;

  Path _mirror(Path p) => p.transform(
    Float64List.fromList([-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, u, 0, 0, 1]),
  );

  static final _space = RegExp(r'\s+');
  static final _command = RegExp(r'^[A-Z]$');

  Path _path(String spec) {
    final t = spec.trim().split(_space);
    final path = Path();
    var i = 0;
    double n() => double.parse(t[i++]) * u;
    var cmd = 'M';
    while (i < t.length) {
      if (_command.hasMatch(t[i])) cmd = t[i++];
      switch (cmd) {
        case 'M':
          path.moveTo(n(), n());
        case 'L':
          path.lineTo(n(), n());
        case 'Q':
          path.quadraticBezierTo(n(), n(), n(), n());
        case 'C':
          path.cubicTo(n(), n(), n(), n(), n(), n());
        case 'Z':
          path.close();
          cmd = '';
        default:
          throw FormatException('Буруу зам: $spec');
      }
    }
    return path;
  }

  void _draw(Path p, Paint paint, bool both) {
    canvas.drawPath(p, paint);
    if (both) canvas.drawPath(_mirror(p), paint);
  }

  void fill(String spec, Color c, {bool both = false}) =>
      _draw(_path(spec), _fill(c), both);

  void line(String spec, Color c, double width, {bool both = false}) => _draw(
    _path(spec),
    Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
    both,
  );

  void circle(double x, double y, double r, Color c, {bool both = false}) =>
      _draw(
        Path()..addOval(
          Rect.fromCircle(center: Offset(x * u, y * u), radius: r * u),
        ),
        _fill(c),
        both,
      );

  void oval(
    double x,
    double y,
    double w,
    double h,
    Color c, {
    bool both = false,
  }) => _draw(
    Path()..addOval(
      Rect.fromCenter(
        center: Offset(x * u, y * u),
        width: w * u,
        height: h * u,
      ),
    ),
    _fill(c),
    both,
  );

  /// Жижиг хар сувдан нүд (хөөрхөн амьтад). Үргэлж хоёр талд.
  void bead(double x, double y, double r) {
    for (final xx in [x, 1 - x]) {
      final c = Offset(xx * u, y * u);
      canvas.drawCircle(c, r * u, _fill(_EnemyPainter._black));
      canvas.drawCircle(
        c.translate(-r * u * 0.35, -r * u * 0.35),
        r * u * 0.35,
        _fill(Colors.white),
      );
    }
  }

  /// Өнгөт нүд: хүүхэн хараа (дугуй эсвэл [slit] босоо), гялбаа,
  /// [brow] өгвөл дотогшоо доошилсон ууртай хөмсөг. Үргэлж хоёр талд.
  void eye(
    double x,
    double y,
    double r,
    Color iris, {
    bool slit = false,
    Color? brow,
  }) {
    final R = r * u;
    for (final xx in [x, 1 - x]) {
      final c = Offset(xx * u, y * u);
      canvas.drawCircle(c, R, _fill(iris));
      canvas.drawCircle(
        c,
        R,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = R * 0.18,
      );
      if (slit) {
        canvas.drawOval(
          Rect.fromCenter(center: c, width: R * 0.4, height: R * 1.6),
          _fill(_EnemyPainter._black),
        );
      } else {
        canvas.drawCircle(c, R * 0.5, _fill(_EnemyPainter._black));
      }
      canvas.drawCircle(
        c.translate(-R * 0.35, -R * 0.35),
        R * 0.25,
        _fill(Colors.white),
      );
      if (brow != null) {
        final s = xx < 0.5 ? 1.0 : -1.0;
        canvas.drawLine(
          c.translate(-s * R * 1.3, -R * 1.5),
          c.translate(s * R * 1.0, -R * 0.8),
          Paint()
            ..color = brow
            ..strokeWidth = R * 0.45
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }
}
