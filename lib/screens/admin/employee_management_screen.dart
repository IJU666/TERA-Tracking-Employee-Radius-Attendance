import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'employee_detail_screen.dart';
import 'employee_form_screen.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  String selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // 🔥 Stream dibuat SEKALI di initState, bukan di build().
  // Kalau dibuat di build(), setiap setState() (misal saat ngetik di search box)
  // akan membuat instance Stream baru -> StreamBuilder unsubscribe-subscribe ulang
  // -> sempat balik ke ConnectionState.waiting -> layar kedip nampilin spinner.
  late final Stream<QuerySnapshot> _employeesStream = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'karyawan')
      .snapshots();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          onPressed: () {
            // Perbaikan tombol back
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.of(
                context,
              ).pop(); // Fallback langsung pop jika routes standar
            }
          },
        ),
        title: const Text(
          'Kelola Karyawan',
          style: TextStyle(
            color: Color(0xFF0D47A1),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, _, __) => const EmployeeFormScreen(),
              transitionsBuilder: (context, animation, _, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _employeesStream,
        builder: (context, snapshot) {
          // 🔥 Hanya tampilkan spinner full-screen saat BENAR-BENAR belum
          // pernah ada data sama sekali (initial load). Setelah itu, meskipun
          // stream reconnect/emit ulang, kita tetap pakai data lama agar
          // tidak flicker saat searchQuery/selectedFilter berubah.
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada data karyawan.'));
          }

          var docs = snapshot.data!.docs;

          int total = docs.length;
          int hadir = docs
              .where(
                (d) =>
                    (d.data() as Map<String, dynamic>)['statusHariIni'] ==
                    'Hadir',
              )
              .length;
          int absen = docs
              .where(
                (d) =>
                    (d.data() as Map<String, dynamic>)['statusHariIni'] ==
                    'Tidak Hadir',
              )
              .length;

          var filteredDocs = docs.where((d) {
            var data = d.data() as Map<String, dynamic>;
            String nama = (data['nama'] ?? '').toString().toLowerCase();
            String nik = (data['nik'] ?? '').toString().toLowerCase();
            bool matchesSearch =
                nama.contains(searchQuery.toLowerCase()) ||
                nik.contains(searchQuery.toLowerCase());

            if (!matchesSearch) return false;

            if (selectedFilter == 'Semua') return true;
            if (selectedFilter == 'Hadir')
              return data['statusHariIni'] == 'Hadir';
            if (selectedFilter == 'Tidak Hadir')
              return data['statusHariIni'] == 'Tidak Hadir';
            if (selectedFilter == 'Cuti')
              return data['statusHariIni'] == 'Izin/Cuti';
            return true;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        '$total',
                        'TOTAL',
                        const Color(0xFFF1F3F9),
                        const Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        '$hadir',
                        'HADIR',
                        const Color(0xFFE8F5E9),
                        const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        '$absen',
                        'ABSEN',
                        const Color(0xFFFFEBEE),
                        const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau NIK...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    fillColor: const Color(0xFFF1F3F4),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Semua', 'Hadir', 'Tidak Hadir', 'Cuti'].map((
                      filter,
                    ) {
                      bool isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0D47A1),
                          backgroundColor: const Color(0xFFEEEEEE),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'DAFTAR KARYAWAN (${filteredDocs.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    return _buildKaryawanCard(context, doc.id, data);
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String count,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKaryawanCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    Color badgeColor;
    Color textColor;
    String status = data['statusHariIni'] ?? 'Hadir';

    if (status == 'Hadir') {
      badgeColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
    } else if (status == 'Tidak Hadir') {
      badgeColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFC62828);
    } else {
      badgeColor = const Color(0xFFFFE0B2);
      textColor = const Color(0xFFE65100);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EmployeeDetailScreen(docId: docId, karyawanData: data),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundImage: NetworkImage(
            data['avatarUrl'] ?? 'https://via.placeholder.com/150',
          ),
        ),
        title: Text(
          data['nama'] ?? '-',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data['nik'] ?? '-',
                  style: const TextStyle(fontSize: 11, color: Colors.black),
                ),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['jabatan'] ?? '-',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status == 'Hadir') ...[
                    const CircleAvatar(
                      radius: 3,
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    status,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.more_vert, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
