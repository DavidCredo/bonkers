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

// final userProvider = StreamProvider.autoDispose((ref) {
//   final userStream = ref.watch(authStateChangesProvider);

//   final user = userStream.value;

//   if (user != null) {
//     var docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
//     return docRef.snapshots();
//   } else {
//     return const Stream.empty();
//   }
// });
final userCollectionProvider = StreamProvider.autoDispose<AuthenticatedUser>((ref) {
  final userStream = ref.watch(authStateChangesProvider);

  final user = userStream.value;

  if (user != null) {
    var docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    return docRef.snapshots().map((snapshot) => AuthenticatedUser.fromJson(snapshot.data()!) );
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
    return collRef.snapshots().map((snapShot) => snapShot.docs
        .map((document) => Bon.fromJson(document.data()))
        .toList());
  } else {
    return const Stream.empty();
  }
});

class DatabaseService {
  final db = FirebaseFirestore.instance.collection('users');

  void addUser(AuthenticatedUser user, FirebaseUser authenticatedUser) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(authenticatedUser.uid)
        .set(user.toJson());
    var userName = user.firstName;
    print("New user added: $userName");
  }

  void getUser(AuthenticatedUser user, FirebaseUser authenticatedUser) async {
    await db.doc(authenticatedUser.uid).get().then((DocumentSnapshot doc) {
      final userAsJson = doc.data() as Map<String, dynamic>;
      return AuthenticatedUser.fromJson(userAsJson);
    });
  }

  void addBon(FirebaseUser user, Bon bon) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("Bons")
        .doc(bon.uid)
        .set(bon.toJson());
  }

  void updatePayer(FirebaseUser user, Bon bon) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("Bons")
        .doc(bon.uid)
        .update({"articles": bon.articles});
  }
}
