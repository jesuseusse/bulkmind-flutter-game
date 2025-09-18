import 'package:bulkmind/features/auth/domain/user_model.dart';

/// Contract for user profile persistence separate from authentication.
abstract class UserRepository {
  Future<User> getById(String uid);
  Future<void> create(User user);
  Future<void> update(User user);
  Stream<User?> watchById(String uid);

  /// Returns the user document if it exists, optionally forcing a refresh
  /// bypassing any cached value.
  Future<User?> getUser(
    String uid, {
    bool forceRefresh = false,
  });

  /// Partially updates subscription fields for a user.
  /// Only non-null parameters are updated.
  Future<void> updateSubscription(
    String uid, {
    DateTime? subscriptionExpiresAt,
    String? subscriptionMethod,
  });

  /// Stores metadata about how the subscription was acquired on the user.
  Future<void> updateSubscriptionDetails(
    String uid, {
    required String subscriptionMethod,
    required String subscriptionPlan,
    DateTime? subscriptionExpiresAt,
    String? discountCode,
  });
}
