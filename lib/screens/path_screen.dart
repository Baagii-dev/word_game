import 'dart:math';

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../design/characters/enemy_art.dart';
import '../design/characters/hero_art.dart';
import '../design/glass.dart';
import '../design/parchment.dart';
import '../design/theme.dart';
import '../design/weather.dart';
import '../logic/path_controller.dart';
import '../models/chapter.dart';
import '../models/tale_path.dart';
import '../services/audio_service.dart';
import '../services/dictionary_service.dart';
import '../widgets/game_button.dart';
import '../widgets/letter_grid.dart';
import '../widgets/shake_widget.dart';
import '../widgets/word_bar.dart';

/// ҮЛГЭРИЙН ЗАМ: баатар илгэн цаасан дээрх үлгэрийн өгүүлбэр дээгүүр алхаж,
/// замд тулгарсан саадыг текстэд сануулсан үгээр давна.
class PathScreen extends StatefulWidget {
  const PathScreen({
    super.key,
    required this.chapter,
    required this.onFinished,
  });

  final Chapter chapter;

  /// Замыг туулсны дараа (оноотой нь) дуудагдана.
  final void Function(BuildContext context, int score) onFinished;

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> with WidgetsBindingObserver {
  late PathController controller;

  @override
  void initState() {
    super.initState();
    controller = _create();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Шинэ controller: эхлээд оноож, дараа нь эхлүүлнэ (сонсогч нь
  /// [controller]-ийг уншдаг тул эхлэхээс өмнө оноогдсон байх ёстой).
  PathController _create() {
    final c = PathController(
      chapter: widget.chapter,
      dictionary: DictionaryService.instance,
    )..addListener(_onChange);
    controller = c;
    c.start();
    return c;
  }

  int _lastClear = 0, _lastHurt = 0, _lastInvalid = 0;

  void _onChange() {
    final c = controller;
    if (c.clearCount != _lastClear) AudioService.instance.play(Sfx.hit);
    if (c.hurtCount != _lastHurt) AudioService.instance.play(Sfx.enemyAttack);
    if (c.invalidCount != _lastInvalid) AudioService.instance.play(Sfx.invalid);
    _lastClear = c.clearCount;
    _lastHurt = c.hurtCount;
    _lastInvalid = c.invalidCount;
  }

  void _restart() {
    controller
      ..removeListener(_onChange)
      ..dispose();
    _lastClear = _lastHurt = _lastInvalid = 0;
    setState(() => controller = _create());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    state == AppLifecycleState.resumed
        ? controller.resume()
        : controller.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller
      ..removeListener(_onChange)
      ..dispose();
    super.dispose();
  }

  Future<void> _confirmExit() async {
    controller.pause();
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Замаас гарах уу?'),
        content: const Text('Үлгэрийн ном руу буцна.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Үргэлжлүүлэх'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Гарах'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      Navigator.pop(context);
    } else {
      controller.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildPage()),
                _buildBottomPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Дээд мөр: оноо, зүрх, хуудас, цаг ----------
  Widget _buildTopBar() {
    final c = controller;
    final facing = c.status == PathStatus.facing;
    final hurry = facing && c.timeLeft <= 5;
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GlassIconButton(
                icon: Icons.pause_rounded,
                tooltip: 'Түр зогсоох',
                size: 40,
                onPressed: _confirmExit,
              ),
              const SizedBox(width: 10),
              const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 2),
              Text(
                '${c.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),
              for (var i = 0; i < 3; i++)
                Icon(
                  Icons.favorite_rounded,
                  size: 18,
                  color: i < c.hearts
                      ? AppColors.red
                      : Colors.white.withValues(alpha: 0.18),
                ),
              const Spacer(),
              Text(
                '${c.segmentIndex + 1}/${c.segments.length}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.hourglass_bottom_rounded,
                size: 18,
                color: hurry ? AppColors.warning : Colors.white70,
              ),
              SizedBox(
                width: 26,
                child: Text(
                  facing ? '${c.timeLeft.ceil()}' : '–',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: hurry ? AppColors.warning : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: facing ? c.timeLeft / GameConfig.pathObstacleSeconds : 0,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: hurry ? AppColors.warning : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Илгэн цаасан хуудас: текст, баатар, саадууд ----------
  Widget _buildPage() {
    final c = controller;
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        gradient: const RadialGradient(
          center: Alignment(0, -0.1),
          radius: 1.1,
          colors: [AppColors.parchment, AppColors.parchmentDeep],
        ),
        border: Border.all(color: AppColors.parchmentEdge, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd - 2),
        child: Stack(
          children: [
            // Цаг агаар хуудасны ард бүдэгхэн
            Positioned.fill(
              child: Opacity(
                opacity: 0.9,
                child: _WeatherTint(scene: widget.chapter.scene),
              ),
            ),
            Positioned.fill(child: WeatherOverlay(scene: widget.chapter.scene)),
            Positioned(
              left: 14,
              right: 14,
              top: 10,
              child: Text(
                '${widget.chapter.title} · Үлгэрийн зам',
                textAlign: TextAlign.center,
                style: TaleText.caption,
              ),
            ),
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                child: KeyedSubtree(
                  key: ValueKey(c.segmentIndex),
                  child: LayoutBuilder(
                    builder: (context, box) => _buildScene(c, box),
                  ),
                ),
              ),
            ),
            if (c.status == PathStatus.finished)
              _EndCard(
                title: 'Зам туулав!',
                text:
                    'Та бүх саадыг даван ${c.score} оноо цуглууллаа. '
                    'Одоо ${widget.chapter.boss.name} хүлээж байна...',
                button: 'Мангастай тулалдах',
                icon: Icons.flash_on_rounded,
                onPressed: () => widget.onFinished(context, c.score),
              ),
            if (c.status == PathStatus.failed)
              _EndCard(
                title: 'Замдаа бүдэрлээ',
                text: c.message ?? '',
                button: 'Дахин оролдох',
                icon: Icons.replay_rounded,
                onPressed: _restart,
                secondary: 'Үлгэрийн ном руу',
                onSecondary: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScene(PathController c, BoxConstraints box) {
    final w = box.maxWidth;
    final h = box.maxHeight;
    final spriteSize = min(58.0, h * 0.2).clamp(32.0, 58.0);
    const sidePad = 18.0;
    final lineY = h * 0.5; // баатар алхах шугам (текстийн дээд ирмэг)
    double xAt(double t) => sidePad + t * (w - sidePad * 2);

    final walking = c.status == PathStatus.walking;
    final bob = walking ? -(sin(c.heroPos * 90).abs() * 4) : 0.0;
    final seg = c.segment;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Мессеж (саадын асуулт, зөв/буруу)
        if (c.message != null && !c.isOver)
          Positioned(
            left: 16,
            right: 16,
            top: 30,
            child: _Bubble(text: c.message!),
          ),
        // Үлгэрийн өгүүлбэр — баатрын зам
        Positioned(
          left: sidePad,
          right: sidePad,
          top: lineY + 4,
          child: _SegmentText(segment: seg),
        ),
        // Саадууд
        for (var i = 0; i < seg.obstacles.length; i++)
          _ObstacleSprite(
            key: ValueKey('o-${c.segmentIndex}-$i'),
            obstacle: seg.obstacles[i],
            cleared: c.isCleared(i),
            active: i == c.obstacleIndex && c.status == PathStatus.facing,
            hurtCount: c.hurtCount,
            size: spriteSize,
            left: xAt(seg.obstacles[i].at) - spriteSize / 2,
            bottom: h - lineY,
          ),
        // Баатар
        AnimatedPositioned(
          duration: PathController.tick,
          left: xAt(c.heroPos) - spriteSize / 2,
          bottom: h - lineY - bob,
          child: ShakeWidget(
            trigger: c.hurtCount,
            child: HeroArt(size: spriteSize),
          ),
        ),
      ],
    );
  }

  // ---------- Доод хэсэг: үсэг ----------
  Widget _buildBottomPanel() {
    final c = controller;
    final facing = c.canAct;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.inkSoft,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        12,
        14,
        12,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ShakeWidget(
                  trigger: c.invalidCount,
                  child: WordBar(tiles: c.selected, onTapTile: c.deselectTile),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Сүүлийн үсгийг арилгах',
                onPressed: facing && c.selected.isNotEmpty ? c.undo : null,
                icon: const Icon(Icons.backspace_rounded, size: 22),
                style: IconButton.styleFrom(
                  fixedSize: const Size(52, 58),
                  backgroundColor: AppColors.glass,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.06),
                  disabledForegroundColor: Colors.white30,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Алхаж байхад самбарын оронд тайлбар (өндөр нь ижил — үсрэхгүй)
          LayoutBuilder(
            builder: (context, box) {
              final tile = (box.maxWidth - LetterGrid.gap * 5) / 6;
              return SizedBox(
                height: tile * 2 + LetterGrid.gap,
                child: facing
                    ? LetterGrid(tiles: c.board, onTap: c.selectTile)
                    : Center(
                        child: Text(
                          switch (c.status) {
                            PathStatus.cleared => 'Саад давагдлаа!',
                            PathStatus.pageTurn => 'Дараагийн хуудас...',
                            PathStatus.finished => 'Зам дууслаа',
                            PathStatus.failed => 'Дахин оролдоорой',
                            _ =>
                              'Баатар замаар алхаж байна...\n'
                                  'Текстийг уншаад саадыг юугаар давахыг тааварла!',
                          },
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
              );
            },
          ),
          const SizedBox(height: 12),
          GameButton(
            label: 'Ашиглах',
            icon: Icons.back_hand_rounded,
            height: 48,
            onPressed: facing && c.selected.isNotEmpty ? c.submit : null,
          ),
        ],
      ),
    );
  }
}

/// Өгүүлбэр: `[үг]` хэсгүүд тод, улаан, доогуур зураастай.
class _SegmentText extends StatelessWidget {
  const _SegmentText({required this.segment});

  final PathSegment segment;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TaleText.body.copyWith(
          fontStyle: FontStyle.italic,
          fontSize: 17,
          height: 1.5,
        ),
        children: [
          for (final s in segment.spans)
            TextSpan(
              text: s.text,
              style: s.marked
                  ? const TextStyle(
                      color: AppColors.seal,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.seal,
                    )
                  : null,
            ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Саадын дүрс: идэвхтэй үед найгана, давагдахад унаж бүдгэрнэ.
class _ObstacleSprite extends StatelessWidget {
  const _ObstacleSprite({
    super.key,
    required this.obstacle,
    required this.cleared,
    required this.active,
    required this.hurtCount,
    required this.size,
    required this.left,
    required this.bottom,
  });

  final PathObstacle obstacle;
  final bool cleared;
  final bool active;
  final int hurtCount;
  final double size;
  final double left;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final art = obstacle.kind != null
        ? EnemyArt(kind: obstacle.kind!, size: size)
        : Text(
            obstacle.emoji ?? '❓',
            style: TextStyle(fontSize: size * 0.82, height: 1.1),
          );
    return Positioned(
      left: left,
      bottom: bottom,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        offset: cleared ? const Offset(0, 0.6) : Offset.zero,
        curve: Curves.easeIn,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: cleared ? 0 : 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active)
                Container(
                  key: const Key('obstacle-name'),
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.seal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    obstacle.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ShakeWidget(
                trigger: active ? hurtCount : 0,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Center(child: art),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Хуудасны дээд хэсгийн мессеж.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.parchmentInk.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.parchment,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}

/// Орчинд тохирсон бүдэг өнгөний давхарга (бороотой тал, халуун говь...).
class _WeatherTint extends StatelessWidget {
  const _WeatherTint({required this.scene});

  final Scene scene;

  @override
  Widget build(BuildContext context) {
    final color = switch (scene) {
      Scene.steppe => const Color(0x1A3D6E9E),
      Scene.desert => const Color(0x26E07B2E),
      Scene.winter => const Color(0x22A9C8E8),
      Scene.mountain => const Color(0x223B2F63),
      Scene.cave => const Color(0x33501020),
    };
    return ColoredBox(color: color);
  }
}

/// Зам дуусах / бүтэлгүйтэх үеийн карт.
class _EndCard extends StatelessWidget {
  const _EndCard({
    required this.title,
    required this.text,
    required this.button,
    required this.icon,
    required this.onPressed,
    this.secondary,
    this.onSecondary,
  });

  final String title;
  final String text;
  final String button;
  final IconData icon;
  final VoidCallback onPressed;
  final String? secondary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black38,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ParchmentCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TaleText.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    text,
                    style: TaleText.body.copyWith(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  GameButton(label: button, icon: icon, onPressed: onPressed),
                  if (secondary != null)
                    TextButton(
                      onPressed: onSecondary,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.parchmentInkSoft,
                      ),
                      child: Text(secondary!),
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
