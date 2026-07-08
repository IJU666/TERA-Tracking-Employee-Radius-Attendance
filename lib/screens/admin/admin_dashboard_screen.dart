import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/routes/app_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

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
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notification),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salam Pengguna
            const Text(
              'Selamat datang, Admin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 4),
            const Text(
              'Senin, 29 Juni 2026',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Grid Menu Utama (2x2)
            Row(
              children: [
                Expanded(
                  child: _buildGridCard(
                    icon: Icons.person_add_alt_1_outlined,
                    count: '142',
                    title: 'Akun Aktif',
                    subtitle: 'karyawan aktif hari ini',
                    bgColor: const Color(0xFFE3F2FD),
                    textColor: const Color(0xFF1565C0),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGridCard(
                    icon: Icons.people_alt_outlined,
                    count: '156',
                    title: 'Total Karyawan',
                    subtitle: 'total terdaftar',
                    bgColor: const Color(0xFFE8F5E9),
                    textColor: const Color(0xFF2E7D32),
                    // Navigasi ke Halaman Kelola Karyawan
                    onTap: () => Navigator.pushNamed(context, AppRoutes.employeeManagement),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGridCard(
                    icon: Icons.calendar_today_outlined,
                    count: '5',
                    title: 'Cuti & Izin',
                    subtitle: 'pengajuan pending',
                    bgColor: const Color(0xFFFFF3E0),
                    textColor: const Color(0xFFE65100),
                    hasNotificationDot: true,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.leaveApproval),
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

            // Daftar Aktivitas Terbaru (Hardcoded Placeholder sesuai Gambar Mockup)
            _buildActivityRow(
              name: 'Budi Santoso',
              desc: 'Absen Masuk • 08:14',
              status: 'Hadir',
              badgeBg: const Color(0xFFE8F5E9),
              badgeText: const Color(0xFF2E7D32),
              icon: Icons.login_rounded,
            ),
            const SizedBox(height: 12),
            _buildActivityRow(
              name: 'Ani Wijaya',
              desc: 'Pengajuan Cuti • 09:30',
              status: 'Pending',
              badgeBg: const Color(0xFFFFF3E0),
              badgeText: const Color(0xFFE65100),
              icon: Icons.calendar_today_rounded,
            ),
          ],
        ),
      ),

      // Custom Floating Action Button & Bottom Navigation Bar sesuai desain
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
              const SizedBox(width: 40), // Ruang kosong untuk notched FAB tengah
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

  // Widget Builder untuk Card Menu Grid
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

  // Widget Builder untuk Daftar Aktivitas di bagian bawah
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