import 'package:bonkers/Screens/text_recognizer_view.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

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
                          return 'Please enter your email adress';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          hintText: "Email", prefixIcon: Icon(Icons.email)),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return "Please enter a valid password (min 6 characters)";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            hintText: "Password",
                            prefixIcon: Icon(Icons.password)),
                        obscureText: true),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_loginFormKey.currentState!.validate()) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const TextRecognizerView()));
                          }
                        },
                        child: const Text('Login'),
                      ),
                    ),
                  ],
                ))));
  }
}
