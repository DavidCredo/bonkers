import 'package:bonkers/controller/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bon.dart';

class BonRepository {
  BonRepository();
  final database = FirebaseFirestore.instance;
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection("users");

  Stream<List<Bon>> getAllBons({required String uid}) {
    return collectionRef.doc(uid).collection("Bons").snapshots().map(
        (snapshot) => snapshot.docs
            .map((document) => Bon.fromJson(document.data()))
            .toList());
  }

  Stream<Bon> getBon({required String uid, required String bonUid}) {
    return collectionRef
        .doc(uid)
        .collection("Bons")
        .doc(bonUid)
        .snapshots()
        .map((document) => Bon.fromJson(document.data()!));
  }
}

final bonRepositoryProvider = Provider<BonRepository>((ref) {
  return BonRepository();
});
