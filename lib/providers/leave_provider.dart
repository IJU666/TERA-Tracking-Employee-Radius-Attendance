import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // List menampung data riwayat cuti lokal setelah diambil dari database
  List<Map<String, dynamic>> _myLeaveRequests = [];
  List<Map<String, dynamic>> get myLeaveRequests => _myLeaveRequests;

  /// Fungsi untuk Mengirim Data Pengajuan Cuti/Izin ke Cloud Firestore
  Future<bool> createLeaveRequest({
    required String uid,
    required String nama,
    required String type,
    required DateTime dateStart,
    required DateTime dateEnd,
    required String alasan,
    Map<String, dynamic>? additionalInfo,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Menyimpan data langsung ke koleksi 'cuti_izin'
      await FirebaseFirestore.instance.collection('cuti_izin').add({
        'uid': uid,
        'nama': nama,
        'type': type,
        'dateStart': Timestamp.fromDate(dateStart), // Mengubah DateTime menjadi Timestamp Firestore
        'dateEnd': Timestamp.fromDate(dateEnd),
        'alasan': alasan,
        'status': 'Pending', // Status default awal untuk di-approve/reject oleh admin
        'createdAt': FieldValue.serverTimestamp(), // Waktu server saat dokumen dibuat
        ...?additionalInfo, // Memasukkan data tambahan seperti kontak_darurat atau fileUrl secara fleksibel
      });

      // Opsional: Refresh list riwayat lokal milik user setelah berhasil input data baru
      await fetchMyLeaveRequests(uid);
      
      return true; // Return true tanda operasi sukses masuk database
    } catch (e) {
      debugPrint("❌ ERROR SUBMIT LEAVE: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fungsi untuk Mengambil Seluruh Riwayat Pengajuan Cuti/Izin Milik Karyawan Tertentu
  Future<void> fetchMyLeaveRequests(String uid) async {
    _isLoading = true;
    // Menggunakan delayed zero agar tidak terjadi error bentrok build widget lifecycle
    Future.delayed(Duration.zero, () => notifyListeners());

    try {
      // Mengambil dokumen yang berisikan UID milik user bersangkutan dari koleksi cuti_izin
      final snapshot = await FirebaseFirestore.instance
          .collection('cuti_izin')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true) // Urutkan dari pengajuan paling baru
          .get();

      // Memetakan dokumen Firestore ke dalam objek list map lokal
      _myLeaveRequests = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Menyimpan ID Dokumen Firestore untuk kebutuhan update/delete nanti
        return data;
      }).toList();
      
    } catch (e) {
      debugPrint("❌ ERROR FETCH MY LEAVE: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}