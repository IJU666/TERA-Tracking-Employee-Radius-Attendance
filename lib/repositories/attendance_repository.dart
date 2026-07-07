import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_model.dart';

/// Repository untuk data absensi di koleksi 'attendances'.
class AttendanceRepository {
  final CollectionReference _ref =
      FirebaseFirestore.instance.collection('attendances');

  String _dateId(String uid, DateTime date) {
    final d = '${date.year}${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    return '${uid}_$d';
  }

  /// Ambil data absensi untuk 1 tanggal tertentu (biasanya hari ini).
  Future<AttendanceModel?> getByDate(String uid, DateTime date) async {
    final doc = await _ref.doc(_dateId(uid, date)).get();
    if (!doc.exists) return null;
    return AttendanceModel.fromMap(
        doc.data() as Map<String, dynamic>, doc.id);
  }

  /// Ambil beberapa riwayat absensi terbaru milik seorang karyawan.
  Future<List<AttendanceModel>> getRecentByUid(String uid,
      {int limit = 10}) async {
    final snapshot = await _ref
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) =>
            AttendanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Ambil semua absensi milik karyawan dalam rentang tanggal (untuk
  /// ringkasan bulanan / history dengan filter).
  Future<List<AttendanceModel>> getByRange(
    String uid,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _ref
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) =>
            AttendanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Ambil semua absensi pada 1 tanggal (dipakai admin dashboard).
  Future<List<AttendanceModel>> getAll(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snapshot = await _ref
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThan: end.toIso8601String())
        .get();
    return snapshot.docs
        .map((doc) =>
            AttendanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> checkIn(AttendanceModel attendance) async {
    await _ref
        .doc(_dateId(attendance.uid, attendance.date))
        .set(attendance.toMap(), SetOptions(merge: true));
  }

  Future<void> checkOut(
    String uid,
    DateTime date,
    DateTime checkOutTime,
    Map<String, dynamic> checkOutLocation,
    String? checkOutPhotoUrl,
  ) async {
    await _ref.doc(_dateId(uid, date)).set({
      'checkOut': checkOutTime.toIso8601String(),
      'checkOutLocation': checkOutLocation,
      'checkOutPhotoUrl': checkOutPhotoUrl,
    }, SetOptions(merge: true));
  }
}
