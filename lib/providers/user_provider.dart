import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  // Inisialisasi repository database
  final UserRepository _userRepository = UserRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _userProfile;
  UserModel? get userProfile => _userProfile;

  /// Mengambil profil user untuk halaman Profil/Dashboard
  Future<void> fetchProfile(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Memanggil fungsi Realtime Database yang sudah kita buat di Langkah 1
      _userProfile = await _userRepository.getUser(uid);
    } catch (e) {
      debugPrint("❌ Error fetching profile di UserProvider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile() async {
    // Logika update profil bisa ditambahkan di sini nanti jika diperlukan
    notifyListeners();
  }
}