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
    return domain.User(
      uid: uid,
      email: data['email'] as String,
      fullName: data['fullName'] as String,
      birthday: birthday,
    );
  }

  Map<String, dynamic> _toMap(domain.User user) => {
        'email': user.email,
        'fullName': user.fullName,
        'birthday': Timestamp.fromDate(user.birthday),
      };

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
}
