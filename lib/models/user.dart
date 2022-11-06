class LoggedInUser {
  final String? firstName;
  final String? email;

  LoggedInUser({required this.firstName, required this.email});

  factory LoggedInUser.fromJson(Map<String, dynamic> data) {
    final firstName = data['firstName'] as String;
    final email = data['email'] as String;
    return LoggedInUser(firstName: firstName, email: email);
  }

  Map<String, dynamic> toJson() {
    return {'firstName': firstName, 'email': email};
  }
}
