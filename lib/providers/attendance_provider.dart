import 'package:flutter/material.dart';
// import '../models/attendance_model.dart';
// import '../repositories/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // AttendanceModel? _todayAttendance;
  // AttendanceModel? get todayAttendance => _todayAttendance;

  // List<AttendanceModel> _attendanceHistory = [];
  // List<AttendanceModel> get attendanceHistory => _attendanceHistory;

  Future<bool> checkIn(double lat, double lng, String imagePath) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Hitung jarak dari office_provider, validasi radius, lalu simpan ke repo
      await Future.delayed(const Duration(seconds: 2)); // Simulasi network
      return true;
    } catch (e) {
      debugPrint("Check-in error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkOut(double lat, double lng, String imagePath) async {
    // Logika check out mirip dengan check in
    return true;
  }
}