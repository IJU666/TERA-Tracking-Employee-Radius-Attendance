import 'package:flutter/material.dart';
// import '../models/leave_model.dart';
// import '../repositories/leave_repository.dart';

class LeaveProvider extends ChangeNotifier {
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // List<LeaveModel> _leaveRequests = [];
  // List<LeaveModel> get leaveRequests => _leaveRequests;

  Future<bool> submitLeaveRequest(/* parameter form cuti/izin */) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      // TODO: Upload file (jika ada) via StorageService, lalu simpan data ke LeaveRepository
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      debugPrint("Error submit leave: $e");
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyLeaveRequests(String uid) async {
    // Ambil riwayat cuti user yang sedang login
  }
}