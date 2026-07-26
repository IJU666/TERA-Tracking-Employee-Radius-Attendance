import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Model Helper untuk Header dan Item Data
abstract class ListItem {}

class HeaderItem extends ListItem {
  final String title;
  HeaderItem(this.title);
}

class DataItem extends ListItem {
  final Map<String, dynamic> data;
  DataItem(this.data);
}

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Parameter Filter & Pagination
  String _selectedStatus = 'Semua';
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  final int _limit = 10;
  int _currentPage = 1;
  bool _isLoading = false;

  // Menyimpan seluruh data dokumen dari Firestore
  List<QueryDocumentSnapshot> _allDocs = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- PEMANGGILAN DATA FIRESTORE (POLOS TANPA WHERE/ORDER BY) ---
  Future<void> _fetchData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Ambil data mentah tanpa .where() atau .orderBy() agar TIDAK PERNAH error index
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('cuti_izin')
          .get();

      List<QueryDocumentSnapshot> fetchedDocs = snapshot.docs;

      // Urutkan tanggal created_at di memori aplikasi (Terbaru ke Terlama)
      fetchedDocs.sort((a, b) {
        var dataA = a.data() as Map<String, dynamic>;
        var dataB = b.data() as Map<String, dynamic>;

        Timestamp tA = dataA['created_at'] ?? Timestamp.now();
        Timestamp tB = dataB['created_at'] ?? Timestamp.now();

        return tB.compareTo(tA);
      });

      setState(() {
        _allDocs = fetchedDocs;
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- DIALOG PICKER TANGGAL ---
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _currentPage = 1;
      });
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-';
    if (timestamp is Timestamp) {
      DateTime dt = timestamp.toDate();
      return DateFormat('dd MMM yyyy').format(dt);
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    // 1. FILTERING DI SISI CLIENT (STATUS, NAMA, & TANGGAL)
    List<QueryDocumentSnapshot> filteredDocs = _allDocs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;

      // A. Filter Status ("Semua", "Pending", "Disetujui", "Ditolak")
      bool matchesStatus = true;
      if (_selectedStatus != 'Semua') {
        String statusDoc = (data['status'] ?? 'Pending').toString();
        matchesStatus = statusDoc.toLowerCase() == _selectedStatus.toLowerCase();
      }

      // B. Filter Search Nama Karyawan
      String nama = (data['nama'] ?? '').toString().toLowerCase();
      bool matchesSearch = nama.contains(_searchQuery);

      // C. Filter Rentang Tanggal
      bool matchesDate = true;
      if (_selectedDateRange != null) {
        dynamic ts = data['date_start'] ?? data['created_at'];
        if (ts is Timestamp) {
          DateTime dt = ts.toDate();
          DateTime start = DateTime(
            _selectedDateRange!.start.year,
            _selectedDateRange!.start.month,
            _selectedDateRange!.start.day,
          );
          DateTime end = DateTime(
            _selectedDateRange!.end.year,
            _selectedDateRange!.end.month,
            _selectedDateRange!.end.day,
            23, 59, 59,
          );
          matchesDate = dt.isAfter(start.subtract(const Duration(seconds: 1))) &&
              dt.isBefore(end);
        }
      }

      return matchesStatus && matchesSearch && matchesDate;
    }).toList();

    // 2. PAGINATION
    int totalPages =
        (filteredDocs.isEmpty) ? 1 : (filteredDocs.length / _limit).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;

    int startIndex = (_currentPage - 1) * _limit;
    int endIndex = startIndex + _limit;
    if (endIndex > filteredDocs.length) endIndex = filteredDocs.length;

    List<QueryDocumentSnapshot> paginatedDocs =
        filteredDocs.isEmpty ? [] : filteredDocs.sublist(startIndex, endIndex);

    // 3. LOGIKA PENGELOMPOKAN (GROUPING)
    List<ListItem> displayItems = [];

    if (_selectedStatus == 'Semua') {
      // Jika tab "Semua", kelompokkan berdasarkan Status (Pending, Disetujui, Ditolak)
      for (var statusGroup in ['Pending', 'Disetujui', 'Ditolak']) {
        var groupDocs = paginatedDocs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String s = (data['status'] ?? 'Pending').toString();
          return s.toLowerCase() == statusGroup.toLowerCase();
        }).toList();

        if (groupDocs.isNotEmpty) {
          displayItems.add(HeaderItem(statusGroup));
          for (var doc in groupDocs) {
            displayItems.add(DataItem(doc.data() as Map<String, dynamic>));
          }
        }
      }
    } else {
      // Jika memilih tab spesifik (Pending/Disetujui/Ditolak), kelompokkan berdasarkan Bulan & Tahun
      String lastGroupHeader = '';
      for (var doc in paginatedDocs) {
        var data = doc.data() as Map<String, dynamic>;
        dynamic ts = data['date_start'] ?? data['created_at'];
        String groupHeader = 'Tanpa Tanggal';

        if (ts is Timestamp) {
          groupHeader = DateFormat('MMMM yyyy').format(ts.toDate());
        }

        if (groupHeader != lastGroupHeader) {
          displayItems.add(HeaderItem(groupHeader));
          lastGroupHeader = groupHeader;
        }
        displayItems.add(DataItem(data));
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit Cuti & Izin',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            Text(
              'Monitoring persetujuan manajer',
              style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterAndSearchSection(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                : displayItems.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _fetchData(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          itemCount: displayItems.length,
                          itemBuilder: (context, index) {
                            final item = displayItems[index];

                            if (item is HeaderItem) {
                              return _buildGroupHeader(item.title);
                            }

                            if (item is DataItem) {
                              return _buildAuditCard(item.data);
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomSheet: _buildPaginationBar(totalPages),
    );
  }

  // --- WIDGET FILTER & SEARCH BAR ---
  Widget _buildFilterAndSearchSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Cari nama karyawan...',
                    hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF64748B)),
                    fillColor: const Color(0xFFF1F5F9),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Tombol Date Picker
              InkWell(
                onTap: () => _selectDateRange(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedDateRange == null
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedDateRange == null
                          ? Colors.transparent
                          : const Color(0xFF2563EB),
                    ),
                  ),
                  child: Icon(
                    Icons.date_range_rounded,
                    color: _selectedDateRange == null
                        ? const Color(0xFF64748B)
                        : const Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          // Indikator Rentang Tanggal Aktif
          if (_selectedDateRange != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_alt_rounded,
                          size: 12, color: Color(0xFF2563EB)),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _selectedDateRange = null),
                        child: const Icon(Icons.close_rounded,
                            size: 14, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // Chips Pengelompokan / Filter Status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  ['Semua', 'Pending', 'Disetujui', 'Ditolak'].map((status) {
                bool isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedStatus = status;
                          _currentPage = 1; // Reset halaman
                        });
                      }
                    },
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF475569),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- HEADER GRUP ---
  Widget _buildGroupHeader(String title) {
    IconData icon = Icons.bookmark_rounded;
    Color color = const Color(0xFF2563EB);

    if (title == 'Pending') {
      icon = Icons.hourglass_top_rounded;
      color = const Color(0xFFB45309);
    } else if (title == 'Disetujui') {
      icon = Icons.check_circle_rounded;
      color = const Color(0xFF15803D);
    } else if (title == 'Ditolak') {
      icon = Icons.cancel_rounded;
      color = const Color(0xFFB91C1C);
    } else {
      icon = Icons.calendar_month_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
          ),
        ],
      ),
    );
  }

  // --- CARD ITEM PENGAJUAN ---
  Widget _buildAuditCard(Map<String, dynamic> data) {
    String namaKaryawan = data['nama'] ?? 'Tanpa Nama';
    String tipePengajuan = data['type'] ?? 'Izin / Cuti';
    String alasan = data['alasan'] ?? '-';
    String status = data['status'] ?? 'Pending';
    String namaManager = data['nama_manager'] ?? '-';
    String ketManager = data['keterangan_manager'] ?? '-';

    String tglMulai = _formatTimestamp(data['date_start']);
    String tglSelesai = _formatTimestamp(data['date_end']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  namaKaryawan.isNotEmpty
                      ? namaKaryawan[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaKaryawan,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF0F172A)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        tipePengajuan,
                        style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                '$tglMulai - $tglSelesai',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '"$alasan"',
            style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded,
                        size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text(
                      'Ditinjau oleh Manager:',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600),
                    ),
                    const Spacer(),
                    Text(
                      namaManager.isNotEmpty ? namaManager : '-',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                if (ketManager.isNotEmpty && ketManager != '-') ...[
                  const SizedBox(height: 6),
                  Text(
                    'Catatan Manager: "$ketManager"',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- BADGE STATUS ---
  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    IconData icon;

    switch (status) {
      case 'Disetujui':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF15803D);
        icon = Icons.check_circle_rounded;
        break;
      case 'Ditolak':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFB91C1C);
        icon = Icons.cancel_rounded;
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        icon = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
                color: text, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- PAGINATION BAR ---
  Widget _buildPaginationBar(int totalPages) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: (_currentPage > 1 && !_isLoading)
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 18),
            label: const Text('Prev'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Halaman $_currentPage dari $totalPages',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155)),
            ),
          ),
          ElevatedButton(
            onPressed: (_currentPage < totalPages && !_isLoading)
                ? () => setState(() => _currentPage++)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Row(
              children: [
                Text('Next', style: TextStyle(color: Colors.white)),
                SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9), shape: BoxShape.circle),
            child: const Icon(Icons.inbox_rounded,
                size: 48, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada data pengajuan',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Data cuti/izin belum ditemukan pada filter ini.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}