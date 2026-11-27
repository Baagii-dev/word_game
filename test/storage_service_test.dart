import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_battle/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Ахиц ба түүх хадгалагдаж, дахин ачаалахад сэргэнэ', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService.instance;
    await storage.load();
    await storage.saveResult(
      chapterId: 1,
      chapterTitle: 'Хулгана тэмээ хоёр',
      won: true,
      score: 120,
      stars: 2,
      wordsCount: 4,
      longestWord: 'цагаан',
    );

    storage.progress.bestScores.clear();
    await storage.load();

    expect(storage.progress.bestScores[1], 120);
    expect(storage.progress.stars[1], 2);
    expect(storage.progress.unlockedChapter, 2);
    expect(storage.progress.history, isNotEmpty);
    expect(storage.progress.history.first.chapterTitle, 'Хулгана тэмээ хоёр');
    expect(storage.progress.history.first.longestWord, 'цагаан');

    await storage.clearHistory();
    expect(storage.progress.history, isEmpty);

    // Ялагдал дараагийн үлгэрийг нээхгүй
    await storage.saveResult(
      chapterId: 2,
      chapterTitle: 'Эрхий мэргэн',
      won: false,
      score: 10,
      stars: 0,
    );
    expect(storage.progress.unlockedChapter, 2);

    await storage.resetAll();
    expect(storage.progress.unlockedChapter, 1);
    expect(storage.progress.totalStars, 0);
  });
}
