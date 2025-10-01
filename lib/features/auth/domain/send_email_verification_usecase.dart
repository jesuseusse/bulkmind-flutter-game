import 'package:bulkmind/features/auth/domain/auth_repository.dart';

/// Use case that requests a verification email for the current auth user.
class SendEmailVerificationUseCase {
  final AuthRepository _authRepository;

  SendEmailVerificationUseCase(this._authRepository);

  Future<void> call() {
    return _authRepository.sendEmailVerification();
  }
}
