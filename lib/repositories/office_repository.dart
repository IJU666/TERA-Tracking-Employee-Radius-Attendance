import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/office_model.dart';

class OfficeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Path dokumen tunggal di Firestore untuk konfigurasi kantor
  static const String _docPath = 'settings/office';

  // Dipanggil oleh Admin saat setting, maupun oleh Karyawan saat mau absen
  Future<OfficeModel?> getOffice() async {
    try {
      final doc = await _firestore.doc(_docPath).get();
      if (!doc.exists || doc.data() == null) return null;
      return OfficeModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('❌ Error di OfficeRepository.getOffice: $e');
      rethrow;
    }
  }

  Future<void> updateOffice(OfficeModel office) async {
    try {
      // merge: true menjaga dokumen agar aman jika ada penambahan field lain di masa depan
      await _firestore.doc(_docPath).set(office.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error di OfficeRepository.updateOffice: $e');
      rethrow;
    }
  }
}