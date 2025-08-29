import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Definición de la clase LoginScreen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto de correo electrónico y contraseña.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Estado para manejar el indicador de carga.
  bool _isLoading = false;
  // Instancia de FirebaseAuth para la autenticación.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Función para manejar el inicio de sesión.
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Inicia sesión con el correo electrónico y la contraseña.
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Si el inicio de sesión es exitoso, navega al home.
      if (mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      // Muestra un mensaje de error si la autenticación falla.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Ocurrió un error desconocido.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Libera los controladores cuando el widget es desechado.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo de texto para el correo electrónico.
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Campo de texto para la contraseña.
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Botón de inicio de sesión.
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Iniciar Sesión'),
                  ),
            const SizedBox(height: 16),
            // Botón para volver al home.
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver al Home'),
            ),
          ],
        ),
      ),
    );
  }
}
