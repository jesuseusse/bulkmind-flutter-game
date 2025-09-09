import 'package:bulkmind/features/auth/domain/user_model.dart';

/// Contract for user profile persistence separate from authentication.
abstract class UserRepository {
  Future<User> getById(String uid);
  Future<void> create(User user);
  Future<void> update(User user);
  Stream<User?> watchById(String uid);

  /// Partially updates subscription fields for a user.
  /// Only non-null parameters are updated.
  Future<void> updateSubscription(
    String uid, {
    DateTime? subscriptionExpiresAt,
    String? subscriptionMethod,
  });
}
