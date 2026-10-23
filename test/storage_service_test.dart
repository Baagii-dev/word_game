import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_battle/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Ахиц хадгалагдаж, дахин ачаалахад сэргэнэ', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService.instance;
    await storage.saveResult(levelId: 1, score: 120, stars: 2);

    storage.progress.bestScores.clear();
    await storage.load();

    expect(storage.progress.bestScores[1], 120);
    expect(storage.progress.stars[1], 2);
    expect(storage.progress.unlockedLevel, 2);
  });
}
