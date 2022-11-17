import 'package:bonkers/controller/auth.dart';
import 'package:bonkers/models/firebaseuser.dart';
import 'package:bonkers/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userCollectionProvider = StreamProvider.autoDispose<Map?>((ref) {
  final userStream = ref.watch(authStateChangesProvider);

  final user = userStream.value;

  if (user != null) {
    var docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    return docRef.snapshots().map((doc) => doc.data());
  } else {
    return const Stream.empty();
  }
});

class DatabaseService {
  final db = FirebaseFirestore.instance.collection('users');

  void addUser(LoggedInUser user, FirebaseUser authenticatedUser) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(authenticatedUser.uid)
        .set(user.toJson());
    var userName = user.firstName;
    print("New user added: $userName");
  }

  void getUser(LoggedInUser user, FirebaseUser authenticatedUser) async {
    await db.doc(authenticatedUser.uid).get().then((DocumentSnapshot doc) {
      //WIP
    });
  }
}
