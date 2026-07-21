import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../models/check_point_model.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/office_repository.dart';

enum AttendanceHistoryFilter { today, thisWeek, thisMonth }

class AttendanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final AttendanceRepository _repository = AttendanceRepository();
  final OfficeRepository _officeRepository = OfficeRepository();

  // 🟢 Tentukan status hadir/terlambat berdasarkan jam hadir + toleransi kantor
  Future<String> _resolveCheckInStatus(DateTime now) async {
    try {
      final office = await _officeRepository.getOffice();
      final jamMasuk = (office?.jamMasuk != null && office!.jamMasuk!.contains(':'))
          ? office.jamMasuk!
          : '08:00';
      final toleransi = office?.toleransi ?? 15;

      final parts = jamMasuk.split(':');
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      final batas = DateTime(now.year, now.month, now.day, hour, minute)
          .add(Duration(minutes: toleransi));

      return now.isAfter(batas) ? 'terlambat' : 'hadir';
    } catch (e) {
      debugPrint('Gagal mengambil jam hadir kantor, pakai default 09:00: $e');
      return now.hour >= 9 ? 'terlambat' : 'hadir';
    }
  }

  AttendanceModel? _todayAttendance;
  AttendanceModel? get todayAttendance => _todayAttendance;

  List<AttendanceModel> _attendanceHistory = [];
  List<AttendanceModel> get attendanceHistory => _attendanceHistory;

  List<AttendanceModel> get recentHistory => _attendanceHistory;
  AttendanceModel? get lastAttendance =>
      _attendanceHistory.isNotEmpty ? _attendanceHistory.first : null;

  int _monthlyHadir = 0;
  int _monthlyLembur = 0;
  int _monthlyAbsen = 0;

  int get monthlyHadir => _monthlyHadir;
  int get monthlyLembur => _monthlyLembur;
  int get monthlyAbsen => _monthlyAbsen;

  int remainingLeaveDays = 12;

  static const int _workingDaysAssumption = 22;

  double get hadirProgress =>
      (_monthlyHadir / _workingDaysAssumption).clamp(0.0, 1.0);
  double get lemburProgress =>
      (_monthlyLembur / _workingDaysAssumption).clamp(0.0, 1.0);
  double get absenProgress =>
      (_monthlyAbsen / _workingDaysAssumption).clamp(0.0, 1.0);

  // 🔥 Getter untuk cek apakah user sudah absen masuk tetapi belum pulang hari ini
  bool get isAlreadyCheckIn =>
      _todayAttendance != null &&
      _todayAttendance!.checkIn != null &&
      _todayAttendance!.checkOut == null;

  // 🔥 Getter untuk cek apakah user sudah menyelesaikan absen masuk DAN
  // checkout hari ini. Berbeda dengan isAlreadyCheckIn (yang jadi false lagi
  // setelah checkout), getter ini tetap true sepanjang hari itu supaya
  // tombol absen tidak bisa ditekan lagi setelah siklus absen selesai.
  bool get hasCompletedToday =>
      _todayAttendance != null &&
      _todayAttendance!.checkIn != null &&
      _todayAttendance!.checkOut != null;

  // 🔥 Mengikuti alur status yang lebih dinamis setelah check-out
  String get todayStatusLabel {
    if (_todayAttendance == null || _todayAttendance!.checkIn == null) {
      return 'Belum Absen';
    }
    if (_todayAttendance!.checkOut != null) {
      return _todayAttendance!.status == 'lembur'
          ? 'Lembur Selesai'
          : 'Selesai Kerja';
    }
    return 'Sudah Masuk';
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Fungsi satu pintu untuk memuat semua kebutuhan data HomeScreen
  Future<void> loadAllHomeData() async {
    final uid = _uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadTodayStatusSilent(),
        _loadRecentHistorySilent(),
        _loadMonthlySummarySilent(),
      ]);
    } catch (e) {
      debugPrint('Gagal memuat semua data beranda: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTodayStatusSilent() async {
    try {
      final uid = _uid;
      if (uid != null) {
        _todayAttendance = await _repository.getByDate(uid, DateTime.now());
      }
    } catch (e) {
      debugPrint('Error _loadTodayStatusSilent: $e');
    }
  }

  Future<void> _loadRecentHistorySilent({int limit = 5}) async {
    try {
      final uid = _uid;
      if (uid != null) {
        _attendanceHistory =
            await _repository.getRecentByUid(uid, limit: limit);
      }
    } catch (e) {
      debugPrint('Error _loadRecentHistorySilent: $e');
    }
  }

  // 🔥 Perhitungan statistik bulanan agar sinkron dengan subkoleksi cuti_izin
  Future<void> _loadMonthlySummarySilent() async {
    try {
      final uid = _uid;
      if (uid == null) return;

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final monthData = await _repository.getByRange(uid, start, end);

      _monthlyHadir = monthData
          .where((a) => a.status == 'hadir' || a.status == 'terlambat')
          .length;

      // Ambil data lembur yang asalnya dari kalkulasi kerja >= 7 jam
      _monthlyLembur = monthData.where((a) => a.status == 'lembur').length;

      // Ambil langsung jumlah izin/cuti yang berstatus "Setujui" dari repositori
      _monthlyAbsen = await _repository.getApprovedCutiIzinCount(uid);
    } catch (e) {
      debugPrint('Error _loadMonthlySummarySilent: $e');
    }
  }

  Future<void> loadTodayStatus() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      _todayAttendance = await _repository.getByDate(uid, DateTime.now());
    } catch (e) {
      debugPrint('Load today status error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadRecentHistory({int limit = 5}) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      _attendanceHistory = await _repository.getRecentByUid(uid, limit: limit);
    } catch (e) {
      debugPrint('Load recent history error: $e');
    } finally {
      notifyListeners();
    }
  }

  // 🔥 Sinkronisasi untuk method publik loadMonthlySummary
  Future<void> loadMonthlySummary() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final monthData = await _repository.getByRange(uid, start, end);

      _monthlyHadir = monthData
          .where((a) => a.status == 'hadir' || a.status == 'terlambat')
          .length;
      _monthlyLembur = monthData.where((a) => a.status == 'lembur').length;
      _monthlyAbsen = await _repository.getApprovedCutiIzinCount(uid);
    } catch (e) {
      debugPrint('Load monthly summary error: $e');
    } finally {
      notifyListeners();
    }
  }

  bool _isWithinRadius(double lat, double lng) {
    return true;
  }

  Future<String> _uploadPhoto(String imagePath) async {
    return imagePath;
  }

  Future<bool> checkIn(double lat, double lng, String imagePath, {String? officeName}) async {
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
      final status = await _resolveCheckInStatus(now);

      final attendance = AttendanceModel(
        id: '',
        uid: uid,
        nama: FirebaseAuth.instance.currentUser?.displayName ?? '-',
        date: now,
        status: status,
        officeName: officeName ?? 'Kantor Pusat',
        checkIn: now,
        checkInLocation: CheckPointModel(
          timestamp: now,
          lat: lat,
          lng: lng,
          distance: 0,
        ),
        checkInPhotoUrl: photoUrl,
      );

      await _repository.checkIn(attendance);
      _todayAttendance = attendance;

      await loadAllHomeData();
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

      await loadAllHomeData();
      return true;
    } catch (e) {
      debugPrint('Check-out error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ PENANGANAN HALAMAN RIWAYAT (HISTORY SCREEN) ============
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

  Future<void> loadHistoryByFilter(
      {required AttendanceHistoryFilter filter}) async {
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
            mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day);
        break;
      case AttendanceHistoryFilter.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
    }
    await loadHistoryByRange(start: start, end: end);
  }

  Future<void> loadHistoryByRange(
      {required DateTime start, required DateTime end}) async {
    final uid = _uid;
    if (uid == null) return;

    _isLoadingHistory = true;
    notifyListeners();

    try {
      _historyList = await _repository.getByRange(uid, start, end);
      _historyList.sort((a, b) => b.date.compareTo(a.date));
      _recalculatePeriodStats();
    } catch (e) {
      debugPrint('Load history error: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // 💡 Catatan: Method doCheckOut ini tetap dipertahankan tanpa parameter
  // agar CheckOutScreen lo gak error saat memanggilnya.
  Future<void> doCheckOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadAllHomeData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}