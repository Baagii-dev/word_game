import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../wallet/firestore_wallet_cloud.dart';
import '../wallet/wallet_service.dart';
import 'local_online_service.dart';
import 'online_models.dart';
import 'online_service.dart';

/// Онлайн боломж ашиглахад ник шаардана. Нэвтэрсэн бол шууд буцаана,
/// үгүй бол ник асууж нэвтрүүлээд, өмнөх тоглолтын дүнг жагсаалтад оруулна.
/// Цуцалбал `null`.
Future<PlayerProfile?> ensureProfile(BuildContext context) async {
  final service = OnlineServices.current;
  final existing = service.profile;
  if (existing != null) return existing;

  final saved = SettingsService.instance.nickname;
  final name = await showDialog<String>(
    context: context,
    builder: (_) => _NicknameDialog(initial: saved),
  );
  if (name == null || name.trim().isEmpty) return null;

  PlayerProfile profile;
  var activeService = service;
  try {
    profile = await service.signIn(name);
  } catch (e) {
    // Онлайн холбогдож чадсангүй (интернэт/Firebase) → офлайн демо горимд шилжинэ
    final local = LocalOnlineService();
    OnlineServices.use(local);
    activeService = local;
    profile = await local.signIn(name);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Онлайнд холбогдож чадсангүй — офлайн демо горимоор үргэлжилнэ',
          ),
        ),
      );
    }
  }
  await SettingsService.instance.setNickname(profile.name);
  if (activeService.isOnline) {
    await WalletService.instance.attachCloud(
      FirestoreWalletCloud(),
      profile.uid,
    );
  }

  // Өмнө нь тоглосон дүнг жагсаалтад оруулна
  final history = StorageService.instance.progress.history;
  if (history.isNotEmpty) {
    await activeService.syncHistory(
      totalScore: history.fold(0, (s, r) => s + r.score),
      wins: history.where((r) => r.won).length,
      bestScore: history.fold(0, (m, r) => r.score > m ? r.score : m),
    );
  }
  return profile;
}

class _NicknameDialog extends StatefulWidget {
  const _NicknameDialog({required this.initial});

  final String initial;

  @override
  State<_NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<_NicknameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _controller.text.trim();
    if (v.length >= 2) Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ник нэрээ оруулна уу'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 16,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'Жишээ: Баатар'),
          ),
          const Text(
            'Онооны жагсаалтад зөвхөн ник харагдана.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Болих'),
        ),
        FilledButton(
          onPressed: _controller.text.trim().length >= 2 ? _submit : null,
          child: const Text('Үргэлжлүүлэх'),
        ),
      ],
    );
  }
}
