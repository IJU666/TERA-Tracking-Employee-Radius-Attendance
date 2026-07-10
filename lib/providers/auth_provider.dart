import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  

  Future<void> refreshCurrentUser() async {
  if (_currentUser == null) return;
  try {
    final refreshedUser = await _userRepository.getUser(_currentUser!.uid);
    if (refreshedUser != null) {
      _currentUser = refreshedUser;
      notifyListeners();
    }
  } catch (_) {
    // silent fail — data lama tetap dipakai
  }
}
Future<bool> registerEmployee({
  required String email,
  required String password,
  required String nama,
}) async {
  try {
    // 1. Daftarkan akun ke Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    String uid = userCredential.user!.uid;

    // 2. Simpan data profil ke Firestore koleksi 'users'
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'nama': nama,
      'email': email,
      'role': 'employee',
      
      // 🔥 OTOMATIS JADI 14 SAAT USER DIBUAT
      'sisa_cuti': 14,  
      'total_cuti': 14, 
      
      'createdAt': FieldValue.serverTimestamp(),
    });

    return true;
  } catch (e) {
    debugPrint("Error register user: $e");
    return false;
  }
}

  Future<void> init() async {
    final firebaseUser = _authRepository.currentUser;
    if (firebaseUser != null) {
      _currentUser = await _userRepository.getUser(firebaseUser.uid);
      notifyListeners();
    }
  }

  /// Login dengan email & password.
  /// Return null jika sukses, atau pesan error (String) jika gagal.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: Autentikasi akun ke Firebase Auth
      final firebaseUser = await _authRepository.login(
        email: email,
        password: password,
      );

      if (firebaseUser == null) {
        return AppStrings.errorLoginFailed; // Email/Password salah
      }

      // Step 2: Ambil data profil dari Realtime Database
      try {
        final userData = await _userRepository.getUser(firebaseUser.uid);
        
        // Antisipasi jika akun di Auth ada, tapi nodenya tidak ada di Realtime Database
        if (userData == null) {
          await _authRepository.logout(); // paksa logout kembali
          return "Akun terdaftar, namun data profil gagal ditemukan di database.";
        }

        _currentUser = userData;
        return null; // LOGIN SUKSES TOTAL
        
      } catch (dbError) {
        // Mencetak error asli database ke Console agar bisa Anda baca saat debug
        debugPrint("❌ ERROR DATABASE: $dbError");
        await _authRepository.logout(); 
        return "Gagal terhubung ke database profil. Periksa koneksi atau rules Anda.";
      }

    } catch (authError) {
      // Mencetak error asli autentikasi ke Console
      debugPrint("❌ ERROR AUTHENTICATION: $authError");
      return AppStrings.errorLoginFailed;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<String?> forgotPassword(String email) async {
    try {
      await _authRepository.forgotPassword(email);
      return null;
    } catch (e) {
      debugPrint("❌ ERROR FORGOT PASSWORD: $e");
      return AppStrings.errorUnknown;
    }
  }
  

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Ambil user Firebase yang sedang login
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        return "Pengguna tidak terdeteksi. Silakan login ulang.";
      }

      // Step 1: Autentikasi ulang (wajib dari Firebase sebelum ganti password)
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Step 2: Update password baru
      await user.updatePassword(newPassword);

      // Step 3: Logout otomatis (opsional, karena user sudah ubah password)
      await logout();

      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ ERROR CHANGE PASSWORD: ${e.code}");
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "Password saat ini salah.";
      } else if (e.code == 'weak-password') {
        return "Password baru terlalu lemah.";
      }
      return "Gagal mengubah password: ${e.message}";
    } catch (e) {
      debugPrint("❌ ERROR CHANGE PASSWORD UNKNOWN: $e");
      return "Terjadi kesalahan tidak terduga.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
}