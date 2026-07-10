import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Menandai semua notifikasi sebagai telah dibaca
  Future<void> _markAllAsRead() async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshots = await FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshots.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Aksi tombol untuk Reset Password
  Future<void> _handleResetPassword(String docId, String email) async {
    // Tambahkan logika reset password auth Anda di sini jika ada
    await FirebaseFirestore.instance.collection('notifications').doc(docId).update({
      'isRead': true,
      'statusAction': 'Selesai',
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permintaan reset password $email diproses.')),
      );
    }
  }

  // Aksi tombol untuk Persetujuan Cuti & Izin
  Future<void> _handleLeaveAction(String docId, String idReferensi, String status) async {
    final batch = FirebaseFirestore.instance.batch();
    
    // Update status di dokumen notifikasi
    batch.update(FirebaseFirestore.instance.collection('notifications').doc(docId), {
      'isRead': true,
      'statusAction': status,
    });

    // Update status di koleksi cuti utama jika ada idReferensi dokumen cutinya
    if (idReferensi.isNotEmpty) {
      batch.update(FirebaseFirestore.instance.collection('cuti_izin').doc(idReferensi), {
        'status': status,
      });
    }

    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengajuan cuti berhasil di-$status'),
          backgroundColor: status == 'Disetujui' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // Format waktu readable (misal: "10 menit lalu", "1 jam lalu", "Kemarin, 15:30")
  String _getReadableTime(Timestamp timestamp) {
    DateTime notificationDate = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(notificationDate);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24 && notificationDate.day == now.day) {
      return '${difference.inHours} jam lalu';
    } else if (notificationDate.day == now.subtract(const Duration(days: 1)).day) {
      return 'Kemarin, ${DateFormat('HH:mm').format(notificationDate)}';
    } else {
      return DateFormat('dd MMMM yyyy, HH:mm').format(notificationDate);
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
          'Notifikasi',
          style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Tandai semua dibaca',
              style: TextStyle(color: Color(0xFF1976D2), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF0D47A1),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          labelColor: const Color(0xFF0D47A1),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Lupa Password'),
            Tab(text: 'Cuti & Izin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationStream('Semua'),
          _buildNotificationStream('Lupa Password'),
          _buildNotificationStream('Cuti & Izin'),
        ],
      ),
    );
  }

  Widget _buildNotificationStream(String category) {
    Query query = FirebaseFirestore.instance.collection('notifications').orderBy('createdAt', descending: true);

    if (category != 'Semua') {
      query = query.where('category', isEqualTo: category);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada notifikasi.', style: TextStyle(color: Colors.grey)));
        }

        var docs = snapshot.data!.docs;
        
        // Memisahkan data Hari ini dan Kemarin/Lalu
        List<QueryDocumentSnapshot> todayItems = [];
        List<QueryDocumentSnapshot> olderItems = [];

        DateTime now = DateTime.now();

        for (var doc in docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['createdAt'] != null) {
            DateTime date = (data['createdAt'] as Timestamp).toDate();
            if (date.day == now.day && date.month == now.month && date.year == now.year) {
              todayItems.add(doc);
            } else {
              olderItems.add(doc);
            }
          }
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            if (todayItems.isNotEmpty) ...[
              _buildSectionHeader('HARI INI'),
              ...todayItems.map((doc) => _buildNotificationCard(doc)),
            ],
            if (olderItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader('KEMARIN'),
              ...olderItems.map((doc) => _buildNotificationCard(doc)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildNotificationCard(QueryDocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    String docId = doc.id;
    String type = data['category'] ?? '';
    bool isRead = data['isRead'] ?? false;
    String statusAction = data['statusAction'] ?? 'Pending';
    Timestamp timestamp = data['createdAt'] ?? Timestamp.now();

    IconData iconData = Icons.notifications;
    Color iconBgColor = Colors.grey[100]!;
    Color iconColor = Colors.grey;

    if (type == 'Lupa Password') {
      iconData = Icons.lock_reset_rounded;
      iconBgColor = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFC62828);
    } else if (type == 'Cuti & Izin') {
      iconData = Icons.calendar_today_rounded;
      iconBgColor = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFE65100);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lingkaran Icon Kiri
          CircleAvatar(
            radius: 24,
            backgroundColor: iconBgColor,
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          
          // Konten Tengah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? '-',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  data['subtitle'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _getReadableTime(timestamp),
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
                
                // Menampilkan tombol aksi interaktif jika statusnya masih 'Pending'
                if (statusAction == 'Pending') ...[
                  const SizedBox(height: 12),
                  if (type == 'Lupa Password')
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0D47A1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () => _handleResetPassword(docId, data['subtitle'] ?? ''),
                      child: const Text('Reset Password', style: TextStyle(color: Color(0xFF0D47A1), fontSize: 13, fontWeight: FontWeight.bold)),
                    )
                  else if (type == 'Cuti & Izin')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFC62828)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _handleLeaveAction(docId, data['idReferensi'] ?? '', 'Ditolak'),
                            child: const Text('Tolak', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B5E20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            onPressed: () => _handleLeaveAction(docId, data['idReferensi'] ?? '', 'Disetujui'),
                            child: const Text('Setujui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                ] else ...[
                  // Menampilkan teks label jika aksi sudah selesai diproses
                  const SizedBox(height: 8),
                  Text(
                    statusAction == 'Disetujui' || statusAction == 'Selesai' 
                        ? '✓ Permintaan telah disetujui' 
                        : '✕ Permintaan ditolak',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusAction == 'Ditolak' ? Colors.red : Colors.green),
                  )
                ]
              ],
            ),
          ),
          
          // Dot Indikator Belum Dibaca (Warna Biru Kanan Atas)
          if (!isRead)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: CircleAvatar(radius: 4, backgroundColor: Color(0xFF0D47A1)),
            ),
        ],
      ),
    );
  }
}