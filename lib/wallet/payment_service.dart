import 'dart:async';

/// Төлбөрийн үр дүн.
class PaymentResult {
  const PaymentResult.success(this.transactionId)
    : success = true,
      error = null;
  const PaymentResult.failure(this.error)
    : success = false,
      transactionId = null;

  final bool success;
  final String? transactionId;
  final String? error;
}

/// Төлбөрийн үйлчилгээний интерфэйс.
///
/// Одоогоор [MockPaymentService] (жинхэнэ мөнгө хөдөлгөхгүй, туршилтын горим).
/// Жинхэнэ төлбөрийн систем (QPay, Stripe, Apple/Google In-App Purchase)
/// холбохдоо зөвхөн энэ интерфэйсийг хэрэгжүүлнэ — дэлгүүр, түрийвч өөрчлөгдөхгүй.
abstract class PaymentService {
  /// Горимын нэр (дэлгэц дээр харагдана).
  String get modeLabel;

  /// [amountMnt] төгрөгөөр төлбөр гүйцэтгэнэ.
  Future<PaymentResult> charge({
    required int amountMnt,
    required String description,
  });
}

/// Туршилтын төлбөр: хүсэлтийг боловсруулж байгаа мэт хүлээгээд амжилттай
/// болгоно. Жинхэнэ карт, мөнгө оролцохгүй.
class MockPaymentService implements PaymentService {
  MockPaymentService({
    this.delay = const Duration(milliseconds: 1500),
    this.failNext = false,
  });

  final Duration delay;

  /// Дараагийн төлбөрийг зориуд амжилтгүй болгоно (туршилт, демо).
  bool failNext;
  int _seq = 0;

  @override
  String get modeLabel => 'Туршилтын төлбөр (жинхэнэ мөнгөгүй)';

  @override
  Future<PaymentResult> charge({
    required int amountMnt,
    required String description,
  }) async {
    await Future<void>.delayed(delay);
    if (amountMnt <= 0) return const PaymentResult.failure('Дүн буруу байна');
    if (failNext) {
      failNext = false;
      return const PaymentResult.failure('Карт татгалзлаа (тест)');
    }
    _seq++;
    return PaymentResult.success(
      'TEST-${DateTime.now().millisecondsSinceEpoch}-$_seq',
    );
  }
}
