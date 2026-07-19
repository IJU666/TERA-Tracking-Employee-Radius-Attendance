import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/leave_model.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class LeaveProvider with ChangeNotifier {
  // 1. Inisialisasi Firestore disatukan agar tidak ada duplikasi variabel
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Dipakai untuk menulis notifikasi ke karyawan saat status diupdate.
  final NotificationRepository _notificationRepository =
      NotificationRepository();

  // State untuk indikator loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // =====================================================================
  // FUNGSI 1: STREAM REALTIME - DENGAN SORTING CLIENT-SIDE (TANPA INDEX)
  // =====================================================================
  Stream<List<LeaveModel>> get allLeavesStream {
    return _db
        .collectionGroup('cuti_izin')
        .snapshots()
        .map((snapshot) {
      
      // === LOG DEBUG UNTUK TERMINAL ===
      debugPrint('==================================================');
      debugPrint('STATUS: Stream cuti_izin aktif!');
      debugPrint('JUMLAH DOKUMEN DI FIRESTORE: ${snapshot.docs.length}');
      if (snapshot.docs.isNotEmpty) {
        debugPrint('CONTOH DATA PERTAMA: ${snapshot.docs.first.data()}');
      }
      debugPrint('==================================================');

      final list = snapshot.docs.map((doc) {
        try {
          return LeaveModel.fromFirestore(doc);
        } catch (e) {
          debugPrint('Gagal konversi dokumen ${doc.id}: $e');
          rethrow;
        }
      }).toList();

      // Urutkan secara manual di memori HP/Browser (terbaru di atas)
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return list;
    });
  }

  // =====================================================================
  // FUNGSI 2: MEMBUAT PENGAJUAN CUTI/IZIN BARU
  // =====================================================================
  Future<bool> createLeaveRequest({
    required String uid,
    required String nama,
    required String type,
    required DateTime dateStart,
    required DateTime dateEnd,
    required String alasan,
    required Map<String, dynamic> additionalInfo,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = {
        'nama': nama,
        'type': type, 
        'date_start': Timestamp.fromDate(dateStart),
        'date_end': Timestamp.fromDate(dateEnd),
        'alasan': alasan,
        'status': 'Pending',
        'created_at': FieldValue.serverTimestamp(),
        ...additionalInfo, 
      };

      // Simpan ke subcollection milik user yang sedang login
      await _db
          .collection('users')
          .doc(uid)
          .collection('cuti_izin')
          .add(data);

      /* 
       * 🔴 PROTEKSI LOGIKA SALDO CUTI: 
       * Bagian ini dinonaktifkan untuk mencegah DOUBLE DEDUCTION.
       * Saldo cuti HANYA akan dipotong melalui fungsi updateLeaveStatus() 
       * ketika status berubah menjadi "Disetujui".
       */
      // if (type == 'Cuti') {
      //   int durasi = dateEnd.difference(dateStart).inDays + 1;
      //   await _db.collection('users').doc(uid).update({
      //     'sisa_cuti': FieldValue.increment(-durasi),
      //   });
      // }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error saat membuat pengajuan: $e');
      return false;
    }
  }

  // =====================================================================
  // FUNGSI 3: MENYETUJUI / MENOLAK PENGAJUAN (UPDATE STATUS)
  // =====================================================================
  Future<bool> updateLeaveStatus({
    required String leaveId,
    required String employeeUid,
    required String status,
    required String jenis,
    required String keteranganManager,
    String? namaManager, 
  }) async {
    try {
      final leaveRef = _db
          .collection('users')
          .doc(employeeUid)
          .collection('cuti_izin')
          .doc(leaveId);

      final leaveDoc = await leaveRef.get();
      if (!leaveDoc.exists) return false;

      final data = leaveDoc.data() as Map<String, dynamic>;
      final String statusLama = data['status'] ?? 'Pending';

      // Simpan pembaruan status dan data manager ke Firestore
      await leaveRef.update({
        'status': status,
        'keterangan_manager': keteranganManager,
        'nama_manager': namaManager, 
      });

      // Logika pengurangan sisa cuti jika disetujui (AMAN)
      if (status == 'Disetujui' && 
          statusLama != 'Disetujui' && 
          jenis.toLowerCase().contains('cuti')) {
        
        final DateTime start = (data['date_start'] as Timestamp).toDate();
        final DateTime end = (data['date_end'] as Timestamp).toDate();
        
        int totalHariCuti = end.difference(start).inDays + 1;

        final userRef = _db.collection('users').doc(employeeUid);

        await userRef.update({
          'sisa_cuti': FieldValue.increment(-totalHariCuti),
        });
      }

      // =================================================================
      // 🔔 BAGIAN BARU: kirim notifikasi ke karyawan setelah status
      // berhasil diupdate. Sebelumnya tidak ada, makanya
      // employee_notification_screen.dart selalu kosong walau status di
      // Firestore sudah berubah.
      //
      // `type` di NotificationModel di-map jadi salah satu dari:
      // 'cuti_disetujui' | 'cuti_ditolak' | 'izin_disetujui' | 'izin_ditolak'
      // — ini harus PERSIS sama dengan yang dicek di
      // _EmployeeNotificationTile._visual (employee_notification_screen.dart),
      // supaya ikon & badge "Disetujui"/"Ditolak" muncul dengan benar.
      // =================================================================
      final bool isApproved = status == 'Disetujui' || status == 'Setujui';
      final String jenisLower =
          jenis.toLowerCase().contains('cuti') ? 'cuti' : 'izin';
      final String jenisLabel = jenisLower == 'cuti' ? 'Cuti' : 'Izin';
      final String namaManagerFinal =
          (namaManager != null && namaManager.isNotEmpty)
              ? namaManager
              : 'Manager';

      try {
        await _notificationRepository.create(
          employeeUid,
          NotificationModel(
            id: '',
            title: 'Pengajuan $jenisLabel '
                '${isApproved ? "Disetujui" : "Ditolak"}',
            body: isApproved
                ? 'Pengajuan $jenisLabel kamu telah disetujui oleh '
                    '$namaManagerFinal.'
                : 'Pengajuan $jenisLabel kamu ditolak oleh '
                    '$namaManagerFinal.'
                    '${keteranganManager.isNotEmpty ? " Catatan: $keteranganManager" : ""}',
            type: '${jenisLower}_${isApproved ? "disetujui" : "ditolak"}',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      } catch (e) {
        // Sengaja tidak menggagalkan seluruh proses approve/reject kalau
        // notifikasinya gagal terkirim (misal karena error jaringan) —
        // status leave-nya sendiri sudah berhasil diupdate di atas.
        debugPrint('Gagal mengirim notifikasi ke karyawan: $e');
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Gagal memperbarui status cuti: $e');
      return false;
    }
  }
} 