import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection('users');

  Future<List<AttendanceModel>> _getRiwayatFromArray(String uid) async {
    try {
      final doc = await _userRef.doc(uid).get();
      if (!doc.exists || doc.data() == null) return [];

      final userData = doc.data() as Map<String, dynamic>;
      final String namaUser = userData['nama'] ?? 'Karyawan';
      
      final List<dynamic>? riwayatRaw = userData['riwayatAbsensi'];
      if (riwayatRaw == null || riwayatRaw.isEmpty) return [];

      return riwayatRaw.map((item) {
        final map = item as Map<String, dynamic>;
        
        final Timestamp timestamp = map['waktu'] is Timestamp 
            ? map['waktu'] as Timestamp 
            : Timestamp.now();
        final DateTime dateTimeValue = timestamp.toDate();

        // 🔥 AMBIL JALUR JAM PULANG JIKA ADA DI DB
        final Timestamp? checkOutTimestamp = map['waktuCheckOut'];

        final convertedMap = {
          'uid': uid,
          'nama': namaUser,
          'date': dateTimeValue.toIso8601String(),
          'status': (map['statusHariIni'] ?? 'absen').toString().toLowerCase(),
          'officeName': userData['divisi'] ?? 'Kantor Pusat',
          'checkIn': dateTimeValue.toIso8601String(), 
          'checkOut': checkOutTimestamp != null 
              ? checkOutTimestamp.toDate().toIso8601String() 
              : null, // Mapped dari DB lo
        };

        return AttendanceModel.fromMap(convertedMap, '');
      }).toList();
    } catch (e) {
      print('Error parsing riwayat array: $e');
      return [];
    }
  }

  // 🔥 AMBIL DATA CUTI/IZIN YANG DI-ACC MANAGER UNTUK CARD "ABSEN"
  Future<int> getApprovedCutiIzinCount(String uid) async {
    try {
      final snapshot = await _userRef
          .doc(uid)
          .collection('cuti_izin')
          .where('status', isEqualTo: 'Setujui')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error get cuti_izin: $e');
      return 0;
    }
  }

  Future<AttendanceModel?> getByDate(String uid, DateTime date) async {
    final list = await _getRiwayatFromArray(uid);
    try {
      return list.firstWhere((a) =>
          a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day);
    } catch (_) {
      return null;
    }
  }

  Future<List<AttendanceModel>> getRecentByUid(String uid, {int limit = 10}) async {
    final list = await _getRiwayatFromArray(uid);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list.take(limit).toList();
  }

  Future<List<AttendanceModel>> getByRange(String uid, DateTime start, DateTime end) async {
    final list = await _getRiwayatFromArray(uid);
    final filtered = list.where((a) {
      return a.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
             a.date.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Future<void> checkIn(AttendanceModel attendance) async {
    final rawData = {
      'statusHariIni': 'Hadir',
      'waktu': Timestamp.fromDate(attendance.date),
      'lokasi': attendance.checkInLocation != null 
          ? '${attendance.checkInLocation!.lat}, ${attendance.checkInLocation!.lng}'
          : '',
      'waktuCheckOut': null, 
    };
    await _userRef.doc(attendance.uid).update({
      'riwayatAbsensi': FieldValue.arrayUnion([rawData])
    });
  }

  // 🔥 SIMPAN PULANG + LOGIKA BATAS KERJA 7 JAM (LEMBUR)
  Future<void> checkOut(
    String uid,
    DateTime date,
    DateTime checkOutTime,
    Map<String, dynamic> checkOutLocation,
    String? checkOutPhotoUrl,
  ) async {
    final doc = await _userRef.doc(uid).get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    List<dynamic> riwayat = List.from(data['riwayatAbsensi'] ?? []);

    if (riwayat.isNotEmpty) {
      Map<String, dynamic> lastRecord = Map<String, dynamic>.from(riwayat.last);
      
      // Ambil jam masuk awal untuk pembanding
      final Timestamp checkInTimestamp = lastRecord['waktu'];
      final DateTime checkInTime = checkInTimestamp.toDate();
      
      // Kalkulasi selisih waktu kerja
      final duration = checkOutTime.difference(checkInTime);
      
      lastRecord['waktuCheckOut'] = Timestamp.fromDate(checkOutTime);
      
      // Jika durasi kerja lebih dari atau sama dengan 7 jam, status jadi Lembur
      if (duration.inHours >= 7) {
        lastRecord['statusHariIni'] = 'Lembur';
      } else {
        lastRecord['statusHariIni'] = 'Hadir';
      }
      
      riwayat[riwayat.length - 1] = lastRecord;
      await _userRef.doc(uid).update({'riwayatAbsensi': riwayat});
    }
  }
}