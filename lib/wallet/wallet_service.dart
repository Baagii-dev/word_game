import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'payment_service.dart';
import 'wallet_models.dart';

/// Түрийвчний үүлэн хуулбар (Firestore). Байхгүй бол зөвхөн төхөөрөмж дээр.
abstract class WalletCloud {
  Future<Map<String, dynamic>?> load(String uid);
  Future<void> save(String uid, Map<String, dynamic> data);
}

enum PurchaseOutcome { ok, notEnoughCoins, alreadyOwned }

/// Тоглогчийн түрийвч: coin, бэлтгэл (inventory), баатрын дүр, гүйлгээний түүх.
///
/// Төхөөрөмж дээр (shared_preferences) хадгалж, онлайн нэвтэрсэн бол
/// Firestore-д хуулбарлана (олон төхөөрөмж дээр ижил түрийвч).
class WalletService extends ChangeNotifier {
  WalletService();

  static final WalletService instance = WalletService();
  static const String _key = 'wallet';
  static const int welcomeCoins = 50;
  static const int maxHistory = 100;

  int coins = 0;
  final Map<String, int> inventory = {}; // бэлтгэлийн id → тоо
  final Set<String> ownedSkins = {kDefaultSkinId};
  String equippedSkin = kDefaultSkinId;
  final List<WalletTransaction> history = []; // шинэ нь эхэндээ
  int _updatedAt = 0;

  WalletCloud? _cloud;
  String? _uid;

  /// Одоо сонгосон баатрын emoji.
  String get heroEmoji => shopItemById(equippedSkin)?.emoji ?? '🏇';

  int count(String itemId) => inventory[itemId] ?? 0;

