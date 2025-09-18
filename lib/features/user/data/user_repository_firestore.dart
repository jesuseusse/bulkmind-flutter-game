import 'package:bulkmind/features/auth/domain/user_model.dart' as domain;
import 'package:bulkmind/features/user/domain/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _db;
  FirestoreUserRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('users');

  static domain.User _fromDoc(String uid, Map<String, dynamic> data) {
    final ts = data['birthday'];
    DateTime birthday;
    if (ts is Timestamp) {
      birthday = ts.toDate();
    } else if (ts is String) {
      birthday = DateTime.tryParse(ts) ?? DateTime(1970, 1, 1);
    } else {
      birthday = DateTime(1970, 1, 1);
    }
    // subscriptionExpiresAt can be a Firestore Timestamp or an ISO string
    final expiresRaw = data['subscriptionExpiresAt'];
    DateTime? subscriptionExpiresAt;
    if (expiresRaw is Timestamp) {
      subscriptionExpiresAt = expiresRaw.toDate();
    } else if (expiresRaw is String) {
      subscriptionExpiresAt = DateTime.tryParse(expiresRaw);
    }

    final String? subscriptionMethod = data['subscriptionMethod'] is String
        ? data['subscriptionMethod'] as String
        : null;
    final String? subscriptionPlan = data['subscriptionPlan'] is String
        ? data['subscriptionPlan'] as String
        : null;
    final String? discountCode = data['discountCode'] is String
        ? data['discountCode'] as String
        : null;
    return domain.User(
      uid: uid,
      email: data['email'] as String,
      fullName: data['fullName'] as String,
      birthday: birthday,
      subscriptionExpiresAt: subscriptionExpiresAt,
      subscriptionMethod: subscriptionMethod,
      subscriptionPlan: subscriptionPlan,
      discountCode: discountCode,
    );
  }

  Map<String, dynamic> _toMap(domain.User user) {
    final map = <String, dynamic>{
      'email': user.email,
      'fullName': user.fullName,
      'birthday': Timestamp.fromDate(user.birthday),
    };
    if (user.subscriptionExpiresAt != null) {
      map['subscriptionExpiresAt'] = Timestamp.fromDate(
        user.subscriptionExpiresAt!,
      );
    }
    if (user.subscriptionMethod != null) {
      map['subscriptionMethod'] = user.subscriptionMethod;
    }
    if (user.subscriptionPlan != null) {
      map['subscriptionPlan'] = user.subscriptionPlan;
    }
    if (user.discountCode != null) {
      map['discountCode'] = user.discountCode;
    }
    return map;
  }

  @override
  Future<void> create(domain.User user) async {
    await _usersCol.doc(user.uid).set(_toMap(user));
  }

  @override
  Future<domain.User> getById(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) throw StateError('User $uid not found');
    final data = doc.data()!;
    return _fromDoc(doc.id, data);
  }

  @override
  Future<void> update(domain.User user) async {
    await _usersCol.doc(user.uid).update(_toMap(user));
  }

  @override
  Stream<domain.User?> watchById(String uid) {
    return _usersCol.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!;
      return _fromDoc(snap.id, data);
    });
  }

  @override
  Future<void> updateSubscription(
    String uid, {
    DateTime? subscriptionExpiresAt,
    String? subscriptionMethod,
  }) async {
    final update = <String, dynamic>{};
    if (subscriptionExpiresAt != null) {
      update['subscriptionExpiresAt'] = Timestamp.fromDate(
        subscriptionExpiresAt,
      );
    }
    if (subscriptionMethod != null) {
      update['subscriptionMethod'] = subscriptionMethod;
    }
    if (update.isEmpty) return; // nothing to do
    await _usersCol.doc(uid).set(update, SetOptions(merge: true));
  }

  @override
  Future<void> updateSubscriptionDetails(
    String uid, {
    required String subscriptionMethod,
    required String subscriptionPlan,
    required DateTime subscriptionExpiresAt,
    String? discountCode,
  }) async {
    final data = <String, dynamic>{
      'subscriptionMethod': subscriptionMethod,
      'subscriptionPlan': subscriptionPlan,
      'discountCode': discountCode ?? '',
    };
    data['subscriptionExpiresAt'] = Timestamp.fromDate(subscriptionExpiresAt);

    await _usersCol.doc(uid).set(data, SetOptions(merge: true));
  }
}
