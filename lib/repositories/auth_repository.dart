import 'package:firebase_auth/firebase_auth.dart';

/// Repository untuk otentikasi (login, logout, lupa password).
/// Hanya berurusan dengan FirebaseAuth — pengambilan data profil karyawan
/// ada di user_repository.dart.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login dengan email & password.
  /// Melempar FirebaseAuthException jika gagal (ditangani di provider).
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
