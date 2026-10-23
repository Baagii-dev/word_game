import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../logic/battle_controller.dart';
import '../models/level.dart';
import '../services/dictionary_service.dart';
import '../services/audio_service.dart';
import '../widgets/character_sprite.dart';
import '../widgets/damage_popup.dart';
import '../widgets/shake_widget.dart';
import '../widgets/hp_bar.dart';
import '../widgets/letter_grid.dart';
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
      body: SafeArea(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _confirmExit,
            icon: const Icon(
              Icons.pause_circle_filled,
              size: 34,
              color: AppColors.woodDark,
            ),
          ),
          Expanded(
            child: HpBar(
              current: c.player.hp,
              max: c.player.maxHp,
              color: AppColors.playerHp,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: WaveIndicator(
              current: c.waveIndex + 1,
              total: c.enemies.length,
            ),
          ),
          Expanded(
            child: HpBar(
              current: c.enemy.hp,
              max: c.enemy.maxHp,
              color: AppColors.enemyHp,
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

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.sky, AppColors.sky, AppColors.grass],
          stops: [0, 0.6, 0.6],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            isPlayerTurn
                ? 'Таны ээлж · ${c.timeLeft} сек'
                : _statusText(c.status),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: hurry ? Colors.red : AppColors.text,
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
                  fontWeight: c.specialIncoming ? FontWeight.bold : null,
                  color: c.specialIncoming ? Colors.red : AppColors.text,
                ),
              ),
            ),
          if (c.message != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                c.message!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.text),
              ),
            ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CharacterSprite(
                emoji: '🧙',
                name: 'Баатар',
                isHit: c.status == BattleStatus.enemyTurn,
              ),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  CharacterSprite(
                    emoji: c.enemy.emoji,
                    name: c.enemy.name,
                    isHit: c.lastDamage != null && !isPlayerTurn,
                    isDead: c.enemy.isDead,
                  ),
                  Positioned(
                    top: 0,
                    child: DamagePopup(event: c.hitCount, amount: c.lastDamage),
                  ),
                ],
              ),
            ],
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
      padding: const EdgeInsets.all(10),
      color: AppColors.wood,
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
              IconButton.filled(
                onPressed: canAttack ? c.clearSelection : null,
                icon: const Icon(Icons.backspace),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LetterGrid(tiles: c.board, onTap: c.selectTile),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: c.canAct && c.hintsLeft > 0 ? c.hint : null,
                icon: const Icon(Icons.lightbulb),
                label: Text('${c.hintsLeft}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: c.canAct ? c.shuffle : null,
                icon: const Icon(Icons.shuffle),
                label: const Text('Холих'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    c.combo > 0
                        ? '🔥${c.combo}  ⚔ ${c.previewDamage}'
                        : '⚔ ${c.previewDamage}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: canAttack ? c.attack : null,
                icon: const Icon(Icons.flash_on),
                label: const Text('Довтлох'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.text,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
