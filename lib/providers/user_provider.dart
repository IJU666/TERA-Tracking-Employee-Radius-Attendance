import 'package:flutter/material.dart';
// import '../models/user_model.dart';
// import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // List<UserModel> _employees = [];
  // List<UserModel> get employees => _employees;

  Future<void> fetchProfile(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Ambil data profil dari UserRepository
      // Data dummy untuk keperluan testing UI (misal: testing UI dengan nama Denis atau Ujang)
      
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(/* parameter update */) async {
    // Logika update profil
    notifyListeners();
  }
}