import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Tambahkan import Auth untuk nama login
import 'package:tugas_besar/screens/notification/notification_screen.dart';
import '../../core/routes/app_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  String _adminName = 'Admin'; // Nama default jika tidak terdeteksi

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

  // Fungsi mengambil nama admin yang sedang login dari Firebase Auth / Firestore
  Future<void> _loadAdminProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Jika nama ada di profil Firebase Auth
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          setState(() => _adminName = user.displayName!);
        } else {
          // Atau jika Anda menyimpan data admin di koleksi 'karyawan' / 'users' di Firestore
          var adminDoc = await FirebaseFirestore.instance.collection('karyawan').doc(user.uid).get();
          if (adminDoc.exists && adminDoc.data()?['nama'] != null) {
            setState(() => _adminName = adminDoc.data()?['nama']);
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal memuat nama admin: $e');
    }
  }

  // Helper untuk mendapatkan format string tanggal hari ini
  String _getFormattedDate() {
    DateTime now = DateTime.now();
    List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    List<String> days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    
    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28),
            onPressed: () => Navigator.push(context, 
            MaterialPageRoute(builder: (context) => const NotificationScreen()),
            )
          ),
          const SizedBox(width: 8),
        ],
      ),
      // MENGGUNAKAN STREAMBUILDER UTAMA AGAR KARTU GRID TERUPDATE REALTIME DARI DATABASE
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('karyawan').snapshots(),
        builder: (context, snapshot) {
          int totalKaryawan = 0;
          int akunAktif = 0; // Karyawan dengan status 'Hadir' hari ini

          if (snapshot.hasData && snapshot.data != null) {
            var docs = snapshot.data!.docs;
            totalKaryawan = docs.length;
            akunAktif = docs.where((d) {
              var data = d.data() as Map<String, dynamic>;
              return data['statusHariIni'] == 'Hadir';
            }).length;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salam Pengguna Dinamis sesuai User Login
                Text(
                  'Selamat datang, $_adminName',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 4),
                // Tanggal Otomatis Mengikuti Waktu HP Aktual
                Text(
                  _getFormattedDate(),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Grid Menu Utama (2x2) Datanya Terhubung Realtime
                Row(
                  children: [
                    Expanded(
                      child: _buildGridCard(
                        icon: Icons.person_add_alt_1_outlined,
                        count: '$akunAktif', // Mengambil data hadir dari Firebase
                        title: 'Akun Aktif',
                        subtitle: 'karyawan aktif hari ini',
                        bgColor: const Color(0xFFE3F2FD),
                        textColor: const Color(0xFF1565C0),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.employeeManagement),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGridCard(
                        icon: Icons.people_alt_outlined,
                        count: '$totalKaryawan', // Mengambil total dari Firebase
                        title: 'Total Karyawan',
                        subtitle: 'total terdaftar',
                        bgColor: const Color(0xFFE8F5E9),
                        textColor: const Color(0xFF2E7D32),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.employeeManagement),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      // STREAMBUILDER KHUSUS UNTUK MENGHITUNG PENGAJUAN CUTI YANG PENDING
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('cuti_izin') // Sesuaikan nama koleksi cuti di Firebase Anda
                            .where('status', isEqualTo: 'Pending')
                            .snapshots(),
                        builder: (context, cutiSnapshot) {
                          int totalCutiPending = 0;
                          if (cutiSnapshot.hasData && cutiSnapshot.data != null) {
                            totalCutiPending = cutiSnapshot.data!.docs.length;
                          }

                          return _buildGridCard(
                            icon: Icons.calendar_today_outlined,
                            count: '$totalCutiPending', // Mengambil jumlah cuti pending
                            title: 'Cuti & Izin',
                            subtitle: 'pengajuan pending',
                            bgColor: const Color(0xFFFFF3E0),
                            textColor: const Color(0xFFE65100),
                            hasNotificationDot: totalCutiPending > 0,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.leaveApproval),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.location_on_outlined, color: Colors.black54),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                                  child: const Text('50m Radius', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Lat: -6.9147', style: TextStyle(fontSize: 11, color: Colors.black54, fontFamily: 'monospace')),
                                Text('Long: 107.6098', style: TextStyle(fontSize: 11, color: Colors.black54, fontFamily: 'monospace')),
                              ],
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 32,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D47A1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.officeSetting),
                                child: const Text('Edit Lokasi', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Aktivitas Terbaru Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Aktivitas Terbaru',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.employeeManagement),
                      child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 8),

                // Menampilkan daftar riwayat aktivitas karyawan terbaru yang didapat dari database
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  const Text('Belum ada aktivitas karyawan hari ini.', style: TextStyle(color: Colors.grey, fontSize: 13))
                else
                  Builder(
                    builder: (context) {
                      // Ambil karyawan yang statusnya selain 'Tidak Hadir' sebagai log aktivitas sederhana
                      var aktifDocs = snapshot.data!.docs.where((d) {
                        var data = d.data() as Map<String, dynamic>;
                        return data['statusHariIni'] != 'Tidak Hadir';
                      }).toList();

                      if (aktifDocs.isEmpty) {
                        return const Text('Belum ada aktivitas masuk/izin hari ini.', style: TextStyle(color: Colors.grey, fontSize: 13));
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: aktifDocs.length > 3 ? 3 : aktifDocs.length, // Batasi maks 3 baris di dashboard
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          var data = aktifDocs[index].data() as Map<String, dynamic>;
                          String status = data['statusHariIni'] ?? 'Hadir';
                          
                          return _buildActivityRow(
                            name: data['nama'] ?? '-',
                            desc: '${data['jabatan'] ?? '-'} • Status Hari Ini',
                            status: status,
                            badgeBg: status == 'Hadir' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                            badgeText: status == 'Hadir' ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                            icon: status == 'Hadir' ? Icons.login_rounded : Icons.calendar_today_rounded,
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),

      // Custom Floating Action Button & Bottom Navigation Bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.employeeManagement),
        backgroundColor: const Color(0xFF0D47A1),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: _currentIndex == 0 ? const Color(0xFF0D47A1) : Colors.grey),
                onPressed: () => setState(() => _currentIndex = 0),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Icon(Icons.settings, color: _currentIndex == 1 ? const Color(0xFF0D47A1) : Colors.grey),
                onPressed: () {
                  setState(() => _currentIndex = 1);
                  Navigator.pushNamed(context, AppRoutes.setting);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required IconData icon,
    required String count,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color textColor,
    bool hasNotificationDot = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: textColor, size: 24),
                ),
                if (hasNotificationDot)
                  const CircleAvatar(radius: 4, backgroundColor: Colors.red),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow({
    required String name,
    required String desc,
    required String status,
    required Color badgeBg,
    required Color badgeText,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFF1F3F4),
            child: Icon(icon, color: const Color(0xFF0D47A1), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)),
            child: Text(
              status,
              style: TextStyle(color: badgeText, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}