import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_battle/wallet/payment_service.dart';
import 'package:word_battle/wallet/wallet_models.dart';
import 'package:word_battle/wallet/wallet_service.dart';

class _FakeCloud implements WalletCloud {
  Map<String, dynamic>? stored;
  int saves = 0;

  @override
  Future<Map<String, dynamic>?> load(String uid) async => stored;

  @override
  Future<void> save(String uid, Map<String, dynamic> data) async {
    stored = Map<String, dynamic>.from(data);
    saves++;
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<WalletService> fresh() async {
    final w = WalletService();
    await w.load();
    return w;
  }

  group('Түрийвч', () {
    test(
      'Анх нээхэд угтах бэлэг өгнө, дахин ачаалахад давтан өгөхгүй',
      () async {
        final w = await fresh();
        expect(w.coins, WalletService.welcomeCoins);
        expect(w.history.single.label, 'Угтах бэлэг');
        expect(w.heroEmoji, '🏇');

        final again = await fresh(); // ижил prefs-ээс
        expect(again.coins, WalletService.welcomeCoins);
        expect(again.history.length, 1);
      },
    );

    test('earn: coin нэмэгдэж, гүйлгээ бүртгэгдэж, хадгалагдана', () async {
      final w = await fresh();
      await w.earn(25, 'Ялалт');
      await w.earn(0, 'үл тоомсорлоно');
      expect(w.coins, 75);
      expect(w.history.first.amount, 25);
      expect((await fresh()).coins, 75);
    });

    test('Шагналын томьёо', () {
      expect(WalletService.battleReward(won: true, stars: 3), 25);
      expect(WalletService.battleReward(won: true, stars: 1), 15);
      expect(WalletService.battleReward(won: false, stars: 0), 2);
      expect(WalletService.duelReward(won: true), 25);
      expect(WalletService.duelReward(won: false), 5);
    });

    test('Бэлтгэл авах: coin хүрэхгүй бол татгалзана', () async {
      final w = await fresh(); // 50 coin
      final hp = shopItemById('boost_hp')!; // 50
      final skin = shopItemById('skin_wolf')!; // 150
      expect(await w.buyItem(skin), PurchaseOutcome.notEnoughCoins);
      expect(w.coins, 50);

      expect(await w.buyItem(hp), PurchaseOutcome.ok);
      expect(w.coins, 0);
      expect(w.count('boost_hp'), 1);
      expect(await w.buyItem(hp), PurchaseOutcome.notEnoughCoins);
    });

    test('Баатрын дүр: авч, сонгоно; давхар авч болохгүй; эзэмшээгүйг сонгож болохгүй', () async {
      final w = await fresh();
      await w.earn(200, 'тест');
      final eagle = shopItemById('skin_eagle')!;
      expect(await w.equip(eagle.id), isFalse);
      expect(await w.buyItem(eagle), PurchaseOutcome.ok);
      expect(await w.buyItem(eagle), PurchaseOutcome.alreadyOwned);
      expect(w.coins, 150);
      expect(await w.equip(eagle.id), isTrue);
      expect(w.heroEmoji, '🦅');

      final back = await fresh(); // сонголт хадгалагдсан
      expect(back.heroEmoji, '🦅');
      expect(back.ownedSkins, contains('skin_eagle'));
    });

    test('Тулааны бэлтгэл: нэг удаа ашиглагдаж, нөлөөг нийлүүлнэ', () async {
      final w = await fresh();
      await w.earn(200, 'тест');
      await w.buyItem(shopItemById('boost_hints')!);
      await w.buyItem(shopItemById('boost_time')!);
      await w.buyItem(shopItemById('boost_time')!);
      await w.buyItem(shopItemById('boost_hp')!);

      final b = w.consumeBattleBonuses();
      expect(b.extraHints, 3);
      expect(b.extraSeconds, 10); // нэг тулаанд цагийн эрчийн нэгийг л ашиглана
      expect(b.extraHp, 10);
      expect(w.count('boost_time'), 1);
      expect(w.count('boost_hints'), 0);
      expect(b.describe(), contains('+10 амь'));

      final next = w.consumeBattleBonuses();
      expect(next.extraSeconds, 10);
      expect(next.extraHp, 0);
      expect(w.consumeBattleBonuses().isEmpty, isTrue);
    });

    test('Хоосон бэлтгэл тайлбар хоосон', () {
      expect(BattleBonuses.none.describe(), '');
    });
  });

  group('Төлбөр (туршилтын)', () {
    test(
      'Амжилттай төлбөр: coin нэмэгдэж, гүйлгээний дугаартай бүртгэгдэнэ',
      () {
        fakeAsync((async) {
          final w = WalletService();
          w.load();
          async.flushMicrotasks();
          final pay = MockPaymentService(delay: const Duration(seconds: 2));
          PaymentResult? result;
          w.buyCoins(kCoinPacks[1], pay).then((r) => result = r);

          async.elapse(const Duration(seconds: 1));
          expect(result, isNull); // боловсруулж байна
          expect(w.coins, 50);

          async.elapse(const Duration(seconds: 2));
          async.flushMicrotasks();
          expect(result!.success, isTrue);
          expect(w.coins, 50 + 550);
          expect(w.history.first.type, TransactionType.purchase);
          expect(w.history.first.reference, startsWith('TEST-'));
        });
      },
    );

    test('Амжилтгүй төлбөр: coin өөрчлөгдөхгүй', () async {
      final w = await fresh();
      final pay = MockPaymentService(delay: Duration.zero, failNext: true);
      final r = await w.buyCoins(kCoinPacks[0], pay);
      expect(r.success, isFalse);
      expect(r.error, isNotEmpty);
      expect(w.coins, 50);
      expect(w.history.length, 1);

      // Дараагийн оролдлого амжилттай
      expect((await w.buyCoins(kCoinPacks[0], pay)).success, isTrue);
      expect(w.coins, 150);
    });

    test('Буруу дүнтэй төлбөр татгалзана', () async {
      final r = await MockPaymentService(delay: Duration.zero)
          .charge(amountMnt: 0, description: 'x');
      expect(r.success, isFalse);
    });
  });

  group('Үүлэн хуулбар', () {
    test('Шинэ тохиргоог үүлэнд хадгалж, өөрчлөлт бүрт шинэчилнэ', () async {
      final w = await fresh();
      final cloud = _FakeCloud();
      await w.attachCloud(cloud, 'u1');
      expect(cloud.stored?['coins'], 50);

      await w.earn(10, 'тест');
      await Future<void>.delayed(Duration.zero);
      expect(cloud.stored?['coins'], 60);
    });

    test('Үүлэн дэх шинэ хувилбарыг (өөр төхөөрөмж) авна', () async {
      final w = await fresh();
      final cloud = _FakeCloud()
        ..stored = {
          'coins': 999,
          'inventory': {'boost_hp': 2},
          'ownedSkins': ['skin_rider', 'skin_wolf'],
          'equippedSkin': 'skin_wolf',
          'history': [],
          'updatedAt': DateTime.now().millisecondsSinceEpoch + 100000,
        };
      await w.attachCloud(cloud, 'u1');
      expect(w.coins, 999);
      expect(w.count('boost_hp'), 2);
      expect(w.heroEmoji, '🐺');
    });

    test(
      'Үүлэн дэх хуучин хувилбар төхөөрөмжийн шинэ өгөгдлийг дарахгүй',
      () async {
        final w = await fresh();
        await w.earn(70, 'тест'); // 120 coin
        final cloud = _FakeCloud()..stored = {'coins': 1, 'updatedAt': 1};
        await w.attachCloud(cloud, 'u1');
        expect(w.coins, 120);
        expect(cloud.stored?['coins'], 120);
      },
    );
  });
}
