import 'dart:math';

import 'package:flutter/material.dart';

import '../design/characters/character_sprite.dart';
import '../design/characters/enemy_art.dart';
import '../design/characters/hero_art.dart';
import '../design/glass.dart';
import '../design/scene_background.dart';
import '../design/theme.dart';
import '../logic/battle_controller.dart';
import '../models/chapter.dart';
import '../models/enemy.dart';
import '../services/audio_service.dart';
import '../services/dictionary_service.dart';
import '../widgets/damage_popup.dart';
import '../widgets/game_button.dart';
import '../widgets/hp_bar.dart';
import '../widgets/letter_grid.dart';
import '../widgets/shake_widget.dart';
import '../widgets/word_bar.dart';
import 'tale_flow.dart';

/// Тулааны дэлгэц. Тоглоомын дүрэм BattleController-т, энд зөвхөн харуулна.
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.chapter});

  final Chapter chapter;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with WidgetsBindingObserver {
  late final BattleController controller;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    controller =
        BattleController(
            chapter: widget.chapter,
            dictionary: DictionaryService.instance,
          )
          ..onEvent = _onEvent
          ..start();
    controller.addListener(_checkEnd);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.resume();
    } else {
      controller.pause();
    }
  }

  void _onEvent(BattleEvent e) {
    AudioService.instance.play(switch (e) {
      BattleEvent.hit => Sfx.hit,
      BattleEvent.heal => Sfx.heal,
      BattleEvent.invalid => Sfx.invalid,
      BattleEvent.enemyAttack => Sfx.enemyAttack,
      BattleEvent.curse => Sfx.invalid,
      BattleEvent.victory => Sfx.victory,
      BattleEvent.defeat => Sfx.defeat,
    });
  }

  /// Ялсан/ялагдсан бол үлгэрийн урсгалыг үргэлжлүүлнэ.
  void _checkEnd() {
    if (_resultShown || !controller.isOver) return;
    _resultShown = true;
    final c = controller;
    final outcome = BattleOutcome(
      chapter: widget.chapter,
      won: c.status == BattleStatus.won,
      score: c.finalScore,
      stars: c.stars,
      wordsCount: c.wordsCount,
      longestWord: c.longestWord,
    );
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) TaleFlow.finishBattle(context, outcome);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_checkEnd);
    controller.dispose();
    super.dispose();
  }

  Future<void> _confirmExit() async {
    controller.pause();
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Тулаанаас гарах уу?'),
        content: const Text('Энэ тулааны ахиц хадгалагдахгүй.'),
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
        if (!didPop && !controller.isOver) _confirmExit();
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
                Expanded(child: _buildBattleArea()),
                _buildBottomPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Дээд мөр: HP, дайсны дугаар ----------
  Widget _buildTopBar() {
    final c = controller;
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 10),
      child: Row(
        children: [
          GlassIconButton(
            icon: Icons.pause_rounded,
            tooltip: 'Түр зогсоох',
            size: 40,
            onPressed: _confirmExit,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: HpBar(
              current: c.player.hp,
              max: c.player.maxHp,
              color: AppColors.mint,
              label: 'Баатар',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _WaveDots(current: c.waveIndex, total: c.enemies.length),
          ),
          Expanded(
            child: HpBar(
              current: c.enemy.hp,
              max: c.enemy.maxHp,
              color: AppColors.primaryEnd,
              label: c.enemy.name,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Дунд хэсэг: баатар vs дайсан ----------
  Widget _buildBattleArea() {
    final c = controller;
    final isPlayerTurn = c.status == BattleStatus.playerTurn;
    final hurry = isPlayerTurn && c.timeLeft <= 5;
    final msg = c.message;

    return SceneBackground(
      scene: widget.chapter.scene,
      horizon: 0.64,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              opacity: 0.5,
              borderColor: hurry
                  ? AppColors.warning.withValues(alpha: 0.8)
                  : AppColors.inkLine,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPlayerTurn
                        ? 'Таны ээлж · ${c.timeLeft} сек'
                        : _statusText(c.status),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hurry ? AppColors.warning : Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (c.turnsUntilSpecial != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        c.specialIncoming
                            ? '⚠ Дараагийн ээлжинд: ${c.enemy.special.label}!'
                            : '${_specialIcon(c.enemy.special)} ${c.enemy.special.label}: ${c.turnsUntilSpecial} ээлжийн дараа',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: c.specialIncoming
                              ? FontWeight.bold
                              : null,
                          color: c.specialIncoming
                              ? AppColors.danger
                              : Colors.white70,
                        ),
                      ),
                    ),
                  if (msg != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                      child: Text(
                        msg,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Дүрсний хэмжээг үлдсэн зайгаас тооцно — халихгүй.
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final spriteSize = min(
                  box.maxWidth * 0.26,
                  box.maxHeight - 44, // нэрийн самбар + сүүдэр
                ).clamp(40.0, 104.0);
                final showQuote =
                    c.enemyQuote != null && box.maxHeight > spriteSize + 90;
                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              CharacterSprite(
                                art: HeroArt(size: spriteSize),
                                name: 'Баатар',
                                size: spriteSize,
                                attackCount: c.hitCount,
                                hitCount: c.enemyAttackCount,
                                isDead: c.player.isDead,
                                lunge: 30,
                              ),
                              Positioned(
                                top: 0,
                                child: DamagePopup(
                                  event: c.healCount,
                                  amount: c.lastHeal,
                                  heal: true,
                                ),
                              ),
                            ],
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              CharacterSprite(
                                key: ValueKey(c.waveIndex),
                                art: EnemyArt(
                                  kind: c.enemy.kind,
                                  image: c.enemy.image,
                                  size: spriteSize,
                                ),
                                name: c.enemy.name,
                                size: spriteSize,
                                attackCount: c.enemyAttackCount,
                                hitCount: c.hitCount,
                                isDead: c.enemy.isDead,
                                lunge: -30,
                              ),
                              Positioned(
                                top: 0,
                                child: DamagePopup(
                                  event: c.hitCount,
                                  amount: c.lastDamage,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (showQuote)
                      Positioned(
                        right: 12,
                        left: box.maxWidth * 0.3,
                        bottom: spriteSize + 40,
                        child: _SpeechBubble(text: c.enemyQuote!),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _specialIcon(EnemySpecial s) => switch (s) {
    EnemySpecial.strike => '⚡',
    EnemySpecial.curse => '🔒',
    EnemySpecial.heal => '💚',
    EnemySpecial.none => '',
  };

  String _statusText(BattleStatus s) => switch (s) {
    BattleStatus.playerTurn => '',
    BattleStatus.enemyTurn => 'Дайсны ээлж...',
    BattleStatus.enemyDefeated => 'Дайсныг ялав!',
    BattleStatus.won => 'Ялалт!',
    BattleStatus.lost => 'Ялагдал...',
  };

  // ---------- Доод хэсэг: үг, самбар, товчнууд ----------
  Widget _buildBottomPanel() {
    final c = controller;
    final canAttack = c.canAct && c.selected.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.inkSoft,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
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
                    child: WordBar(
                      tiles: c.selected,
                      onTapTile: c.deselectTile,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onLongPress: canAttack ? c.clearSelection : null,
                  child: _SquareAction(
                    icon: Icons.backspace_rounded,
                    tooltip: 'Сүүлийн үсгийг арилгах (удаан дарвал бүгдийг)',
                    onPressed: canAttack ? c.undo : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LetterGrid(tiles: c.board, onTap: c.selectTile),
            const SizedBox(height: 12),
            Row(
              children: [
                _PillAction(
                  icon: Icons.lightbulb,
                  label: '${c.hintsLeft}',
                  tooltip: 'Санамж',
                  onPressed: c.canAct && c.hintsLeft > 0 ? c.hint : null,
                ),
                const SizedBox(width: 6),
                _PillAction(
                  icon: Icons.shuffle_rounded,
                  label: 'Холих',
                  tooltip: 'Бүх үсгийг солих (ээлж алдана)',
                  onPressed: c.canAct ? c.shuffle : null,
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        c.combo > 0
                            ? '🔥${c.combo}  ⚔ ${c.previewDamage}'
                            : '⚔ ${c.previewDamage}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 124,
                  child: GameButton(
                    label: 'Довтлох',
                    icon: Icons.flash_on_rounded,
                    height: 46,
                    onPressed: canAttack ? c.attack : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Дайсны ярианы бөмбөлөг (илгэн цаасан өнгөтэй).
class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.normal,
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.scale(
        scale: t,
        alignment: Alignment.bottomRight,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.parchment,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(3),
          ),
          border: Border.all(color: AppColors.parchmentEdge, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          '“$text”',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.parchmentInk,
            fontSize: 13,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

/// Хэд дэх дайсан болохыг цэгээр (ялсан нь алтан).
class _WaveDots extends StatelessWidget {
  const _WaveDots({required this.current, required this.total});

  final int current; // 0-ээс эхэлсэн
  final int total;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Дайсан ${current + 1}/$total',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${current + 1}/$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < total; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < current
                        ? AppColors.accent
                        : i == current
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Самбарын дөрвөлжин товч.
class _SquareAction extends StatelessWidget {
  const _SquareAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
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
    );
  }
}

/// Санамж / Холих — тунгалаг pill товч.
class _PillAction extends StatelessWidget {
  const _PillAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        backgroundColor: AppColors.glass,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.06),
        disabledForegroundColor: Colors.white30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 46),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
