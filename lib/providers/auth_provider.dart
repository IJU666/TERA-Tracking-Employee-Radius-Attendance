import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

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
}