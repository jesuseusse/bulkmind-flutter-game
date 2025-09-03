import 'package:bulkmind/features/auth/domain/user_model.dart';

// An abstract class that defines the contract for authentication operations.
// This decouples the business logic from the specific implementation (e.g., Firebase).
abstract class AuthRepository {
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthday,
  });

  // Method for Google sign-in.
  Future<void> signInWithGoogle();
}
