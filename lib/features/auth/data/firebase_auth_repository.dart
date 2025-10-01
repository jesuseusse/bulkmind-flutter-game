import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:bulkmind/features/auth/domain/auth_repository.dart';
import 'package:bulkmind/features/auth/domain/user_model.dart';

// Concrete implementation of the AuthRepository using Firebase.
class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({firebase_auth.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthday,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('User is null after sign up.');
      }

      // Here you can also save the full name and birthday to Firestore
      // For example:
      // await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      //   'fullName': fullName,
      //   'birthday': birthday.toIso8601String(),
      //   'email': email,
      // });

      return User(
        uid: user.uid,
        email: user.email!,
        fullName: fullName,
        birthday: birthday,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('An unknown error occurred during sign up.');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    // TODO: Implement Google sign-in logic here.
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user to send verification email.');
    }
    await user.sendEmailVerification();
  }

  @override
  Future<bool> refreshEmailVerificationStatus() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user to refresh.');
    }
    await user.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }
}
