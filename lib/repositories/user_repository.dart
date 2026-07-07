import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

/// Repository untuk data profil karyawan di koleksi 'users'.
class UserRepository {
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
  }

  Future<void> updateUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    final snapshot = await _usersRef.where('role', isEqualTo: role).get();
    return snapshot.docs
        .map((doc) =>
            UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _usersRef.get();
    return snapshot.docs
        .map((doc) =>
            UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
