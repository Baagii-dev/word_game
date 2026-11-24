/// Дэлгүүр, түрийвч (coin) -ийн өгөгдлийн бүтцүүд.
library;

enum ShopItemKind {
  /// Тулаанд нэг удаа ашиглагддаг бэлтгэл.
  consumable,

  /// Баатрын дүр (нэг удаа худалдаж аваад үргэлж эзэмшинэ).
  skin,
}

/// Бэлтгэлийн нөлөө (тулаан эхлэхэд автоматаар хэрэглэгдэнэ).
enum BoostEffect { extraHints, extraSeconds, extraHp, none }

class ShopItem {
  const ShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.emoji,
    required this.kind,
    this.effect = BoostEffect.none,
    this.amount = 0,
  });

  final String id;
  final String title;
  final String description;
  final int price; // coin
  final String emoji; // бэлтгэлийн дүрс эсвэл баатрын emoji
  final ShopItemKind kind;
  final BoostEffect effect;
  final int amount; // нөлөөний хэмжээ
}

/// Анхдагч (үнэгүй) баатрын дүр.
const String kDefaultSkinId = 'skin_rider';

const List<ShopItem> kShopItems = [
  ShopItem(
    id: 'boost_hints',
    title: 'Санамжийн багц',
    description: 'Дараагийн тулаанд +3 санамж',
    price: 30,
    emoji: '💡',
    kind: ShopItemKind.consumable,
    effect: BoostEffect.extraHints,
    amount: 3,
  ),
  ShopItem(
    id: 'boost_time',
    title: 'Цагийн эрч',
    description: 'Дараагийн тулаанд ээлж бүр +10 секунд',
    price: 40,
    emoji: '⏱️',
    kind: ShopItemKind.consumable,
    effect: BoostEffect.extraSeconds,
    amount: 10,
  ),
  ShopItem(
    id: 'boost_hp',
    title: 'Хуяг',
    description: 'Дараагийн тулаанд +10 амь',
    price: 50,
    emoji: '🛡️',
    kind: ShopItemKind.consumable,
    effect: BoostEffect.extraHp,
    amount: 10,
  ),
  ShopItem(
    id: kDefaultSkinId,
    title: 'Морьтон',
    description: 'Анхдагч баатар',
    price: 0,
    emoji: '🏇',
    kind: ShopItemKind.skin,
  ),
  ShopItem(
    id: 'skin_eagle',
    title: 'Бүргэд',
    description: 'Тал нутгийн хаан шувуу',
    price: 100,
    emoji: '🦅',
    kind: ShopItemKind.skin,
  ),
  ShopItem(
    id: 'skin_archer',
    title: 'Харваач',
    description: 'Монгол харваач',
    price: 120,
    emoji: '🏹',
    kind: ShopItemKind.skin,
  ),
  ShopItem(
    id: 'skin_wolf',
    title: 'Чоно',
    description: 'Хөх чоно',
    price: 150,
    emoji: '🐺',
    kind: ShopItemKind.skin,
  ),
];

ShopItem? shopItemById(String id) {
  for (final i in kShopItems) {
    if (i.id == id) return i;
  }
  return null;
}

/// Coin худалдаж авах багц (жинхэнэ мөнгөгүй, туршилтын төлбөрөөр).
class CoinPack {
  const CoinPack({
    required this.id,
    required this.coins,
    required this.priceMnt,
  });

  final String id;
  final int coins;
  final int priceMnt; // төгрөг (тест горим)
}

const List<CoinPack> kCoinPacks = [
  CoinPack(id: 'pack_s', coins: 100, priceMnt: 1000),
  CoinPack(id: 'pack_m', coins: 550, priceMnt: 5000),
  CoinPack(id: 'pack_l', coins: 1200, priceMnt: 10000),
];

enum TransactionType { reward, spend, purchase }

/// Түрийвчний нэг гүйлгээ.
class WalletTransaction {
  WalletTransaction({
    required this.type,
    required this.amount,
    required this.label,
    DateTime? at,
    this.reference,
  }) : at = at ?? DateTime.now();

  final TransactionType type;

  /// Coin-ий өөрчлөлт: орлого (+), зарлага (−).
  final int amount;
  final String label;
  final DateTime at;

  /// Төлбөрийн гүйлгээний дугаар (худалдан авалтад).
  final String? reference;

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'amount': amount,
    'label': label,
    'at': at.toIso8601String(),
    'reference': reference,
  };

  factory WalletTransaction.fromMap(Map<String, dynamic> m) =>
      WalletTransaction(
        type: TransactionType.values.firstWhere(
          (t) => t.name == m['type'],
          orElse: () => TransactionType.reward,
        ),
        amount: (m['amount'] as num?)?.toInt() ?? 0,
        label: m['label'] as String? ?? '',
        at: DateTime.tryParse(m['at'] as String? ?? '') ?? DateTime.now(),
        reference: m['reference'] as String?,
      );
}

/// Тулаан эхлэхэд хэрэглэгдэх бэлтгэлийн нийлбэр.
class BattleBonuses {
  const BattleBonuses({
    this.extraHints = 0,
    this.extraSeconds = 0,
    this.extraHp = 0,
  });

  static const none = BattleBonuses();

  final int extraHints;
  final int extraSeconds;
  final int extraHp;

  bool get isEmpty => extraHints == 0 && extraSeconds == 0 && extraHp == 0;

  /// Дэлгэцэнд харуулах товч тайлбар.
  String describe() {
    final parts = <String>[
      if (extraHp > 0) '+$extraHp амь',
      if (extraSeconds > 0) '+$extraSeconds сек',
      if (extraHints > 0) '+$extraHints санамж',
    ];
    return parts.isEmpty ? '' : '🎒 Бэлтгэл: ${parts.join(', ')}';
  }
}
