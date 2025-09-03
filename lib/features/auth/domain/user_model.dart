// A simple User model to be used across the application.
// This is a pure data entity that represents a user.
class User {
  final String uid;
  final String email;
  final String fullName;
  final DateTime birthday;

  User({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.birthday,
  });
}
