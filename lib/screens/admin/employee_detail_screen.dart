import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class EmployeeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> karyawanData;

  const EmployeeDetailScreen({super.key, required this.karyawanData});

  @override
  Widget build(BuildContext context) {
    var ringkasan = karyawanData['ringkasanBulanan'] ?? {'hadir': 0, 'telat': 0, 'izin': 0};
    List riwayat = karyawanData['riwayatAbsensi'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Riwayat',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.black)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(karyawanData['avatarUrl'] ?? 'https://via.placeholder.com/150'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          karyawanData['nama'] ?? '-',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('NIK: ${karyawanData['nik'] ?? '-'}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.badge_outlined, size: 12, color: Color(0xFF3F51B5)),
                              const SizedBox(width: 4),
                              Text(
                                (karyawanData['jabatan'] ?? '-').toUpperCase(),
                                style: const TextStyle(fontSize: 10, color: Color(0xFF3F51B5), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ringkasan Bulanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: const [
                      Text('Juni 2026 ', style: TextStyle(color: Color(0xFF0D47A1), fontSize: 12, fontWeight: FontWeight.bold)),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF0D47A1)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMonthlyStatCard('${ringkasan['hadir']}', 'Hadir', const Color(0xFFE8F5E9), const Color(0xFF2E7D32))),
                const SizedBox(width: 8),
                Expanded(child: _buildMonthlyStatCard('${ringkasan['telat']}', 'Telat', const Color(0xFFFFEBEE), const Color(0xFFC62828))),
                const SizedBox(width: 8),
                Expanded(child: _buildMonthlyStatCard('${ringkasan['izin']}', 'Izin', const Color(0xFFEEEEEE), Colors.black54)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Riwayat Absensi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Terbaru', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: riwayat.length,
              itemBuilder: (context, idx) {
                var item = riwayat[idx] as Map<String, dynamic>;
                return _buildRiwayatCard(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStatCard(String val, String label, Color itemBg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: itemBg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textCol)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> item) {
    String status = item['status'] ?? 'Hadir';
    Color badgeColor = const Color(0xFFE8F5E9);
    Color textColor = const Color(0xFF2E7D32);

    if (status == 'Terlambat') {
      badgeColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFC62828);
    } else if (status == 'Izin') {
      badgeColor = const Color(0xFFEEEEEE);
      textColor = Colors.black54;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['hari'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(item['tipeHari'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                child: Text(status, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 16),
          if (status != 'Izin') ...[
            Row(
              children: [
                Expanded(child: _buildTimeBox(Icons.login_rounded, 'Check-in', item['checkIn'] ?? '--:--', const Color(0xFFE3F2FD))),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeBox(Icons.logout_rounded, 'Check-out', item['checkOut'] ?? '--:--', const Color(0xFFEEEEEE))),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF0D47A1)),
                label: const Text('Lihat Lokasi', style: TextStyle(color: Color(0xFF0D47A1), fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            )
          ] else ...[
            Text(
              '"${item['catatan'] ?? ''}"',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54, fontSize: 13),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTimeBox(IconData icon, String title, String time, Color iconBg) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF0D47A1), size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        )
      ],
    );
  }
}