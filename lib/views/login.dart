import 'package:bonkers/controller/auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  final Function? toggleView;
  const Login({super.key, this.toggleView});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
                key: _loginFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      // The validator receives the text that the user has entered.
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte gib deine Email Adresse ein.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Email",
                          prefixIcon: Icon(Icons.email)),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return "'Bitte gib ein Passwort mit mindestens 6 Zeichen ein.";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Password",
                            prefixIcon: Icon(Icons.password)),
                        obscureText: true),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                            child: ElevatedButton(
                              onPressed: () async {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_loginFormKey.currentState!.validate()) {
                                  dynamic result =
                                      await _auth.signInEmailPassword(
                                          _emailController.text,
                                          _passwordController.text);
                                  if (result.uid == null) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: Text(result.code),
                                          );
                                        });
                                  }
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Login'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                        onPressed: () {
                          widget.toggleView!();
                        },
                        child: const Text("No account yet?"))
                  ],
                ))));
  }
}
