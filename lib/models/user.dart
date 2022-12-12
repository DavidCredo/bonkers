import 'package:bonkers/models/payer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticatedUser {
  final String firstName;
  final String email;
  final List<Payer>? payers;
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
    final payers = payerData != null
        ? payerData.map((payer) => Payer.fromJson(payer)).toList()
        : <Payer>[];
    final uid = data['uid'] as String;

    return AuthenticatedUser(
        firstName: firstName, email: email, payers: payers, uid: uid);
  }

  AuthenticatedUser copyWith(
          {String? firstName,
          String? email,
          List<Payer>? payers,
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
      if (payers != null)
        "payers": payers!.map((payer) => payer.toJson()).toList(),
      'uid': uid
    };
  }
}

class PayerNotifier extends ChangeNotifier {
  Payer selectedPayer = Payer(color: Color(16043240), name: "Niemand");

  void updatePayer(Payer newPayer) {
    selectedPayer = newPayer;
    notifyListeners();
  }
}

final payerNotifierProvider = ChangeNotifierProvider((ref) => PayerNotifier());
