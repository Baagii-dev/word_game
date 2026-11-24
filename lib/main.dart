import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'models/level.dart';
import 'online/firebase_online_service.dart';
import 'online/local_online_service.dart';
import 'online/online_service.dart';
import 'services/dictionary_service.dart';
import 'services/settings_service.dart';
import 'services/storage_service.dart';
import 'wallet/firestore_wallet_cloud.dart';
import 'wallet/wallet_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DictionaryService.instance.load();
  await loadLevels();
  await StorageService.instance.load();
  await SettingsService.instance.load();

  await WalletService.instance.load();
  await _setupOnline();

  runApp(const WordBattleApp());
}

/// Онлайн үйлчилгээг сонгоно: Firebase амжилттай эхэлбэл онлайн,
/// эс бөгөөс (тохиргоо дутуу, интернэтгүй) санах ойн офлайн демо горим.
Future<void> _setupOnline() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    OnlineServices.use(FirebaseOnlineService());
  } catch (e) {
    debugPrint('Firebase эхлээгүй, офлайн горимд ажиллана: $e');
    OnlineServices.use(LocalOnlineService());
  }

  final nick = SettingsService.instance.nickname;
  if (nick.isNotEmpty) {
    try {
      final profile = await OnlineServices.current.signIn(nick);
      if (OnlineServices.current.isOnline) {
        await WalletService.instance.attachCloud(
          FirestoreWalletCloud(),
          profile.uid,
        );
      }
    } catch (e) {
      debugPrint('Онлайн нэвтрэлт амжилтгүй, офлайн горимд шилжив: $e');
      final local = LocalOnlineService();
      OnlineServices.use(local);
      await local.signIn(nick);
    }
  }
}
