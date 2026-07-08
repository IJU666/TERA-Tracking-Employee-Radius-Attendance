import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  // Inisialisasi repository database
  final UserRepository _userRepository = UserRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _userProfile;
  UserModel? get userProfile => _userProfile;

  /// Mengambil profil user untuk halaman Profil/Dashboard
  Future<void> fetchProfile(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userProfile = await _userRepository.getUser(uid);
    } catch (e) {
      debugPrint("❌ Error fetching profile di UserProvider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update profil karyawan (nama, nik, divisi, jabatan).
  /// Return true kalau berhasil, false kalau gagal.
  Future<bool> updateProfile({
    required String uid,
    required String nama,
    required String nik,
    required String divisi,
    required String jabatan,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final existingUser = _userProfile ?? await _userRepository.getUser(uid);
      if (existingUser == null) {
        throw 'User tidak ditemukan';
      }

      final updatedUser = existingUser.copyWith(
        nama: nama,
        nik: nik,
        divisi: divisi,
        jabatan: jabatan,
      );

      await _userRepository.updateUser(updatedUser);

      // langsung update state lokal juga supaya UI ikut refresh
      _userProfile = updatedUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ Error update profile di UserProvider: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}