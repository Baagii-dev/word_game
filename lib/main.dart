import 'package:flutter/material.dart';

import 'app.dart';
import 'models/level.dart';
import 'services/dictionary_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DictionaryService.instance.load();
  await loadLevels();
  await StorageService.instance.load();

  runApp(const WordBattleApp());
}
