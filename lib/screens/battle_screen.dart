import 'dart:math';

import 'package:flutter/material.dart';

import '../design/characters/character_sprite.dart';
import '../design/characters/enemy_art.dart';
import '../design/characters/hero_art.dart';
import '../design/glass.dart';
import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../logic/battle_controller.dart';
import '../models/level.dart';
import '../services/audio_service.dart';
import '../services/dictionary_service.dart';
import '../widgets/damage_popup.dart';
import '../widgets/game_button.dart';
import '../widgets/hp_bar.dart';
import '../widgets/letter_grid.dart';
import '../widgets/shake_widget.dart';
import '../widgets/wave_indicator.dart';
import '../widgets/word_bar.dart';
import 'result_screen.dart';

/// Үндсэн тулааны дэлгэц.
/// Тоглоомын дүрэм BattleController-т, энд зөвхөн харуулах хэсэг.
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.level});

  final Level level;

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
            level: widget.level,
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
      BattleEvent.invalid => Sfx.invalid,
      BattleEvent.enemyAttack => Sfx.enemyAttack,
      BattleEvent.victory => Sfx.victory,
      BattleEvent.defeat => Sfx.defeat,
    });
  }

  /// Ялсан/ялагдсан бол үр дүнгийн дэлгэц рүү шилжинэ.
  void _checkEnd() {
    if (_resultShown) return;
    final s = controller.status;
    if (s != BattleStatus.won && s != BattleStatus.lost) return;

    _resultShown = true;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            level: widget.level,
            won: s == BattleStatus.won,
            score: controller.finalScore,
            stars: controller.stars,
            wordsCount: controller.wordsCount,
            longestWord: controller.longestWord,
          ),
        ),
      );
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
            child: const Text('Үгүй'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Тийм'),
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
    return Scaffold(
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
    );
  }

  // ---------- Дээд мөр: HP, wave ----------
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
              label: 'Таны амь',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: WaveIndicator(
              current: c.waveIndex + 1,
              total: c.enemies.length,
            ),
          ),
          Expanded(
            child: HpBar(
              current: c.enemy.hp,
              max: c.enemy.maxHp,
              color: AppColors.primaryEnd,
              label: 'Дайсны амь',
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

    return SteppeBackground(
      horizon: 0.62,
      showGer: widget.level.id == 1,
      showClouds: true,
      levelId: widget.level.id,
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
                            ? '⚠ Дайсан дараагийн ээлжинд хүчтэй цохино!'
                            : '⚡ Хүчтэй цохилт: ${c.turnsUntilSpecial} ээлжийн дараа',
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
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Text(
                        msg,
                        textAlign: TextAlign.center,
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
          // Дүрсний хэмжээг үлдсэн зайгаас тооцно — мессежийн самбар хэдэн
          // мөр болсноос үл хамаарч халихгүй.
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final spriteSize = min(
                  box.maxWidth * 0.26,
                  box.maxHeight - 44, // нэрийн самбар + сүүдэр
                ).clamp(40.0, 104.0);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          CharacterSprite(
                            key: ValueKey(c.waveIndex),
                            art: EnemyArt(
                              emoji: c.enemy.emoji,
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
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Жижиг бариул зураас — доод самбар гэдгийг илтгэнэ
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              10,
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
                    _SquareAction(
                      icon: Icons.backspace_rounded,
                      tooltip: 'Арилгах',
                      onPressed: canAttack ? c.clearSelection : null,
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
                      onPressed: c.canAct && c.hintsLeft > 0 ? c.hint : null,
                    ),
                    const SizedBox(width: 6),
                    _PillAction(
                      icon: Icons.shuffle_rounded,
                      label: 'Холих',
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
        ],
      ),
    );
  }
}

/// Самбарын дөрвөлжин товч (бүх үсгийг арилгах).
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
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
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
  }
}
