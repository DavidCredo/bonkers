import 'package:bonkers/models/bon.dart';

class LoggedInUser {
  final String firstName;
  final String email;
  final List<Bon>? bons;

  LoggedInUser({required this.firstName, required this.email, this.bons});

  factory LoggedInUser.fromJson(Map<String, dynamic> data) {
    final firstName = data['firstName'] as String;
    final email = data['email'] as String;
    final bonsData = data['Bons'] as List<dynamic>?;
    final bons = bonsData != null
        ? bonsData.map((bonData) => Bon.fromJson(bonData)).toList()
        : <Bon>[];
    return LoggedInUser(firstName: firstName, email: email, bons: bons);
  }

  Map<String, dynamic> toJson() {
    return {'firstName': firstName, 'email': email};
  }
}
