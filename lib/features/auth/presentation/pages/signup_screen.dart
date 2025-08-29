import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  static const routeName = "/sign-up";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Cuenta")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Aquí conectas con tu lógica de auth (Firebase)
          },
          child: const Text("Login con Google"),
        ),
      ),
    );
  }
}
