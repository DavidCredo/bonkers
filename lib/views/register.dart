import 'package:bonkers/models/loginuser.dart';
import 'package:bonkers/controller/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Register extends StatefulWidget {
  final Function? toggleView;
  const Register({super.key, this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  final _registerFormKey = GlobalKey<FormState>();

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
            key: _registerFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid email adress';
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
                      return 'Please enter a valid password, minimum 6 characters.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.password)),
                  obscureText: true,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_registerFormKey.currentState!.validate()) {
                        dynamic result = await _auth.registerEmailPassword(
                            LoginUser(
                                email: _emailController.text,
                                password: _passwordController.text));
                        if (result.uid == null) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(content: Text(result.code));
                              });
                        }
                      }
                    },
                    child: const Text('Register'),
                  ),
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