  // ---------------- Хадгалалт ----------------

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        _apply(jsonDecode(raw) as Map<String, dynamic>);
      } else {
        _grant(welcomeCoins, 'Угтах бэлэг', TransactionType.reward);
        await _persist();
      }
    } catch (_) {
      // эвдэрсэн өгөгдөл → шинээр эхэлнэ
      _reset();
      _grant(welcomeCoins, 'Угтах бэлэг', TransactionType.reward);
    }
    notifyListeners();
  }

  Map<String, dynamic> toMap() => {
    'coins': coins,
    'inventory': inventory,
    'ownedSkins': ownedSkins.toList(),
    'equippedSkin': equippedSkin,
    'history': history.map((t) => t.toMap()).toList(),
    'updatedAt': _updatedAt,
  };

  void _reset() {
    coins = 0;
    inventory.clear();
    ownedSkins
      ..clear()
      ..add(kDefaultSkinId);
    equippedSkin = kDefaultSkinId;
    history.clear();
    _updatedAt = 0;
  }

  void _apply(Map<String, dynamic> m) {
    _reset();
    coins = (m['coins'] as num?)?.toInt() ?? 0;
    final inv = m['inventory'];
    if (inv is Map) {
      for (final e in inv.entries) {
        final n = e.value;
        if (n is num && n > 0) inventory['${e.key}'] = n.toInt();
      }
    }
    final skins = m['ownedSkins'];
    if (skins is List) ownedSkins.addAll(skins.whereType<String>());
    final eq = m['equippedSkin'];
    if (eq is String && ownedSkins.contains(eq)) equippedSkin = eq;
    final h = m['history'];
    if (h is List) {
      for (final t in h) {
        if (t is Map) {
          history.add(WalletTransaction.fromMap(Map<String, dynamic>.from(t)));
        }
      }
    }
    _updatedAt = (m['updatedAt'] as num?)?.toInt() ?? 0;
  }

  Future<void> _persist() async {
    _updatedAt = DateTime.now().millisecondsSinceEpoch;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(toMap()));
    } catch (e) {
      debugPrint('Түрийвч хадгалж чадсангүй: $e');
    }
    final cloud = _cloud, uid = _uid;
    if (cloud != null && uid != null) {
      unawaited(cloud.save(uid, toMap()).catchError((Object _) {}));
    }
  }

  /// Онлайн нэвтэрсний дараа үүлэн хуулбартай холбоно: хамгийн сүүлд
  /// өөрчлөгдсөн хувилбар (төхөөрөмж эсвэл үүл) хүчинтэй.
  Future<void> attachCloud(WalletCloud cloud, String uid) async {
    _cloud = cloud;
    _uid = uid;
    try {
      final remote = await cloud.load(uid);
      final remoteAt = (remote?['updatedAt'] as num?)?.toInt() ?? 0;
      if (remote != null && remoteAt > _updatedAt) {
        _apply(remote);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_key, jsonEncode(toMap()));
        notifyListeners();
      } else {
        await cloud.save(uid, toMap());
      }
    } catch (e) {
      debugPrint('Түрийвчийн үүлэн хуулбар холбогдсонгүй: $e');
    }
  }

  void detachCloud() {
    _cloud = null;
    _uid = null;
  }

  // ---------------- Гүйлгээ ----------------

  void _grant(
    int amount,
    String label,
    TransactionType type, {
    String? reference,
  }) {
    coins += amount;
    _log(
      WalletTransaction(
        type: type,
        amount: amount,
        label: label,
        reference: reference,
      ),
    );
  }

  void _log(WalletTransaction t) {
    history.insert(0, t);
    if (history.length > maxHistory) {
      history.removeRange(maxHistory, history.length);
    }
  }

  /// Тулаан ялснаас зэрэг оноосон coin.
  Future<void> earn(int amount, String label) async {
    if (amount <= 0) return;
    _grant(amount, label, TransactionType.reward);
    notifyListeners();
    await _persist();
  }

  /// Ердийн тулааны шагнал: ялбал 10 + од бүрт 5, ялагдвал 2.
  static int battleReward({required bool won, required int stars}) =>
      won ? 10 + stars * 5 : 2;

  /// 1v1 тулааны шагнал.
  static int duelReward({required bool won}) => won ? 25 : 5;

  /// Дэлгүүрээс бараа худалдаж авна (coin-оор).
  Future<PurchaseOutcome> buyItem(ShopItem item) async {
    if (item.kind == ShopItemKind.skin && ownedSkins.contains(item.id)) {
      return PurchaseOutcome.alreadyOwned;
    }
    if (coins < item.price) return PurchaseOutcome.notEnoughCoins;
    coins -= item.price;
    if (item.kind == ShopItemKind.skin) {
      ownedSkins.add(item.id);
    } else {
      inventory[item.id] = count(item.id) + 1;
    }
    _log(
      WalletTransaction(
        type: TransactionType.spend,
        amount: -item.price,
        label: item.title,
      ),
    );
    notifyListeners();
    await _persist();
    return PurchaseOutcome.ok;
  }

  /// Эзэмшиж буй баатрын дүрийг сонгоно.
  Future<bool> equip(String skinId) async {
    if (!ownedSkins.contains(skinId)) return false;
    equippedSkin = skinId;
    notifyListeners();
    await _persist();
    return true;
  }

  /// [pack]-ийг [payment]-аар төлж coin авна (туршилтын төлбөрөөр).
  Future<PaymentResult> buyCoins(CoinPack pack, PaymentService payment) async {
    final result = await payment.charge(
      amountMnt: pack.priceMnt,
      description: '${pack.coins} coin',
    );
    if (result.success) {
      _grant(
        pack.coins,
        '${pack.coins} coin худалдан авалт',
        TransactionType.purchase,
        reference: result.transactionId,
      );
      notifyListeners();
      await _persist();
    }
    return result;
  }

  /// Тулаан эхлэхэд эзэмшиж буй бэлтгэл бүрээс нэгийг ашиглаж, нөлөөг нь буцаана.
  BattleBonuses consumeBattleBonuses() {
    var hints = 0, seconds = 0, hp = 0;
    var used = false;
    for (final item in kShopItems.where(
      (i) => i.kind == ShopItemKind.consumable,
    )) {
      final n = count(item.id);
      if (n <= 0) continue;
      used = true;
      if (n == 1) {
        inventory.remove(item.id);
      } else {
        inventory[item.id] = n - 1;
      }
      switch (item.effect) {
        case BoostEffect.extraHints:
          hints += item.amount;
        case BoostEffect.extraSeconds:
          seconds += item.amount;
        case BoostEffect.extraHp:
          hp += item.amount;
        case BoostEffect.none:
          break;
      }
    }
    if (used) {
      notifyListeners();
      unawaited(_persist());
    }
    return BattleBonuses(extraHints: hints, extraSeconds: seconds, extraHp: hp);
  }
}
