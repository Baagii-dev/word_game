import 'package:flutter/material.dart';

import '../design/characters/character_sprite.dart';
import '../design/characters/enemy_art.dart';
import '../design/characters/hero_art.dart';
import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../online/duel_controller.dart';
import '../online/online_models.dart';
import '../online/online_service.dart';
import '../services/audio_service.dart';
import '../services/dictionary_service.dart';
import '../wallet/wallet_service.dart';
import '../widgets/damage_popup.dart';
import '../widgets/hp_bar.dart';
import '../widgets/word_panel.dart';
import 'duel_lobby_screen.dart';

/// Онлайн 1v1 тулаан: хоёр тоглогч ээлжгүйгээр зэрэг үг бүтээж,
/// өрсөлдөгчийн амийг түрүүлж тэглэсэн нь ялна (эсвэл хугацаа дуусахад амь нь олон нь).
class DuelScreen extends StatefulWidget {
  const DuelScreen({super.key, required this.session});

  final DuelSession session;

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> {
  late final DuelController controller;
  bool _resultShown = false;
  int _reward = 0;
  int _lastHits = 0;
  int _lastOppHits = 0;

  static const _opponentEmoji = ['🥷', '🧙', '🤺', '👺', '🧛'];

  @override
  void initState() {
    super.initState();
    controller = DuelController(
      session: widget.session,
      dictionary: DictionaryService.instance,
    )..addListener(_onChange);
  }

  void _onChange() {
    final c = controller;
    if (c.hitCount != _lastHits) {
      _lastHits = c.hitCount;
      AudioService.instance.play(Sfx.hit);
    }
    if (c.snapshot.opponentHits != _lastOppHits) {
      _lastOppHits = c.snapshot.opponentHits;
      AudioService.instance.play(Sfx.enemyAttack);
    }
    if (c.snapshot.finished && !_resultShown) {
      _resultShown = true;
      final s = c.snapshot;
      AudioService.instance.play(s.iWon ? Sfx.victory : Sfx.defeat);
      _reward = WalletService.duelReward(won: s.iWon);
      WalletService.instance.earn(
        _reward,
        '1v1 тулаан: ${s.iWon ? 'ялалт' : 'оролдлого'}',
      );
      if (OnlineServices.isReady) {
        OnlineServices.current
            .submitDuelResult(won: s.iWon, score: c.finalScore)
            .catchError((_) {});
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _showResult());
    }
  }

  Future<void> _showResult() async {
    if (!mounted) return;
    final c = controller;
    final s = c.snapshot;
    final title = s.iWon ? 'Ялалт! 🏆' : (s.draw ? 'Тэнцлээ 🤝' : 'Ялагдал 💀');
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Өрсөлдөгч: ${s.opponentName}'),
            const SizedBox(height: 8),
            Text('Таны амь: ${s.myHp}/${s.maxHp}'),
            Text('Өрсөлдөгчийн амь: ${s.opponentHp}/${s.maxHp}'),
            const SizedBox(height: 8),
            Text('Бүтээсэн үг: ${c.wordsCount}'),
            Text('Шагнал: +$_reward 🪙'),
            Text(
              'Тулааны оноо: ${c.finalScore}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'exit'),
            child: const Text('Гарах'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'again'),
            child: const Text('Дахин тоглох'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'again') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DuelLobbyScreen()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmExit() async {
    if (controller.snapshot.finished) {
      Navigator.pop(context);
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Тулаанаас гарах уу?'),
        content: const Text('Гарвал өрсөлдөгч ялна.'),
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
      await controller.leave();
      // Ялагдлын цонх ( _showResult ) өөрөө гаргана.
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onChange);
    controller.dispose();
    super.dispose();
  }

  String _emojiFor(String name) =>
      _opponentEmoji[name.codeUnits.fold(0, (a, b) => a + b) %
          _opponentEmoji.length];

  String _clock(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final c = controller;
            return Column(
              children: [
                _topBar(c),
                Expanded(child: _arena(c)),
                WordPanel(
                  board: c.board,
                  selected: c.selected,
                  enabled: c.canAct,
                  combo: c.combo,
                  previewDamage: c.previewDamage,
                  invalidCount: c.invalidCount,
                  onSelect: c.selectTile,
                  onDeselect: c.deselectTile,
                  onClear: c.clearSelection,
                  onShuffle: c.shuffle,
                  onAttack: c.attack,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topBar(DuelController c) {
    final s = c.snapshot;
    final hurry = c.timeLeft <= 10 && !s.finished;
    Widget side(String name, int hp, Color color, CrossAxisAlignment align) =>
        Expanded(
          child: Column(
            crossAxisAlignment: align,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              HpBar(current: hp, max: s.maxHp, color: color),
            ],
          ),
        );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.navyDeep, AppColors.navyDark],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _confirmExit,
            icon: const Icon(
              Icons.flag_circle,
              size: 34,
              color: AppColors.accent,
            ),
          ),
          side('Та', s.myHp, AppColors.playerHp, CrossAxisAlignment.start),
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.navyDark,
              border: Border.all(
                color: hurry ? AppColors.warning : AppColors.accent,
                width: 3,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _clock(c.timeLeft),
              style: TextStyle(
                color: hurry ? AppColors.warning : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          side(
            s.opponentName,
            s.opponentHp,
            AppColors.enemyHp,
            CrossAxisAlignment.end,
          ),
        ],
      ),
    );
  }

  Widget _arena(DuelController c) {
    final s = c.snapshot;
    final msg = c.message;
    return SteppeBackground(
      horizon: 0.62,
      showGer: false,
      child: Column(
        children: [
          const SizedBox(height: 8),
          if (msg != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.navyDeep.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.65),
                ),
              ),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final size = (box.maxHeight - 44).clamp(40.0, 96.0);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CharacterSprite(
                        art: HeroArt(size: size),
                        name: 'Та',
                        size: size,
                        attackCount: c.hitCount,
                        hitCount: s.opponentHits,
                        isDead: s.finished && !s.iWon && !s.draw,
                        lunge: 30,
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          CharacterSprite(
                            art: EnemyArt(
                              emoji: _emojiFor(s.opponentName),
                              size: size,
                            ),
                            name: s.opponentName,
                            size: size,
                            attackCount: s.opponentHits,
                            hitCount: c.hitCount,
                            isDead: s.finished && s.iWon,
                            lunge: -30,
                          ),
                          Positioned(
                            top: 0,
                            child: DamagePopup(
                              event: c.hitCount,
                              amount: c.hitCount == 0 ? null : c.lastDamage,
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
}
