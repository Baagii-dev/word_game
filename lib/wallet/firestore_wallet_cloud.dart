import 'package:cloud_firestore/cloud_firestore.dart';

import 'wallet_service.dart';

/// Түрийвчийг Firestore-ийн `wallets/{uid}` баримтад хуулбарлана.
class FirestoreWalletCloud implements WalletCloud {
  FirestoreWalletCloud({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('wallets').doc(uid);

  @override
  Future<Map<String, dynamic>?> load(String uid) async =>
      (await _doc(uid).get()).data();

  @override
  Future<void> save(String uid, Map<String, dynamic> data) =>
      _doc(uid).set(data);
}
