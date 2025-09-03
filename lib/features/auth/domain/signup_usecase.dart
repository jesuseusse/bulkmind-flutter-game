import 'package:bulkmind/features/auth/domain/auth_repository.dart';
import 'package:bulkmind/features/auth/domain/user_model.dart';
import 'package:bulkmind/features/user/domain/user_repository.dart';

// A use case class that orchestrates the sign-up process.
// It uses the AuthRepository to perform the actual authentication.
class SignUpUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  SignUpUseCase(this._authRepository, this._userRepository);

  Future<User> call({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthday,
  }) async {
    // Step 1: create auth credentials
    final user = await _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
      birthday: birthday,
    );

    // Step 2: persist user profile via UserRepository
    await _userRepository.create(user);
    return user;
  }
}
