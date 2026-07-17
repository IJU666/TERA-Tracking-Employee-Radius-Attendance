import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModel {
  final String id;
  final String employeeUid;
  final String jenis;             // 'Cuti' atau 'Izin'
  final String status;            // 'Pending', 'Disetujui', 'Ditolak'
  final String keteranganManager;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final String? alasan;

  LeaveModel({
    required this.id,
    required this.employeeUid,
    required this.jenis,
    required this.status,
    required this.keteranganManager,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.alasan,
  });

  // 🔥 TAMBAHKAN FUNGSI INI DI DALAM KELAS LEAVEMODEL KAMU
  factory LeaveModel.fromMap(Map<String, dynamic> map, String documentId) {
    return LeaveModel(
      id: documentId, // Mengambil ID dari doc.id sesuai panggian di repo
      employeeUid: map['employeeUid'] ?? map['uid'] ?? '', // Sesuaikan nama key di Firestore kamu
      jenis: map['jenis'] ?? 'Cuti',
      status: map['status'] ?? 'Pending',
      keteranganManager: map['keteranganManager'] ?? '',
      
      // Mengonversi Timestamp Firestore ke DateTime Dart secara aman
      tanggalMulai: map['tanggalMulai'] != null 
          ? (map['tanggalMulai'] as Timestamp).toDate() 
          : null,
      tanggalSelesai: map['tanggalSelesai'] != null 
          ? (map['tanggalSelesai'] as Timestamp).toDate() 
          : null,
          
      alasan: map['alasan'] ?? '',
    );
  }
}