import 'package:flutter/material.dart';

import '../design/theme.dart';
import 'payment_service.dart';
import 'wallet_models.dart';
import 'wallet_service.dart';

/// Coin худалдан авах төлбөрийн цонх: баталгаажуулах → боловсруулах → үр дүн.
/// Туршилтын горимд ажиллана (жинхэнэ мөнгө хасагдахгүй).
Future<bool> showCheckoutDialog(
  BuildContext context, {
  required CoinPack pack,
  required WalletService wallet,
  required PaymentService payment,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        _CheckoutDialog(pack: pack, wallet: wallet, payment: payment),
  );
  return ok ?? false;
}

enum _Stage { confirm, processing, success, failed }

class _CheckoutDialog extends StatefulWidget {
  const _CheckoutDialog({
    required this.pack,
    required this.wallet,
    required this.payment,
  });

  final CoinPack pack;
  final WalletService wallet;
  final PaymentService payment;

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  _Stage _stage = _Stage.confirm;
  String? _reference;
  String? _error;

  String _money(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '₮$buf';
  }

  Future<void> _pay() async {
    setState(() => _stage = _Stage.processing);
    final result = await widget.wallet.buyCoins(widget.pack, widget.payment);
    if (!mounted) return;
    setState(() {
      if (result.success) {
        _stage = _Stage.success;
        _reference = result.transactionId;
      } else {
        _stage = _Stage.failed;
        _error = result.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pack = widget.pack;
    return PopScope(
      canPop: _stage != _Stage.processing,
      child: AlertDialog(
        title: Text(switch (_stage) {
          _Stage.confirm => 'Төлбөр баталгаажуулах',
          _Stage.processing => 'Боловсруулж байна…',
          _Stage.success => 'Төлбөр амжилттай ✅',
          _Stage.failed => 'Төлбөр амжилтгүй ❌',
        }),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: Text(
                '🧪 ${widget.payment.modeLabel}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Бараа: ${pack.coins} 🪙 coin'),
            Text(
              'Дүн: ${_money(pack.priceMnt)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const Text('Төлбөрийн хэрэгсэл: Тест карт •••• 4242'),
            const SizedBox(height: 12),
            if (_stage == _Stage.processing)
              const Center(child: CircularProgressIndicator()),
            if (_stage == _Stage.success) ...[
              Text('+${pack.coins} 🪙 түрийвчинд нэмэгдлээ'),
              Text(
                'Гүйлгээний дугаар:\n$_reference',
                style: const TextStyle(fontSize: 11),
              ),
            ],
            if (_stage == _Stage.failed) Text(_error ?? 'Тодорхойгүй алдаа'),
          ],
        ),
        actions: switch (_stage) {
          _Stage.confirm => [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Цуцлах'),
            ),
            FilledButton(
              onPressed: _pay,
              child: Text('Төлөх ${_money(pack.priceMnt)}'),
            ),
          ],
          _Stage.processing => const [],
          _Stage.success => [
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Хаах'),
            ),
          ],
          _Stage.failed => [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Хаах'),
            ),
            FilledButton(onPressed: _pay, child: const Text('Дахин оролдох')),
          ],
        },
      ),
    );
  }
}
