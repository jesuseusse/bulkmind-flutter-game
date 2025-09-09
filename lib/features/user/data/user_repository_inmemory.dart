import 'dart:async';

import 'package:bulkmind/features/auth/domain/user_model.dart' as domain;
import 'package:bulkmind/features/user/domain/user_repository.dart';

/// Simple in-memory repository for development without external deps.
class UserRepositoryInMemory implements UserRepository {
  final Map<String, domain.User> _store = {};
  final Map<String, StreamController<domain.User?>> _controllers = {};

  StreamController<domain.User?> _controllerFor(String uid) {
    return _controllers.putIfAbsent(
      uid,
      () => StreamController<domain.User?>.broadcast(),
    );
  }

  @override
  Future<void> create(domain.User user) async {
    _store[user.uid] = user;
    _controllerFor(user.uid).add(user);
  }

  @override
  Future<domain.User> getById(String uid) async {
    final user = _store[uid];
    if (user == null) {
      throw StateError('User $uid not found');
    }
    return user;
  }

  @override
  Future<void> update(domain.User user) async {
    _store[user.uid] = user;
    _controllerFor(user.uid).add(user);
  }

  @override
  Stream<domain.User?> watchById(String uid) {
    final existing = _store[uid];
    final ctrl = _controllerFor(uid);
    // Emit current value asynchronously to avoid sync listeners issues.
    scheduleMicrotask(() => ctrl.add(existing));
    return ctrl.stream;
  }

  @override
  Future<void> updateSubscription(
    String uid, {
    DateTime? subscriptionExpiresAt,
    String? subscriptionMethod,
  }) async {
    final current = await getById(uid);
    final updated = domain.User(
      uid: current.uid,
      email: current.email,
      fullName: current.fullName,
      birthday: current.birthday,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? current.subscriptionExpiresAt,
      subscriptionMethod: subscriptionMethod ?? current.subscriptionMethod,
    );
    _store[uid] = updated;
    _controllerFor(uid).add(updated);
  }
}
