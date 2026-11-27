import 'package:flutter/material.dart';

import 'app.dart';
import 'models/chapter.dart';
import 'services/dictionary_service.dart';
import 'services/settings_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    DictionaryService.instance.load(),
    loadChapters(),
    StorageService.instance.load(),
    SettingsService.instance.load(),
  ]);

  runApp(const TaleHeroApp());
}
