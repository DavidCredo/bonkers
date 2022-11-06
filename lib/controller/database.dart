import 'package:bonkers/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final db = FirebaseFirestore.instance.collection('users');

  void addUser(LoggedInUser user, dynamic result) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(result.uid)
        .set(user.toJson());
  }
}
