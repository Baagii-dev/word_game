import 'package:flutter/material.dart';

import '../design/ornament_strip.dart';
import '../design/steppe_background.dart';
import '../design/theme.dart';
import '../wallet/checkout_dialog.dart';
import '../wallet/payment_service.dart';
import '../wallet/wallet_models.dart';
import '../wallet/wallet_service.dart';

/// Дэлгүүр: бэлтгэл, баатрын дүр (coin-оор), coin худалдан авах (туршилтын
/// төлбөрөөр), гүйлгээний түүх.
class ShopScreen extends StatelessWidget {
  ShopScreen({super.key, WalletService? wallet, PaymentService? payment})
    : wallet = wallet ?? WalletService.instance,
      payment = payment ?? MockPaymentService();

  final WalletService wallet;
  final PaymentService payment;

  Future<void> _buy(BuildContext context, ShopItem item) async {
    final outcome = await wallet.buyItem(item);
    if (!context.mounted) return;
    final msg = switch (outcome) {
      PurchaseOutcome.ok => '${item.title} авлаа',
      PurchaseOutcome.notEnoughCoins => 'Coin хүрэлцэхгүй байна',
      PurchaseOutcome.alreadyOwned => 'Аль хэдийн эзэмшиж байна',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
  }

  String _date(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.month}/${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.accentLight : AppColors.navyDeep;

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          color: AppColors.accentLight,
          shadows: const [Shadow(color: AppColors.navyDeep, blurRadius: 6)],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дэлгүүр'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(18),
          child: OrnamentStrip(height: 18),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SteppeBackground(horizon: 0.82)),
          ListenableBuilder(
            listenable: wallet,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          wallet.heroEmoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Таны түрийвч',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '🪙 ${wallet.coins}',
                                key: const Key('coins'),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                section('🎒 Бэлтгэл (дараагийн тулаанд)'),
                for (final item in kShopItems.where(
                  (i) => i.kind == ShopItemKind.consumable,
                ))
                  _ItemCard(
                    item: item,
                    titleColor: titleColor,
                    badge: wallet.count(item.id) > 0
                        ? '×${wallet.count(item.id)}'
                        : null,
                    action: FilledButton(
                      onPressed: () => _buy(context, item),
                      child: Text('🪙 ${item.price}'),
                    ),
                  ),
                section('🧙 Баатрын дүр'),
                for (final item in kShopItems.where(
                  (i) => i.kind == ShopItemKind.skin,
                ))
                  _ItemCard(
                    item: item,
                    titleColor: titleColor,
                    action: _skinAction(context, item),
                  ),
                section('🪙 Coin авах (туршилтын төлбөр)'),
                for (final pack in kCoinPacks)
                  Card(
                    child: ListTile(
                      leading: const Text('💰', style: TextStyle(fontSize: 28)),
                      title: Text(
                        '${pack.coins} coin',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      subtitle: Text('₮${pack.priceMnt}'),
                      trailing: FilledButton(
                        key: Key('buy_${pack.id}'),
                        onPressed: () => showCheckoutDialog(
                          context,
                          pack: pack,
                          wallet: wallet,
                          payment: payment,
                        ),
                        child: const Text('Худалдан авах'),
                      ),
                    ),
                  ),
                section('📒 Гүйлгээний түүх'),
                if (wallet.history.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Гүйлгээ алга'),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (final t in wallet.history.take(10))
                          ListTile(
                            dense: true,
                            leading: Icon(
                              t.amount >= 0
                                  ? Icons.add_circle
                                  : Icons.remove_circle,
                              color: t.amount >= 0
                                  ? AppColors.playerHp
                                  : AppColors.enemyHp,
                            ),
                            title: Text(
                              t.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              t.reference == null
                                  ? _date(t.at)
                                  : '${_date(t.at)} · ${t.reference}',
                              style: const TextStyle(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              '${t.amount >= 0 ? '+' : ''}${t.amount}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skinAction(BuildContext context, ShopItem item) {
    if (wallet.equippedSkin == item.id) {
      return const Chip(label: Text('Сонгосон ✓'));
    }
    if (wallet.ownedSkins.contains(item.id)) {
      return OutlinedButton(
        onPressed: () => wallet.equip(item.id),
        child: const Text('Сонгох'),
      );
    }
    return FilledButton(
      onPressed: () => _buy(context, item),
      child: Text('🪙 ${item.price}'),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.titleColor,
    required this.action,
    this.badge,
  });

  final ShopItem item;
  final Color titleColor;
  final Widget action;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(item.emoji, style: const TextStyle(fontSize: 30)),
        title: Row(
          children: [
            Flexible(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Text(badge!, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ],
        ),
        subtitle: Text(item.description, style: const TextStyle(fontSize: 12)),
        trailing: action,
      ),
    );
  }
}
