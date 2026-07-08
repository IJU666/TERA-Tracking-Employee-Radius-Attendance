import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../models/check_point_model.dart';
import '../repositories/attendance_repository.dart';

/// Provider untuk state absensi: status hari ini, riwayat terbaru,
/// ringkasan bulanan, riwayat berdasarkan filter periode, dan proses
/// check-in/check-out.
///
/// Dipakai oleh:
/// - home_screen.dart -> todayAttendance, todayStatusLabel, lastAttendance,
///   monthlyHadir/Lembur/Absen, progress getter, load...()
/// - absen_screen.dart -> checkIn(), checkOut()
/// - history_screen.dart -> historyList, isLoadingHistory, periodHadir/
///   Terlambat/Izin/Absen, loadHistoryByFilter(), loadHistoryByRange()
///
/// Catatan / TODO (lihat juga PROGRESS.md):
/// - Validasi radius kantor (haversine + office_provider) belum dipasang,
///   masih placeholder `_isWithinRadius`. Setelah office_provider &
///   haversine_util dibuat, panggil dari sana sebelum simpan checkIn.
/// - Upload foto (imagePath) ke Storage belum dipasang, masih placeholder
///   `_uploadPhoto`. Setelah storage_service.dart dibuat, ganti isinya.
/// - `remainingLeaveDays` masih hardcode, nanti pindah ke LeaveProvider.
enum AttendanceHistoryFilter { today, thisWeek, thisMonth }

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _repository = AttendanceRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AttendanceModel? _todayAttendance;
  AttendanceModel? get todayAttendance => _todayAttendance;

  List<AttendanceModel> _attendanceHistory = [];
  List<AttendanceModel> get attendanceHistory => _attendanceHistory;

  // Alias supaya konsisten dengan nama yang dipakai di home_screen.dart
  List<AttendanceModel> get recentHistory => _attendanceHistory;
  AttendanceModel? get lastAttendance =>
      _attendanceHistory.isNotEmpty ? _attendanceHistory.first : null;

  int _monthlyHadir = 0;
  int _monthlyLembur = 0;
  int _monthlyAbsen = 0;

  int get monthlyHadir => _monthlyHadir;
  int get monthlyLembur => _monthlyLembur;
  int get monthlyAbsen => _monthlyAbsen;

  // TODO: ganti dengan data asli dari LeaveProvider/leave_repository.
  int remainingLeaveDays = 12;

  static const int _workingDaysAssumption = 22;

  double get hadirProgress =>
      (_monthlyHadir / _workingDaysAssumption).clamp(0.0, 1.0);
  double get lemburProgress =>
      (_monthlyLembur / _workingDaysAssumption).clamp(0.0, 1.0);
  double get absenProgress =>
      (_monthlyAbsen / _workingDaysAssumption).clamp(0.0, 1.0);

  /// Label status absensi hari ini untuk StatusBadge di home_screen.
  String get todayStatusLabel {
    if (_todayAttendance == null || _todayAttendance!.checkIn == null) {
      return 'Belum Absen';
    }
    return _todayAttendance!.statusLabel;
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Muat status absensi hari ini. Panggil di initState home_screen.
  Future<void> loadTodayStatus() async {
    final uid = _uid;
    if (uid == null) return;

    _todayAttendance = await _repository.getByDate(uid, DateTime.now());
    notifyListeners();
  }

  /// Muat beberapa riwayat absensi terbaru (section "Absensi Terakhir").
  Future<void> loadRecentHistory({int limit = 5}) async {
    final uid = _uid;
    if (uid == null) return;

    _attendanceHistory = await _repository.getRecentByUid(uid, limit: limit);
    notifyListeners();
  }

  /// Muat ringkasan bulan berjalan (section "Ringkasan Bulan Ini").
  Future<void> loadMonthlySummary() async {
    final uid = _uid;
    if (uid == null) return;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final monthData = await _repository.getByRange(uid, start, end);

    _monthlyHadir = monthData
        .where((a) => a.status == 'hadir' || a.status == 'terlambat')
        .length;
    _monthlyAbsen = monthData.where((a) => a.status == 'absen').length;
    // Lembur belum punya field khusus di AttendanceModel; sementara 0
    // sampai modul lembur dibuat.
    _monthlyLembur = 0;

    notifyListeners();
  }

  /// Placeholder validasi radius kantor. Ganti dengan pemanggilan
  /// haversine_util + data kantor dari office_provider.
  bool _isWithinRadius(double lat, double lng) {
    // TODO: hitung jarak asli, sementara selalu true.
    return true;
  }

  /// Placeholder upload foto ke Storage. Ganti dengan storage_service.dart
  /// setelah dibuat. Sementara langsung mengembalikan path lokal apa adanya.
  Future<String> _uploadPhoto(String imagePath) async {
    // TODO: upload ke Firebase Storage, return download URL asli.
    return imagePath;
  }

  Future<bool> checkIn(double lat, double lng, String imagePath) async {
    final uid = _uid;
    if (uid == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      if (!_isWithinRadius(lat, lng)) {
        debugPrint('Check-in gagal: di luar radius kantor');
        return false;
      }

      final now = DateTime.now();
      final photoUrl = await _uploadPhoto(imagePath);

      // TODO: tentukan status 'hadir'/'terlambat' berdasarkan jam masuk
      // kantor (misal dari office_provider). Sementara selalu 'hadir'.
      final status = now.hour >= 9 ? 'terlambat' : 'hadir';

      final attendance = AttendanceModel(
        id: '',
        uid: uid,
        nama: FirebaseAuth.instance.currentUser?.displayName ?? '-',
        date: now,
        status: status,
        officeName: 'Kantor Pusat', // TODO: ambil dari office_provider
        checkIn: now,
        checkInLocation: CheckPointModel(
          timestamp: now,
          lat: lat,
          lng: lng,
          distance: 0, // TODO: isi jarak asli dari haversine_util
        ),
        checkInPhotoUrl: photoUrl,
      );

      await _repository.checkIn(attendance);
      _todayAttendance = attendance;
      return true;
    } catch (e) {
      debugPrint('Check-in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkOut(double lat, double lng, String imagePath) async {
    final uid = _uid;
    if (uid == null || _todayAttendance == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      if (!_isWithinRadius(lat, lng)) {
        debugPrint('Check-out gagal: di luar radius kantor');
        return false;
      }

      final now = DateTime.now();
      final photoUrl = await _uploadPhoto(imagePath);

      await _repository.checkOut(
        uid,
        _todayAttendance!.date,
        now,
        {
          'timestamp': now.toIso8601String(),
          'lat': lat,
          'lng': lng,
          'distance': 0,
        },
        photoUrl,
      );

      await loadTodayStatus();
      return true;
    } catch (e) {
      debugPrint('Check-out error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ TAMBAHAN UNTUK HISTORY_SCREEN ============

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  List<AttendanceModel> _historyList = [];
  List<AttendanceModel> get historyList => _historyList;

  int _periodHadir = 0;
  int _periodTerlambat = 0;
  int _periodIzin = 0;
  int _periodAbsen = 0;

  int get periodHadir => _periodHadir;
  int get periodTerlambat => _periodTerlambat;
  int get periodIzin => _periodIzin;
  int get periodAbsen => _periodAbsen;

  void _recalculatePeriodStats() {
    _periodHadir = _historyList.where((a) => a.status == 'hadir').length;
    _periodTerlambat =
        _historyList.where((a) => a.status == 'terlambat').length;
    _periodIzin = _historyList
        .where((a) => a.status == 'izin' || a.status == 'cuti')
        .length;
    _periodAbsen = _historyList.where((a) => a.status == 'absen').length;
  }

  /// Muat riwayat absensi berdasarkan filter cepat (Hari Ini/Minggu Ini/
  /// Bulan Ini). Dipakai oleh history_screen.dart.
  Future<void> loadHistoryByFilter({
    required AttendanceHistoryFilter filter,
  }) async {
    final now = DateTime.now();
    late DateTime start;
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (filter) {
      case AttendanceHistoryFilter.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case AttendanceHistoryFilter.thisWeek:
        final mondayThisWeek = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(
          mondayThisWeek.year,
          mondayThisWeek.month,
          mondayThisWeek.day,
        );
        break;
      case AttendanceHistoryFilter.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
    }

    await loadHistoryByRange(start: start, end: end);
  }

  /// Muat riwayat absensi berdasarkan rentang tanggal custom (dari
  /// showDateRangePicker di history_screen.dart).
  Future<void> loadHistoryByRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    _isLoadingHistory = true;
    notifyListeners();

    try {
      _historyList = await _repository.getByRange(uid, start, end);
      // Urutkan terbaru dulu di paling atas, sesuai desain UI.
      _historyList.sort((a, b) => b.date.compareTo(a.date));
      _recalculatePeriodStats();
    } catch (e) {
      debugPrint('Load history error: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // ============ END TAMBAHAN ============
}