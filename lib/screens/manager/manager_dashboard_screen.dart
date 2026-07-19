import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/leave_model.dart';
import '../../providers/leave_provider.dart';
import '../../core/routes/app_routes.dart';


class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _currentIndex = 0;
  String _managerName = 'Manager';

  // State untuk Pagination
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadManagerProfile();
  }

  Future<void> _loadManagerProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          setState(() => _managerName = user.displayName!);
        } else {
          var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data()?['nama'] != null) {
            setState(() => _managerName = doc.data()?['nama']);
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal memuat profil manager: $e');
    }
  }

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
    final leaveProvider = Provider.of<LeaveProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dashboard Manager',
          style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang, $_managerName',
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 4.0),
            Text(
              _getFormattedDate(),
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            const SizedBox(height: 24.0),

            // Realtime Counter Cards
            StreamBuilder<List<LeaveModel>>(
              stream: leaveProvider.allLeavesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const SizedBox.shrink(); 
                }

                int totalPending = 0;
                int totalApproved = 0;

                if (snapshot.hasData && snapshot.data != null) {
                  totalPending = snapshot.data!.where((l) => l.status == 'Pending').length;
                  totalApproved = snapshot.data!.where((l) => l.status == 'Disetujui' || l.status == 'Setujui').length;
                }

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildGridCard(
                          icon: Icons.pending_actions_outlined,
                          count: '$totalPending',
                          title: 'Menunggu',
                          subtitle: 'Persetujuan pending',
                          bgColor: const Color(0xFFFFF3E0),
                          textColor: const Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: _buildGridCard(
                          icon: Icons.assignment_turned_in_outlined,
                          count: '$totalApproved',
                          title: 'Disetujui',
                          subtitle: 'Total pengajuan lolos',
                          bgColor: const Color(0xFFE8F5E9),
                          textColor: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28.0),

            const Text(
              'Daftar Pengajuan Cuti & Izin',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12.0),

            // List Pengajuan dengan Penanganan Error dan Pagination
            StreamBuilder<List<LeaveModel>>(
              stream: leaveProvider.allLeavesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            'Gagal memuat data dari Firestore: ${snapshot.error}',
                            style: TextStyle(color: Colors.red.shade800, fontSize: 13.0, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'Belum ada pengajuan izin atau cuti.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }

                final leaves = snapshot.data!;
                final int totalItems = leaves.length;
                final int totalPages = (totalItems / _itemsPerPage).ceil();

                if (_currentPage > totalPages) {
                  _currentPage = totalPages > 0 ? totalPages : 1;
                }

                final int startIndex = (_currentPage - 1) * _itemsPerPage;
                int endIndex = startIndex + _itemsPerPage;
                if (endIndex > totalItems) endIndex = totalItems;

                final paginatedLeaves = leaves.sublist(startIndex, endIndex);

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paginatedLeaves.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                      itemBuilder: (context, index) {
                        final leave = paginatedLeaves[index];
                        return _buildLeaveCard(context, leave, leaveProvider);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    
                    if (totalPages > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0D47A1),
                              elevation: 0,
                              side: const BorderSide(color: Color(0xFF0D47A1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            onPressed: _currentPage > 1
                                ? () => setState(() => _currentPage--)
                                : null,
                            icon: const Icon(Icons.arrow_back_ios, size: 14.0),
                            label: const Text('Sblmnya'),
                          ),
                          Text(
                            'Halaman $_currentPage dari $totalPages',
                            style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0D47A1),
                              elevation: 0,
                              side: const BorderSide(color: Color(0xFF0D47A1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            onPressed: _currentPage < totalPages
                                ? () => setState(() => _currentPage++)
                                : null,
                            icon: const Icon(Icons.arrow_forward_ios, size: 14.0),
                            label: const Text('Berikut'),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: _currentIndex == 0 ? const Color(0xFF0D47A1) : Colors.grey),
                onPressed: () => setState(() => _currentIndex = 0),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: _currentIndex == 1 ? const Color(0xFF0D47A1) : Colors.grey),
                onPressed: () {
                  setState(() => _currentIndex = 1);
                  Navigator.pushNamed(context, AppRoutes.AdminSettingScreen).then((_) {
                    setState(() => _currentIndex = 0);
                  });
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10.0, offset: const Offset(0.0, 4.0)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12.0)),
            child: Icon(icon, color: textColor, size: 24.0),
          ),
          const SizedBox(height: 12.0),
          Text(
            count, 
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: textColor, height: 1.1)
          ),
          const SizedBox(height: 4.0),
          Text(
            title, 
            style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2.0),
          Text(
            subtitle, 
            style: const TextStyle(fontSize: 10.0, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(BuildContext context, LeaveModel leave, LeaveProvider provider) {
    bool isPending = leave.status == 'Pending';
    
    Color statusColor = (leave.status == 'Disetujui' || leave.status == 'Setujui')
        ? const Color(0xFF2E7D32)
        : leave.status == 'Ditolak'
            ? const Color(0xFFC62828)
            : const Color(0xFFE65100);

    // FIX: Sekarang membaca dinamis langsung dari properti leave.namaManager di database!
    String pemberiIzin = '-';
    if (!isPending) {
      pemberiIzin = (leave.namaManager != null && leave.namaManager!.isNotEmpty)
          ? 'Manager (${leave.namaManager})'
          : 'Manager';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLeaveDetailModal(context, leave, pemberiIzin),
        borderRadius: BorderRadius.circular(16.0),
        child: Ink(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8.0, offset: const Offset(0.0, 2.0)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(leave.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                      Text('${leave.divisi} • ${leave.jenis}', style: const TextStyle(color: Colors.grey, fontSize: 12.0)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      leave.status,
                      style: TextStyle(color: statusColor, fontSize: 11.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24.0),
              Text('Alasan: ${leave.alasan}', style: const TextStyle(fontSize: 13.0, color: Colors.black87)),
              const SizedBox(height: 6.0),
              Text(
                'Periode: ${leave.tanggalMulai.day}/${leave.tanggalMulai.month}/${leave.tanggalMulai.year} s.d ${leave.tanggalSelesai.day}/${leave.tanggalSelesai.month}/${leave.tanggalSelesai.year}',
                style: const TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
              
              if (!isPending) ...[
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, size: 14.0, color: Colors.grey),
                    const SizedBox(width: 4.0),
                    Text(
                      'Diproses Oleh: $pemberiIzin',
                      style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ],
                ),
              ],

              if (leave.keteranganManager != null && leave.keteranganManager!.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Text('Catatan Manager: ${leave.keteranganManager}', style: const TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic, color: Colors.grey)),
              ],
              if (isPending) ...[
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFC62828),
                        side: const BorderSide(color: Color(0xFFC62828)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: () => _showDecisionDialog(context, leave, provider, 'Ditolak'),
                      child: const Text('Tolak'),
                    ),
                    const SizedBox(width: 12.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: () => _showDecisionDialog(context, leave, provider, 'Disetujui'),
                      child: const Text('Setujui', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLeaveDetailModal(BuildContext context, LeaveModel leave, String pemberiIzin) {
    Color statusColor = (leave.status == 'Disetujui' || leave.status == 'Setujui')
        ? const Color(0xFF2E7D32)
        : leave.status == 'Ditolak'
            ? const Color(0xFFC62828)
            : const Color(0xFFE65100);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  const Text(
                    'Detail Pengajuan Izin & Cuti',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                  ),
                  const Divider(height: 24.0, thickness: 1.0),
                  
                  _buildDetailRow('Nama Karyawan', leave.nama),
                  _buildDetailRow('Divisi / Jabatan', leave.divisi),
                  _buildDetailRow('Jenis Pengajuan', leave.jenis),
                  
                  const Divider(height: 24.0),
                  
                  _buildDetailRow('Alasan / Keterangan', leave.alasan),
                  _buildDetailRow(
                    'Periode Pengajuan', 
                    '${leave.tanggalMulai.day}/${leave.tanggalMulai.month}/${leave.tanggalMulai.year} s.d ${leave.tanggalSelesai.day}/${leave.tanggalSelesai.month}/${leave.tanggalSelesai.year}'
                  ),
                  
                  const Divider(height: 24.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status Perizinan',
                        style: TextStyle(fontSize: 13.0, color: Colors.grey),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          leave.status,
                          style: TextStyle(color: statusColor, fontSize: 12.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  _buildDetailRow('Pemberi Izin', pemberiIzin),
                  
                  if (leave.keteranganManager != null && leave.keteranganManager!.isNotEmpty) ...[
                    const SizedBox(height: 12.0),
                    _buildDetailRow('Catatan Tambahan', leave.keteranganManager!),
                  ],
                  
                  const SizedBox(height: 32.0),
                  SizedBox(
                    width: double.infinity,
                    height: 48.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup', style: TextStyle(color: Colors.white, fontSize: 16.0)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          const SizedBox(height: 2.0),
          Text(
            value,
            style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _showDecisionDialog(BuildContext context, LeaveModel leave, LeaveProvider provider, String decision) {
    final TextEditingController commentController = TextEditingController();
    
    final String labelTindakan = decision == 'Disetujui' ? 'Setujui' : 'Tolak';
    final String kataKerja = decision == 'Disetujui' ? 'menyetujui' : 'menolak';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$labelTindakan Pengajuan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin $kataKerja pengajuan dari ${leave.nama}?'),
            const SizedBox(height: 16.0),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Catatan tambahan (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: decision == 'Disetujui' ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            ),
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Memproses data...')),
              );

              // Ambil nama Manager yang sedang aktif saat ini
              final currentManagerName = _managerName;

              // Update data status sekaligus simpan nama manager yang mengeklik aksi ke Firestore
              bool success = await provider.updateLeaveStatus(
                leaveId: leave.id,
                employeeUid: leave.uid,
                status: decision, 
                jenis: leave.jenis,
                keteranganManager: commentController.text,
                namaManager: currentManagerName, // <-- DIKIRIM KE PROVIDER
              );

              if (this.mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Berhasil memproses pengajuan!' : 'Gagal memproses pengajuan.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Konfirmasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}