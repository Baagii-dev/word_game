import 'package:flutter/material.dart';

import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../online/nickname_dialog.dart';
import '../online/online_models.dart';
import '../online/online_service.dart';
import '../widgets/game_button.dart';
import 'duel_screen.dart';

/// Онлайн 1v1: ник авч, өрсөлдөгч хайгаад тулаан руу шилжинэ.
class DuelLobbyScreen extends StatefulWidget {
  const DuelLobbyScreen({super.key});

  @override
  State<DuelLobbyScreen> createState() => _DuelLobbyScreenState();
}

class _DuelLobbyScreenState extends State<DuelLobbyScreen> {
  DuelSearch? _search;
  String? _error;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    setState(() => _error = null);
    final profile = await ensureProfile(context);
    if (!mounted) return;
    if (profile == null) {
      Navigator.pop(context); // ник өгөөгүй
      return;
    }
    try {
      final search = OnlineServices.current.findDuel();
      _search = search;
      final session = await search.result;
      if (!mounted || _leaving || session == null) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DuelScreen(session: session)),
      );
    } catch (e) {
      if (mounted) setState(() => _error = 'Өрсөлдөгч хайж чадсангүй: $e');
    }
  }

  void _cancel() {
    _leaving = true;
    _search?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _leaving = true;
    _search?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = OnlineServices.current;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: SteppeBackground(horizon: 0.78)),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚔️', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 8),
                        Text(
                          _error == null
                              ? 'Өрсөлдөгч хайж байна…'
                              : 'Алдаа гарлаа',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _error ??
                              '${service.modeLabel} · хоёр тоглогч ижил үсгээр эхэлж, '
                                  'өрсөлдөгчийн амийг түрүүлж тэглэсэн нь ялна.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        if (_error == null)
                          const CircularProgressIndicator()
                        else
                          GameButton(
                            label: 'Дахин оролдох',
                            color: AppColors.red,
                            onPressed: _start,
                          ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _cancel,
                          child: const Text('Цуцлах'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
