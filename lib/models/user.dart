import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticatedUser {
  final String firstName;
  final String email;
  final List<dynamic>? payers;

  AuthenticatedUser(
      {required this.firstName, required this.email, this.payers});

  factory AuthenticatedUser.fromJson(Map<String, dynamic> data) {
    final firstName = data['firstName'] as String;
    final email = data['email'] as String;
    final payerData = data['payers'] as List<dynamic>?;

    return AuthenticatedUser(
        firstName: firstName, email: email, payers: payerData);
  }

  Map<String, dynamic> toJson() {
    return {'firstName': firstName, 'email': email, 'payers': payers};
  }
}

class PayerNotifier extends ChangeNotifier {
  String selectedPayer = "";

  void updatePayer(String newPayer) {
    selectedPayer = newPayer;
    notifyListeners();
  }
}

final payerNotifierProvider = ChangeNotifierProvider((ref) => PayerNotifier());
