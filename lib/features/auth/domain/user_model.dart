// A simple User model to be used across the application.
// This is a pure data entity that represents a user.
class User {
  final String uid;
  final String email;
  final String fullName;
  final DateTime birthday;
  // Optional subscription expiry date (null if not subscribed/unknown)
  final DateTime? subscriptionExpiresAt;
  // Optional subscription acquisition method (e.g., 'stripe', 'appstore', 'promotional')
  final String? subscriptionMethod;

  User({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.birthday,
    this.subscriptionExpiresAt,
    this.subscriptionMethod,
  });

  // Convenience computed status: true if expiry is in the future
  bool get isSubscribed =>
      subscriptionExpiresAt != null &&
      subscriptionExpiresAt!.isAfter(DateTime.now());
}
