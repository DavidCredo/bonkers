import 'package:bonkers/controller/database.dart';
import 'package:bonkers/controller/auth.dart';
import 'package:bonkers/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Register extends ConsumerStatefulWidget {
  final Function? toggleView;
  const Register({super.key, this.toggleView});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  final db = DatabaseService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final AuthService _auth = AuthService();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _registerFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Your name',
                      prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gib eine valide Email Adresse an.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gib ein Passwort mit mindestens 6 Zeichen ein.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.password)),
                  obscureText: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_registerFormKey.currentState!.validate()) {
                              dynamic result =
                                  await _auth.registerEmailPassword(
                                      _emailController.text,
                                      _passwordController.text);

                              if (result.uid == null) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          content: Text(result.code));
                                    });
                              } else {
                                AuthenticatedUser user = AuthenticatedUser(
                                  email: _emailController.text,
                                  firstName: _nameController.text,
                                  uid: result.uid,
                                );

                                ref.read(databaseProvider).addUser(user);
                              }
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Register'),
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
                    child: const Text("Already have an account?"))
              ],
            )),
      ),
    );
  }
}
