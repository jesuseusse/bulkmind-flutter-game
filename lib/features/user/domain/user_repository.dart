import 'package:bulkmind/features/auth/domain/user_model.dart';

/// Contract for user profile persistence separate from authentication.
abstract class UserRepository {
  Future<User> getById(String uid);
  Future<void> create(User user);
  Future<void> update(User user);
  Stream<User?> watchById(String uid);
}

