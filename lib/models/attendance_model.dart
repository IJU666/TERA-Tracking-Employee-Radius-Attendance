import 'check_point_model.dart';

/// Model data absensi harian seorang karyawan.
class AttendanceModel {
  final String id;
  final String uid;
  final String nama;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status;
  final String officeName;
  final CheckPointModel? checkInLocation;
  final CheckPointModel? checkOutLocation;
  final String? checkInPhotoUrl;
  final String? checkOutPhotoUrl;
  final String? leaveNote; // TAMBAHAN: catatan izin/cuti, contoh "Acara Keluarga - Sudah disetujui HRD"

  const AttendanceModel({
    required this.id,
    required this.uid,
    required this.nama,
    required this.date,
    required this.status,
    required this.officeName,
    this.checkIn,
    this.checkOut,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInPhotoUrl,
    this.checkOutPhotoUrl,
    this.leaveNote, // TAMBAHAN
  });

  String get statusLabel {
    switch (status) {
      case 'hadir':
        return 'Hadir';
      case 'terlambat':
        return 'Terlambat';
      case 'izin':
        return 'Izin';
      case 'cuti':
        return 'Cuti';
      default:
        return 'Absen';
    }
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      uid: map['uid'] ?? '',
      nama: map['nama'] ?? '',
      date: DateTime.parse(map['date']),
      checkIn: map['checkIn'] != null ? DateTime.parse(map['checkIn']) : null,
      checkOut: map['checkOut'] != null ? DateTime.parse(map['checkOut']) : null,
      status: map['status'] ?? 'absen',
      officeName: map['officeName'] ?? '-',
      checkInLocation: map['checkInLocation'] != null
          ? CheckPointModel.fromMap(Map<String, dynamic>.from(map['checkInLocation']))
          : null,
      checkOutLocation: map['checkOutLocation'] != null
          ? CheckPointModel.fromMap(Map<String, dynamic>.from(map['checkOutLocation']))
          : null,
      checkInPhotoUrl: map['checkInPhotoUrl'],
      checkOutPhotoUrl: map['checkOutPhotoUrl'],
      leaveNote: map['leaveNote'], // TAMBAHAN
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'date': date.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'status': status,
      'officeName': officeName,
      'checkInLocation': checkInLocation?.toMap(),
      'checkOutLocation': checkOutLocation?.toMap(),
      'checkInPhotoUrl': checkInPhotoUrl,
      'checkOutPhotoUrl': checkOutPhotoUrl,
      'leaveNote': leaveNote, // TAMBAHAN
    };
  }
}
