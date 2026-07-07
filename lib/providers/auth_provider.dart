import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

/// Provider untuk state login & user yang sedang aktif.
/// Dipakai di login_screen.dart dan home_screen.dart (untuk greeting nama).
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  /// Panggil sekali di splash_screen untuk cek sesi yang sedang berjalan.
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
      final firebaseUser = await _authRepository.login(
        email: email,
        password: password,
      );

      if (firebaseUser == null) {
        return AppStrings.errorLoginFailed;
      }

      _currentUser = await _userRepository.getUser(firebaseUser.uid);
      return null;
    } on Exception catch (_) {
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
    } on Exception catch (_) {
      return AppStrings.errorUnknown;
    }
  }
}
