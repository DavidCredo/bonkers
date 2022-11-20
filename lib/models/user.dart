import 'package:bonkers/models/bon.dart';

class AuthenticatedUser {
  final String firstName;
  final String email;
  // final List<Bon>? bons;

  AuthenticatedUser({required this.firstName, required this.email });

  factory AuthenticatedUser.fromJson(Map<String, dynamic> data) {
    final firstName = data['firstName'] as String;
    final email = data['email'] as String;
    // final bonsData = data['Bons'] as List<dynamic>?;
    // final bons = bonsData != null
    //     ? bonsData.map((bonData) => Bon.fromJson(bonData)).toList()
    //     : <Bon>[];
    return AuthenticatedUser(firstName: firstName, email: email );
  }

  Map<String, dynamic> toJson() {
    return {'firstName': firstName, 'email': email};
  }
}
