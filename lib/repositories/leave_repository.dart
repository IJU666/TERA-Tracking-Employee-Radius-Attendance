import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_model.dart';

class LeaveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream seluruh pengajuan izin & cuti realtime untuk Manager
  Stream<List<LeaveModel>> streamAllLeaves() {
    return _firestore
        .collection('cuti_izin')
        .orderBy('tanggalMulai', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaveModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Memperbarui status pengajuan. Jika disetujui, otomatis menambah field statistik bulanan karyawan.
  Future<void> updateLeaveStatus({
    required String leaveId,
    required String employeeUid,
    required String status, // 'Disetujui' atau 'Ditolak'
    required String jenis,  // 'Cuti' atau 'Izin'
    String? keteranganManager,
  }) async {
    final leaveDocRef = _firestore.collection('cuti_izin').doc(leaveId);
    final userDocRef = _firestore.collection('users').doc(employeeUid);

    await _firestore.runTransaction((transaction) async {
      // 1. Update status di dokumen cuti_izin
      transaction.update(leaveDocRef, {
        'status': status,
        'keteranganManager': keteranganManager ?? '',
      });

      // 2. Jika disetujui, increment nilai ringkasanBulanan di users
      if (status == 'Disetujui') {
        // Tentukan field mana yang akan ditambahkan berdasarkan jenisnya
        final String targetField = jenis.toLowerCase() == 'cuti' 
            ? 'ringkasanBulanan.cuti' 
            : 'ringkasanBulanan.izin';

        transaction.update(userDocRef, {
          targetField: FieldValue.increment(1),
        });
      }
    });
  }
}