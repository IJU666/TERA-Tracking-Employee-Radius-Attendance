import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/utils/date_formatter.dart';
import '../../models/attendance_model.dart';
import '../../repositories/attendance_repository.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> karyawanData;

  const EmployeeDetailScreen({
    super.key,
    required this.docId,
    required this.karyawanData,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  bool _isDeleting = false;

  // 🔥 Sumber data absensi asli (Firestore), menggantikan field statis
  // 'ringkasanBulanan' & 'riwayatAbsensi' yang gak pernah benar-benar ada.
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  bool _isLoadingRiwayat = true;
  List<AttendanceModel> _riwayat = [];
  int _hadir = 0;
  int _telat = 0;
  int _izin = 0;

  // Variabel untuk mengelola Dropdown Bulan
  String _selectedMonth = '';
  List<String> _availableMonths = [];

  final List<String> _namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _generateMonths();
    _loadDataForMonth(_selectedMonth);
  }

  // 🔥 Ubah label dropdown ("Juli 2026") jadi rentang tanggal 1 bulan penuh
  DateTime _monthLabelToDate(String label) {
    final parts = label.split(' ');
    final monthIndex = _namaBulan.indexOf(parts[0]) + 1;
    final year =
        int.tryParse(parts.length > 1 ? parts[1] : '') ?? DateTime.now().year;
    return DateTime(year, monthIndex <= 0 ? 1 : monthIndex, 1);
  }

  Future<void> _loadDataForMonth(String monthLabel) async {
    setState(() => _isLoadingRiwayat = true);
    try {
      final monthStart = _monthLabelToDate(monthLabel);
      final start = DateTime(monthStart.year, monthStart.month, 1);
      final end = DateTime(
        monthStart.year,
        monthStart.month + 1,
        0,
        23,
        59,
        59,
      );

      final riwayat = await _attendanceRepo.getByRange(
        widget.docId,
        start,
        end,
      );
      final izinCount = await _attendanceRepo.getApprovedCutiIzinCountInRange(
        widget.docId,
        start,
        end,
      );

      if (!mounted) return;
      setState(() {
        _riwayat = riwayat;
        _hadir = riwayat.where((a) => a.status == 'hadir').length;
        _telat = riwayat.where((a) => a.status == 'terlambat').length;
        _izin = izinCount;
        _isLoadingRiwayat = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat riwayat absensi karyawan: $e');
      if (mounted) setState(() => _isLoadingRiwayat = false);
    }
  }

  // Fungsi untuk menghasilkan daftar bulan (misal: 6 bulan terakhir dari hari ini)
  void _generateMonths() {
    DateTime now = DateTime.now();
    for (int i = 0; i < 6; i++) {
      int month = now.month - i;
      int year = now.year;

      // Penyesuaian jika mundur hingga ke tahun sebelumnya
      if (month <= 0) {
        month += 12;
        year -= 1;
      }

      String formatted = '${_namaBulan[month - 1]} $year';
      _availableMonths.add(formatted);
    }
    // Set default ke bulan saat ini
    _selectedMonth = _availableMonths.first;
  }

  Future<void> _hapusKaryawan() async {
    setState(() => _isDeleting = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun karyawan berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showKonfirmasiHapusDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isDeleting,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Hapus Akun Karyawan?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus data dari ${widget.karyawanData['nama'] ?? 'Karyawan'}? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: _isDeleting ? null : () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isDeleting
                  ? null
                  : () {
                      Navigator.pop(context);
                      _hapusKaryawan();
                    },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showKonfirmasiHapusDialog();
              }
            },
            icon: const Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Hapus Karyawan', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CARD PROFIL ---
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
                          backgroundImage: NetworkImage(
                            widget.karyawanData['avatarUrl'] ??
                                'https://via.placeholder.com/150',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.karyawanData['nama'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NIK: ${widget.karyawanData['nik'] ?? '-'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8EAF6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.badge_outlined,
                                      size: 12,
                                      color: Color(0xFF3F51B5),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      (widget.karyawanData['jabatan'] ?? '-')
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF3F51B5),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- RINGKASAN BULANAN ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ringkasan Bulanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),

                      // --- PERBAIKAN: Dropdown Dinamis ---
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedMonth,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Color(0xFF0D47A1),
                            ),
                            style: const TextStyle(
                              color: Color(0xFF0D47A1),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            isDense: true,
                            alignment: Alignment.center,
                            onChanged: (String? newValue) {
                              if (newValue != null &&
                                  newValue != _selectedMonth) {
                                setState(() => _selectedMonth = newValue);
                                _loadDataForMonth(newValue);
                              }
                            },
                            items: _availableMonths
                                .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMonthlyStatCard(
                          _hadir.toString(),
                          'Hadir',
                          const Color(0xFFE8F5E9),
                          const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMonthlyStatCard(
                          _telat.toString(),
                          'Telat',
                          const Color(0xFFFFEBEE),
                          const Color(0xFFC62828),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMonthlyStatCard(
                          _izin.toString(),
                          'Izin',
                          const Color(0xFFEEEEEE),
                          Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- RIWAYAT ABSENSI ---
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Riwayat Absensi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Terbaru',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingRiwayat)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_riwayat.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Tidak ada riwayat absensi di bulan ini.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _riwayat.length,
                      itemBuilder: (context, idx) {
                        return _buildRiwayatCard(_riwayat[idx]);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthlyStatCard(
    String val,
    String label,
    Color itemBg,
    Color textCol,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textCol,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(AttendanceModel item) {
    // item.status disimpan lowercase ('hadir'/'terlambat'/'izin'/'cuti'/
    // 'lembur'/'absen'); statusLabel mengubahnya ke label tampilan.
    final String status = item.statusLabel;
    Color badgeColor = const Color(0xFFE8F5E9);
    Color textColor = const Color(0xFF2E7D32);

    if (status == 'Terlambat') {
      badgeColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFC62828);
    } else if (status == 'Izin' || status == 'Cuti') {
      badgeColor = const Color(0xFFEEEEEE);
      textColor = Colors.black54;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  Text(
                    DateFormatter.formatDayName(item.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    DateFormatter.formatDate(item.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (status != 'Izin' && status != 'Cuti') ...[
            Row(
              children: [
                Expanded(
                  child: _buildTimeBox(
                    Icons.login_rounded,
                    'Check-in',
                    item.checkIn != null
                        ? DateFormatter.formatTime(item.checkIn!)
                        : '--:--',
                    const Color(0xFFE3F2FD),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeBox(
                    Icons.logout_rounded,
                    'Check-out',
                    item.checkOut != null
                        ? DateFormatter.formatTime(item.checkOut!)
                        : '--:--',
                    const Color(0xFFEEEEEE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Catatan: lokasi mentah tersimpan sebagai string "lat,
                  // lng" di field 'lokasi' pada dokumen Firestore, belum
                  // dipetakan ke peta di sini — di luar cakupan perbaikan
                  // saat ini (ringkasan bulanan & riwayat absensi).
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur lihat lokasi segera hadir'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF0D47A1),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                label: const Text(
                  'Lihat Lokasi',
                  style: TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              '"${item.leaveNote ?? '-'}"',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeBox(IconData icon, String title, String time, Color iconBg) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0D47A1), size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
