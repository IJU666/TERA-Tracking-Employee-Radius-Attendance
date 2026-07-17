import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModel {
  final String id;
  final String uid;
  final String nama;
  final String divisi;
  final String alasan;
  final String type;
  final String status;
  final DateTime dateStart;
  final DateTime dateEnd;
  final DateTime createdAt;
  final String fileUrl;
  final String? keteranganManager;
  final String? namaManager; // 1. Tambahkan properti namaManager (nullable)

  LeaveModel({
    required this.id,
    required this.uid,
    required this.nama,
    required this.divisi,
    required this.alasan,
    required this.type,
    required this.status,
    required this.dateStart,
    required this.dateEnd,
    required this.createdAt,
    required this.fileUrl,
    this.keteranganManager,
    this.namaManager, // 2. Tambahkan di constructor
  });

  String get jenis => type;
  DateTime get tanggalMulai => dateStart;
  DateTime get tanggalSelesai => dateEnd;

  factory LeaveModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final pathSegments = doc.reference.path.split('/');
    String extractedUid = '';
    if (pathSegments.length >= 2) {
      extractedUid = pathSegments[1];
    }

    // Fungsi pembantu agar tidak crash jika tipe data di Firestore bukan Timestamp
    DateTime safeParseDate(dynamic field) {
      if (field is Timestamp) {
        return field.toDate();
      } else if (field is String) {
        return DateTime.tryParse(field) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return LeaveModel(
      id: doc.id,
      uid: extractedUid,
      nama: data['nama'] ?? 'Tanpa Nama',
      divisi: data['divisi'] ?? 'Karyawan',
      alasan: data['alasan'] ?? '',
      type: data['type'] ?? 'Izin',
      status: data['status'] ?? 'Pending',
      dateStart: safeParseDate(data['date_start']),
      dateEnd: safeParseDate(data['date_end']),
      createdAt: safeParseDate(data['created_at']),
      fileUrl: data['fileUrl'] ?? '',
      keteranganManager: data['keterangan_manager'],
      // 3. Ambil data dari key 'nama_manager' di Firestore
      namaManager: data['nama_manager'] ?? data['namaManager'], 
    );
  }
}