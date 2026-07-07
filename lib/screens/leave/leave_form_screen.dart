import 'package:flutter/material.dart';

class LeaveFormScreen extends StatefulWidget {
  const LeaveFormScreen({Key? key}) : super(key: key);

  @override
  State<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends State<LeaveFormScreen> {
  // false = Cuti (Orange), true = Izin (Biru)
  bool _isIzinTab = false; 
  @override
void initState() {
  super.initState();
  // Tangkap argument tipe string ('cuti' / 'izin') saat layar dirender
  Future.delayed(Duration.zero, () {
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args == 'izin') {
      setState(() => _isIzinTab = true);
    } else {
      setState(() => _isIzinTab = false);
    }
  });
}

  // Form Controllers Cuti
  final _cutiMulaiController = TextEditingController(text: '12 Okt 2023');
  final _cutiSelesaiController = TextEditingController(text: '15 Okt 2023');
  final _cutiAlasanController = TextEditingController();
  final _cutiKontakController = TextEditingController();

  // Form Controllers Izin
  String? _selectedJenisIzin;
  final _izinTanggalController = TextEditingController();
  final _izinAlasanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Tema warna dinamis sesuai tab aktif
    final themeColor = _isIzinTab ? const Color(0xFF1565C0) : Colors.orange.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pengajuan Cuti & Izin',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Custom Tab Switcher (Cuti vs Izin)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBEB),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.decelerate,
                    alignment: _isIzinTab ? Alignment.centerRight : Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(21),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isIzinTab = false),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text(
                              'Cuti',
                              style: TextStyle(
                                color: !_isIzinTab ? Colors.white : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isIzinTab = true),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text(
                              'Izin',
                              style: TextStyle(
                                color: _isIzinTab ? Colors.white : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Form Konten (Berubah dinamis tergantung Tab)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isIzinTab ? _buildIzinForm() : _buildCutiForm(),
            ),
          ),

          // 3. Tombol Submit di Bagian Paling Bawah
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isIzinTab ? 'Ajukan Izin' : 'Ajukan Cuti',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (_isIzinTab) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.send, color: Colors.white, size: 16),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB PANEL CUTI (ORANGE) ---
  Widget _buildCutiForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Sisa Cuti
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
                child: Icon(Icons.calendar_month, color: Colors.orange.shade800),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sisa Cuti Kamu', style: TextStyle(color: Colors.black54, fontSize: 14)),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: '12 hari ',
                      style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 20),
                      children: const [
                        TextSpan(text: 'dari 14 hari/tahun', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.normal))
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildFieldLabel('Tanggal Mulai'),
        _buildTextField(_cutiMulaiController, 'Pilih Tanggal', icon: Icons.calendar_today_outlined),
        _buildFieldLabel('Tanggal Selesai'),
        _buildTextField(_cutiSelesaiController, 'Pilih Tanggal', icon: Icons.disabled_by_default_outlined),
        
        // Durasi Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBBDEFB)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue),
              SizedBox(width: 6),
              Text('Durasi: 3 hari kerja', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Keperluan / Alasan'),
        _buildTextField(_cutiAlasanController, 'Tuliskan alasan cuti...', maxLines: 4),
        _buildFieldLabel('Kontak Darurat'),
        _buildTextField(_cutiKontakController, 'Nomor HP yang bisa dihubungi', icon: Icons.phone_outlined),
      ],
    );
  }

  // --- TAB PANEL IZIN (BIRU) ---
  Widget _buildIzinForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Jenis Izin'),
        DropdownButtonFormField<String>(
          value: _selectedJenisIzin,
          decoration: _inputDecoration('Pilih jenis izin', null),
          items: ['Sakit dengan Surat Dokter', 'Keperluan Keluarga', 'Lainnya']
              .map((label) => DropdownMenuItem(value: label, child: Text(label)))
              .toList(),
          onChanged: (value) => setState(() => _selectedJenisIzin = value),
        ),
        _buildFieldLabel('Tanggal Izin'),
        _buildTextField(_izinTanggalController, 'mm/dd/yyyy', icon: Icons.calendar_today_outlined),
        _buildFieldLabel('Alasan'),
        _buildTextField(_izinAlasanController, 'Tuliskan alasan...', maxLines: 4),
        _buildFieldLabel('Lampiran Dokumen'),
        
        // Upload Area Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDCDCDC)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), shape: BoxShape.circle),
                child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF1565C0), size: 28),
              ),
              const SizedBox(height: 12),
              const Text('Klik untuk Unggah', style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              const Text('Unggah surat dokter / surat keterangan', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bottom Info Row (Kuota & Status)
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('QUOTA SISA', style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                        const Text('12 Hari', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDCDCDC)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.grey),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STATUS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('Aktif', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // --- HELPER COMPONENT WIDGETS ---
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {IconData? icon, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: _inputDecoration(hint, icon),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      fillColor: Colors.white,
      filled: true,
      suffixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDCDCDC))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDCDCDC))),
    );
  }
}