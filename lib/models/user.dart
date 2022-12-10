import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticatedUser {
  final String firstName;
  final String email;
  final List<dynamic>? payers;
  final String uid;

  AuthenticatedUser(
      {required this.firstName,
      required this.email,
      this.payers,
      required this.uid});

  factory AuthenticatedUser.fromJson(Map<String, dynamic> data) {
    final firstName = data['firstName'] as String;
    final email = data['email'] as String;
    final payerData = data['payers'] as List<dynamic>?;
    final payers = payerData != null ? payerData : <String>[];
    final uid = data['uid'] as String;

    return AuthenticatedUser(
        firstName: firstName, email: email, payers: payers, uid: uid);
  }

  AuthenticatedUser copyWith(
          {String? firstName,
          String? email,
          List<dynamic>? payers,
          String? uid}) =>
      AuthenticatedUser(
          firstName: firstName ?? this.firstName,
          email: email ?? this.email,
          uid: uid ?? this.uid,
          payers: payers ?? this.payers);

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'email': email,
      'payers': payers,
      'uid': uid
    };
  }
}

class PayerNotifier extends ChangeNotifier {
  String selectedPayer = "Niemand";

  void updatePayer(String newPayer) {
    selectedPayer = newPayer;
    notifyListeners();
  }
}

final payerNotifierProvider = ChangeNotifierProvider((ref) => PayerNotifier());
