import 'package:flutter/material.dart';

import '../design/characters/enemy_art.dart';
import '../design/characters/hero_art.dart';
import '../design/glass.dart';
import '../design/parchment.dart';
import '../design/scene_background.dart';
import '../design/theme.dart';
import '../models/chapter.dart';
import '../services/audio_service.dart';
import '../widgets/game_button.dart';

/// Үлгэрийн хуудас: тулааны өмнө (эхлэл) эсвэл ялсны дараа (төгсгөл).
///
/// Текст үсэг үсгээр бичигдэнэ. Дэлгэц дээр дарвал бүтэн гарна, дахин дарвал
/// дараагийн хуудас. Сүүлийн хуудасны дараа [onFinished] дуудагдана.
class StoryScreen extends StatefulWidget {
  const StoryScreen({
    super.key,
    required this.chapter,
    required this.outro,
    required this.onFinished,
  });

  final Chapter chapter;

  /// true = төгсгөл (сургамжтай), false = эхлэл.
  final bool outro;
  final void Function(BuildContext context) onFinished;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late final List<String> _pages = widget.outro
      ? widget.chapter.outro
      : widget.chapter.intro;
  int _page = 0;
  bool _finished = false;

  late final AnimationController _typing = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    if (_pages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
    } else {
      _startTyping();
    }
  }

  @override
  void dispose() {
    _typing.dispose();
    super.dispose();
  }

  String get _text => _pages.isEmpty ? '' : _pages[_page];
  bool get _isLast => _page >= _pages.length - 1;

  void _startTyping() {
    // ~30 тэмдэгт/сек, гэхдээ нэг хуудас 4 секундээс удаан бичигдэхгүй
    final ms = (_text.length * 32).clamp(400, 4000);
    _typing
      ..duration = Duration(milliseconds: ms)
      ..forward(from: 0);
  }

  void _advance() {
    if (_typing.isAnimating) {
      _typing.value = 1; // бүтэн текстийг шууд харуулна
      return;
    }
    AudioService.instance.play(Sfx.tap);
    if (_isLast) {
      _finish();
    } else {
      setState(() => _page++);
      _startTyping();
    }
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    widget.onFinished(context);
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SceneBackground(scene: chapter.scene, horizon: 0.7),
          ),
          const Positioned.fill(child: ScrimOverlay(top: 0.45, bottom: 0.7)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      GlassIconButton(
                        icon: Icons.close_rounded,
                        tooltip: 'Буцах',
                        size: 40,
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _finish,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Алгасах »'),
                      ),
                    ],
                  ),
                ),
                // Зөвхөн хуудасны хэсэгт дарж урагшилна (дээд товчнуудад саад болохгүй)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _advance,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: _buildPage(chapter),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Dots(count: _pages.length, current: _page),
                        const SizedBox(height: 12),
                        GameButton(
                          label: _isLast
                              ? (widget.outro
                                    ? 'Үргэлжлүүлэх'
                                    : widget.chapter.path.isEmpty
                                    ? 'Тулаанд орох'
                                    : 'Замд гарах')
                              : 'Цааш',
                          icon: _isLast && !widget.outro
                              ? Icons.flash_on_rounded
                              : Icons.arrow_forward_rounded,
                          onPressed: _advance,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(Chapter chapter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Баатар ба (эхлэлд) бүлгийн гол дайсан
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HeroArt(size: 64),
            if (!widget.outro) ...[
              const SizedBox(width: 14),
              const Text(
                '⚔',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(width: 14),
              EnemyArt(
                kind: chapter.boss.kind,
                image: chapter.boss.image,
                size: 64,
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        ParchmentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.outro
                    ? '${chapter.id}-р үлгэр · Төгсгөл'
                    : '${chapter.id}-р үлгэр',
                style: TaleText.caption,
              ),
              const SizedBox(height: 4),
              Text(chapter.title, style: TaleText.title),
              const SizedBox(height: 4),
              Container(height: 2, width: 48, color: AppColors.seal),
              const SizedBox(height: 14),
              // Бүтэн текстийн өндрийг урьдчилан эзэлж, бичигдэх үед үсрэхгүй
              AnimatedBuilder(
                animation: _typing,
                builder: (context, _) {
                  final n = (_text.length * _typing.value).round();
                  return Stack(
                    children: [
                      Opacity(
                        opacity: 0,
                        child: Text(_text, style: TaleText.body),
                      ),
                      Text(_text.substring(0, n), style: TaleText.body),
                    ],
                  );
                },
              ),
              if (widget.outro && _isLast && chapter.moral.isNotEmpty) ...[
                const SizedBox(height: 16),
                _MoralBox(moral: chapter.moral),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Үлгэрийн сургамж — улаан тамгатай хайрцаг.
class _MoralBox extends StatelessWidget {
  const _MoralBox({required this.moral});

  final String moral;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.seal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.seal.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_stories_rounded, color: AppColors.seal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Сургамж: $moral',
              style: const TextStyle(
                color: AppColors.seal,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Хуудасны цэгүүд.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppDurations.fast,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == current
                  ? AppColors.accent
                  : Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
