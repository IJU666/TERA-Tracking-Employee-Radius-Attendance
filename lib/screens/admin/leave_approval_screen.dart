import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // POP-UP DIALOG 1: Konfirmasi Setujui Permohonan Cuti
  void _showApproveDialog(String docId, String name, String dateRange) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'Setujui pengajuan ini?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(dateRange, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => _updateStatus(docId, 'Disetujui'),
                child: const Text('Ya, Setujui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // POP-UP DIALOG 2: Konfirmasi Tolak Permohonan Cuti + Alasan Penolakan
  void _showRejectDialog(String docId, String name, String type, String date) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFFFEBEE),
                child: Icon(Icons.close_rounded, color: Color(0xFFC62828), size: 48),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Tolak pengajuan ini?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '$name - $type ($date)',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Alasan penolakan (opsional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alasan...',
                hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
                fillColor: const Color(0xFFF5F5F5),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => _updateStatus(docId, 'Ditolak', alasan: reasonController.text.trim()),
                child: const Text('Ya, Tolak', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Eksekusi Update Status ke Firebase Firestore
  Future<void> _updateStatus(String docId, String status, {String alasan = ''}) async {
    Navigator.pop(context); // Tutup dialog konfirmasi
    
    try {
      final batch = FirebaseFirestore.instance.batch();
      final cutiRef = FirebaseFirestore.instance.collection('cuti_izin').doc(docId);
      
      // Update status di koleksi cuti_izin utama
      batch.update(cutiRef, {
        'status': status,
        'alasanPenolakan': alasan,
        'diprosesOleh': 'Admin',
        'tanggalDiproses': FieldValue.serverTimestamp(),
      });

      // Sinkronisasi status di dokumen notifikasi terkait jika ada
      final notifSnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('idReferensi', isEqualTo: docId)
          .get();

      for (var doc in notifSnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'statusAction': status,
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengajuan berhasil di-$status'),
            backgroundColor: status == 'Disetujui' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Persetujuan Cuti & Izin',
          style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF0D47A1),
          labelColor: const Color(0xFF0D47A1),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            const Tab(text: 'Semua'),
            // STREAMBUILDER BADGE HITUNG JUMLAH PENDING SECARA REALTIME DI TAB BAR
            Tab(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('cuti_izin').where('status', isEqualTo: 'Pending').snapshots(),
                builder: (context, snapshot) {
                  int pendingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Row(
                    children: [
                      const Text('Pending'),
                      if (pendingCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFE65100), borderRadius: BorderRadius.circular(10)),
                          child: Text('$pendingCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
                        )
                      ]
                    ],
                  );
                },
              ),
            ),
            const Tab(text: 'Disetujui'),
            const Tab(text: 'Ditolak'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Bar Pencarian Nama Karyawan
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari nama karyawan...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                fillColor: const Color(0xFFF1F3F4),
                filled: true,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaveStream('Semua'),
                _buildLeaveStream('Pending'),
                _buildLeaveStream('Disetujui'),
                _buildLeaveStream('Ditolak'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveStream(String filterStatus) {
    Query query = FirebaseFirestore.instance.collection('cuti_izin').orderBy('tanggalPengajuan', descending: true);

    if (filterStatus != 'Semua') {
      query = query.where('status', isEqualTo: filterStatus);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data?.docs ?? [];
        
        // Filter nama jika user mengetik di search bar
        if (_searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return (data['nama'] ?? '').toString().toLowerCase().contains(_searchQuery);
          }).toList();
        }

        // KONDISI EMPTY STATE (TAMPILAN JIKA TIDAK ADA DATA PADA KATEGORI INI)
        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                    child: Icon(Icons.mail_outline_rounded, size: 80, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Belum ada pengajuan pada kategori ini',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Semua pengajuan baru akan muncul di sini. Kami akan memberitahu Anda saat ada data yang masuk.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh, color: Color(0xFF0D47A1), size: 18),
                    label: const Text('Perbarui Data', style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var doc = docs[index];
            var data = doc.data() as Map<String, dynamic>;
            String docId = doc.id;
            String name = data['nama'] ?? '-';
            String position = data['jabatan'] ?? '-';
            String type = data['jenis'] ?? 'Cuti'; // Cuti / Izin
            String dateRange = data['rentangTanggal'] ?? '-';
            String duration = data['durasi'] ?? '-';
            String note = data['keterangan'] ?? '-';
            String status = data['status'] ?? 'Pending';
            String avatarUrl = data['avatarUrl'] ?? 'https://via.placeholder.com/150';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Atas: Profil Karyawan & Label Status Utama
                  Row(
                    children: [
                      CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatarUrl)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(position, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Label info Jenis Permohonan & Detail Tanggal
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: type == 'Cuti' ? const Color(0xFFF3E5F5) : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: type == 'Cuti' ? const Color(0xFF8E24AA) : const Color(0xFF2E7D32),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$dateRange • $duration',
                          style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Catatan Alasan dari Karyawan
                  Text(
                    '"$note"',
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 14),

                  // TAMPILAN TOMBOL AKSI JIKA STATUS MASIH 'PENDING'
                  if (status == 'Pending')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFC62828)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _showRejectDialog(docId, name, type, dateRange),
                            child: const Text('Tolak', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D47A1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            onPressed: () => _showApproveDialog(docId, name, dateRange),
                            child: const Text('Setujui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  else
                    // Log Keterangan Tambahan jika data sudah selesai diulas oleh admin
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              status == 'Disetujui'
                                  ? 'Diproses oleh Admin • Selesai'
                                  : 'Ditolak dengan alasan: ${data['alasanPenolakan'] ?? "-"}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    if (status == 'Pending') {
      bg = const Color(0xFFFFEBEE);
      text = const Color(0xFFE65100);
    } else if (status == 'Disetujui') {
      bg = const Color(0xFFE8F5E9);
      text = const Color(0xFF2E7D32);
    } else {
      bg = const Color(0xFFFFEBEE);
      text = const Color(0xFFC62828);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status,
        style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}