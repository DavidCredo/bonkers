import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/firebaseuser.dart';
import '../models/loginuser.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);

  return firebaseAuth.authStateChanges();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser? _firebaseUser(User? user) {
    return user != null ? FirebaseUser(uid: user.uid) : null;
  }

  Stream<FirebaseUser?> get user {
    return _auth.authStateChanges().map(_firebaseUser);
  }

  Future signInAnonymous() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;
      return _firebaseUser(user);
    } catch (e) {
      return FirebaseUser(uid: null, code: e.toString());
    }
  }

  Future signInEmailPassword(LoginUser _login) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _login.email.toString(), password: _login.password.toString());
      User? user = userCredential.user;
      return _firebaseUser(user);
    } on FirebaseAuthException catch (e) {
      return FirebaseUser(code: e.code, uid: null);
    }
  }

  Future registerEmailPassword(LoginUser _login) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: _login.email.toString(),
              password: _login.password.toString());
      User? user = userCredential.user;
      return _firebaseUser(user);
    } on FirebaseAuthException catch (e) {
      return FirebaseUser(code: e.code, uid: null);
    } catch (e) {
      return FirebaseUser(code: e.toString(), uid: null);
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }
}
