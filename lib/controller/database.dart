import 'package:bonkers/controller/auth.dart';
import 'package:bonkers/models/bon.dart';
import 'package:bonkers/models/bon_item.dart';
import 'package:bonkers/models/firebaseuser.dart';
import 'package:bonkers/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

final userCollectionProvider =
    StreamProvider.autoDispose<AuthenticatedUser>((ref) {
  final userStream = ref.watch(authStateChangesProvider);

  final user = userStream.value;

  if (user != null) {
    var docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    return docRef
        .snapshots()
        .map((snapshot) => AuthenticatedUser.fromJson(snapshot.data()!));
  } else {
    return const Stream.empty();
  }
});
// TODO: Refactoring needed? Type safety is ok, but there's probably a better way.
final userBonsCollectionProvider = StreamProvider.autoDispose<List<Bon>>((ref) {
  final userStream = ref.watch(authStateChangesProvider);

  final user = userStream.value;

  if (user != null) {
    var collRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('Bons');
    return collRef.snapshots().map((snapshot) => snapshot.docs
        .map((document) => Bon.fromJson(document.data()))
        .toList());
  } else {
    return const Stream.empty();
  }
});
class DatabaseService {
  final db = FirebaseFirestore.instance.collection('users');

  void addUser(AuthenticatedUser user) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set(user.toJson());
  }

  Future addBon(User user, Bon bon) async {
    await db.doc(user.uid).collection("Bons").doc(bon.uid).set(bon.toJson());
  }

  Future updateBon(User user, Bon bon) async {
    List<Map<String, dynamic>> changedItems =
        bon.articles.map((article) => article.toJson()).toList();
    await db
        .doc(user.uid)
        .collection("Bons")
        .doc(bon.uid)
        .update({"articles": changedItems});
  }

  void updatePayerList(AuthenticatedUser user) async {
    await db.doc(user.uid).update({"payers": user.payers});
  }

  void updatePayerOfItem(AuthenticatedUser user, Bon bon) async {
    await db.doc(user.uid).collection('Bons').doc(bon.uid).set(bon.toJson());
  }
}

final databaseProvider = Provider.autoDispose<DatabaseService>((ref) {
  return DatabaseService();
});
