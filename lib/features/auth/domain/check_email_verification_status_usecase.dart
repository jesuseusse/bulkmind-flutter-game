import 'package:bulkmind/features/auth/domain/auth_repository.dart';

/// Use case that refreshes the auth user and returns the latest
/// email verification status. Returns `true` when the email is verified.
class CheckEmailVerificationStatusUseCase {
  final AuthRepository _authRepository;

  CheckEmailVerificationStatusUseCase(this._authRepository);

  Future<bool> call() {
    return _authRepository.refreshEmailVerificationStatus();
  }
}
