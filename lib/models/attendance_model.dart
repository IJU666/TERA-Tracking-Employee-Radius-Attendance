import 'package:cloud_firestore/cloud_firestore.dart'; // Wajib diimport untuk mendeteksi Timestamp
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
  final String? leaveNote; // Catatan izin/cuti

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
    this.leaveNote,
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

  // 🔥 Fungsi pengaman untuk mengonversi Timestamp / String dari Firestore ke DateTime secara dinamis
  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now(); // Fallback keamanan jika data kosong atau rusak
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      uid: map['uid'] ?? '',
      nama: map['nama'] ?? '',
      date: _parseDateTime(map['date']),
      checkIn: _parseNullableDateTime(map['checkIn']),
      checkOut: _parseNullableDateTime(map['checkOut']),
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
      leaveNote: map['leaveNote'],
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
      'leaveNote': leaveNote,
    };
  }
}