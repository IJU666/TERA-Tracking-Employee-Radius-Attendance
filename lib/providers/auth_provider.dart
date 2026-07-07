import 'package:flutter/material.dart'; // Wajib untuk ChangeNotifier
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart'; // Sesuaikan dengan path modelmu

// TAMBAHKAN 'with ChangeNotifier' di akhir nama class
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // --- State Management untuk UI ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Mengubah return type menjadi Future<bool> agar UI tahu login sukses atau gagal
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null; // Reset error sebelum mulai

    try {
      // TAHAP 1: Verifikasi email & password di Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ambil UID otomatis yang dihasilkan oleh Firebase Auth
      String uid = userCredential.user!.uid;

      // TAHAP 2: Ambil data profil di Realtime Database berdasarkan UID tersebut
      DataSnapshot snapshot = await _dbRef.child('users').child(uid).get();

      if (snapshot.exists) {
        // Bungkus data JSON dari database menjadi objek UserModel
        final Map<String, dynamic> userData = 
            Map<String, dynamic>.from(snapshot.value as Map);
        
        // Masukkan UID ke dalam map data sebelum diubah ke model
        userData['uid'] = uid;
        
        _currentUser = UserModel.fromJson(userData);
        _setLoading(false);
        return true; // Login Sukses
      } else {
        throw 'Data profil tidak ditemukan di database!';
      }
    } on FirebaseAuthException catch (e) {
      // Menangkap error khusus dari Firebase Auth
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        _errorMessage = 'Email tidak terdaftar!';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _errorMessage = 'Password yang Anda masukkan salah!';
      } else {
        _errorMessage = e.message ?? 'Terjadi kesalahan saat login';
      }
      _setLoading(false);
      return false; // Login Gagal
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false; // Login Gagal
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Fungsi bantuan untuk mengubah status loading dan memberi tahu UI
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Ini yang membuat UI otomatis refresh (loading spinner muncul/hilang)
  }
}