import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_battle/design/theme.dart';
import 'package:word_battle/screens/home_screen.dart';
import 'package:word_battle/screens/shop_screen.dart';
import 'package:word_battle/wallet/payment_service.dart';
import 'package:word_battle/wallet/wallet_models.dart';
import 'package:word_battle/wallet/wallet_service.dart';

void main() {
  const sizes = [Size(320, 568), Size(375, 667), Size(412, 915)];

  late WalletService wallet;
  late MockPaymentService payment;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    wallet = WalletService();
    await wallet.load();
    payment = MockPaymentService(delay: const Duration(milliseconds: 100));
  });

  Future<void> pumpAt(WidgetTester t, Size size, Widget home) async {
    t.view.physicalSize = size * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: home));
    await t.pump(const Duration(milliseconds: 200));
  }

  void noVerticalOverflow(WidgetTester t, String where) {
    final e = t.takeException();
    if (e == null) return;
    expect(e.toString(), isNot(contains('on the bottom')), reason: where);
  }

  for (final size in sizes) {
    testWidgets(
      'Дэлгүүр халахгүй (${size.width.toInt()}x${size.height.toInt()})',
      (t) async {
        await pumpAt(t, size, ShopScreen(wallet: wallet, payment: payment));
        expect(find.byKey(const Key('coins')), findsOneWidget);
        expect(
          (t.widget(find.byKey(const Key('coins'))) as Text).data,
          '🪙 50',
        );
        expect(find.text('Санамжийн багц'), findsOneWidget);
        noVerticalOverflow(t, 'дэлгүүр');
      },
    );
  }

  testWidgets('Бэлтгэл авахад coin хасагдаж, гүйлгээний түүхэд орно', (
    t,
  ) async {
    await pumpAt(
      t,
      const Size(375, 667),
      ShopScreen(wallet: wallet, payment: payment),
    );
    await t.tap(find.text('🪙 30').first); // Санамжийн багц
    await t.pump(const Duration(milliseconds: 300));
    expect(wallet.coins, 20);
    expect(wallet.count('boost_hints'), 1);
    expect((t.widget(find.byKey(const Key('coins'))) as Text).data, '🪙 20');
    expect(find.text('Санамжийн багц авлаа'), findsOneWidget);
  });

  testWidgets('Coin хүрэхгүй бол татгалзана', (t) async {
    await pumpAt(
      t,
      const Size(400, 3200),
      ShopScreen(wallet: wallet, payment: payment),
    );
    await t.scrollUntilVisible(
      find.text('🪙 150'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await t.drag(
      find.byType(ListView),
      const Offset(0, -150),
    ); // ирмэгээс холдуулна
    await t.pump();
    await t.tap(find.text('🪙 150'));
    await t.pump(const Duration(milliseconds: 300));
    expect(wallet.coins, 50);
    expect(find.text('Coin хүрэлцэхгүй байна'), findsOneWidget);
  });

  testWidgets('Баатрын дүр авч, сонгоно', (t) async {
    await wallet.earn(100, 'тест'); // 150
    await pumpAt(
      t,
      const Size(400, 3200),
      ShopScreen(wallet: wallet, payment: payment),
    );
    await t.scrollUntilVisible(
      find.text('🪙 100'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await t.drag(
      find.byType(ListView),
      const Offset(0, -150),
    ); // ирмэгээс холдуулна
    await t.pump();
    await t.tap(find.text('🪙 100')); // Бүргэд
    await t.pump(const Duration(milliseconds: 300));
    expect(wallet.ownedSkins, contains('skin_eagle'));
    await t.pump(const Duration(seconds: 3)); // snackbar арилна
    await t.tap(find.text('Сонгох').first);
    await t.pump();
    expect(wallet.heroEmoji, '🦅');
  });

  testWidgets('Туршилтын төлбөр: баталгаажуулах → боловсруулах → амжилттай', (
    t,
  ) async {
    await pumpAt(
      t,
      const Size(375, 667),
      ShopScreen(wallet: wallet, payment: payment),
    );
    final buy = find.byKey(const Key('buy_pack_s'));
    await t.scrollUntilVisible(
      buy,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(buy);
    await t.pumpAndSettle();
    expect(find.textContaining('Төлбөр баталгаажуулах'), findsOneWidget);
    expect(
      find.textContaining('Туршилтын төлбөр'),
      findsOneWidget,
    ); // тест горимын анхааруулга
    expect(find.textContaining('₮1,000'), findsWidgets);

    await t.tap(find.text('Төлөх ₮1,000'));
    await t.pump(const Duration(milliseconds: 20));
    expect(find.text('Боловсруулж байна…'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Төлбөр амжилттай'), findsOneWidget);
    expect(wallet.coins, 150);
    expect(wallet.history.first.type, TransactionType.purchase);

    await t.tap(find.text('Хаах'));
    await t.pumpAndSettle();
    expect(wallet.coins, 150);
  });

  testWidgets(
    'Төлбөр амжилтгүй болбол coin өөрчлөгдөхгүй, дахин оролдож болно',
    (t) async {
      payment.failNext = true;
      await pumpAt(
        t,
        const Size(375, 667),
        ShopScreen(wallet: wallet, payment: payment),
      );
      final buy = find.byKey(const Key('buy_pack_s'));
      await t.scrollUntilVisible(
        buy,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(buy);
      await t.pumpAndSettle();
      await t.tap(find.text('Төлөх ₮1,000'));
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Төлбөр амжилтгүй'), findsOneWidget);
      expect(wallet.coins, 50);

      await t.tap(find.text('Дахин оролдох'));
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Төлбөр амжилттай'), findsOneWidget);
      expect(wallet.coins, 150);
    },
  );

  testWidgets('Нүүр дэлгэцэд coin ба Дэлгүүр товч харагдана', (t) async {
    await WalletService.instance.load();
    await pumpAt(t, const Size(375, 667), const HomeScreen());
    expect(find.byKey(const Key('home_coins')), findsOneWidget);
    expect(find.text('Дэлгүүр'), findsOneWidget);
    noVerticalOverflow(t, 'нүүр');
  });
}
