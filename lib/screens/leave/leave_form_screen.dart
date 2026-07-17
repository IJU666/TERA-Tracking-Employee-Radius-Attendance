import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tugas_besar/models/user_model.dart';
import '../../providers/leave_provider.dart';
import '../../providers/auth_provider.dart';

class LeaveFormScreen extends StatefulWidget {
  // PERBAIKAN 1: Menggunakan modern super parameter syntax
  const LeaveFormScreen({super.key});

  @override
  State<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends State<LeaveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isIzinTab = false; // false = Cuti, true = Izin

  // Form Controllers Cuti
  final _cutiMulaiController = TextEditingController();
  final _cutiSelesaiController = TextEditingController();
  final _cutiAlasanController = TextEditingController();
  final _cutiKontakController = TextEditingController();

  // Form Controllers Izin
  String? _selectedJenisIzin;
  final _izinTanggalController = TextEditingController();
  final _izinAlasanController = TextEditingController();

  // Variabel penampung tanggal
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _izinDate;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      // PERBAIKAN 2: Proteksi context lintas async gap dengan mounted check
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      setState(() => _isIzinTab = args == 'izin');
    });
  }

  @override
  void dispose() {
    _cutiMulaiController.dispose();
    _cutiSelesaiController.dispose();
    _cutiAlasanController.dispose();
    _cutiKontakController.dispose();
    _izinTanggalController.dispose();
    _izinAlasanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, TextEditingController controller, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd MMM yyyy').format(picked);
        if (type == 'start') _startDate = picked;
        if (type == 'end') _endDate = picked;
        if (type == 'izin') _izinDate = picked;
      });
    }
  }

  int get _hitungDurasiCuti {
    if (_startDate == null || _endDate == null) return 0;
    if (_endDate!.isBefore(_startDate!)) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    final leaveProvider = context.read<LeaveProvider>();

    final String uid = authProvider.currentUser?.uid ?? '';
    // PERBAIKAN 3: Mengubah .displayName menjadi .nama sesuai properti UserModel Anda
    final String nama = authProvider.currentUser?.nama ?? 'users';

    bool success = false;

    if (!_isIzinTab) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih rentang tanggal cuti')));
        return;
      }
      
      success = await leaveProvider.createLeaveRequest(
        uid: uid,
        nama: nama,
        type: 'Cuti',
        dateStart: _startDate!,
        dateEnd: _endDate!,
        alasan: _cutiAlasanController.text,
        additionalInfo: {'kontak_darurat': _cutiKontakController.text},
      );
    } else {
      if (_izinDate == null || _selectedJenisIzin == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi jenis izin dan tanggal')));
        return;
      }

      success = await leaveProvider.createLeaveRequest(
        uid: uid,
        nama: nama,
        type: _selectedJenisIzin!,
        dateStart: _izinDate!,
        dateEnd: _izinDate!,
        alasan: _izinAlasanController.text,
        additionalInfo: {'fileUrl': ''},
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan berhasil dikirim!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _isIzinTab ? const Color(0xFF1565C0) : Colors.orange.shade800;
    final isLoading = context.watch<LeaveProvider>().isLoading;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pengajuan Cuti & Izin', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Custom Tab Switcher
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(color: const Color(0xFFEBEBEB), borderRadius: BorderRadius.circular(25)),
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
                          decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(21)),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isIzinTab = false),
                            behavior: HitTestBehavior.opaque,
                            child: Center(child: Text('Cuti', style: TextStyle(color: !_isIzinTab ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold))),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isIzinTab = true),
                            behavior: HitTestBehavior.opaque,
                            child: Center(child: Text('Izin', style: TextStyle(color: _isIzinTab ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Form Konten
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isIzinTab ? _buildIzinForm() : _buildCutiForm(user),
              ),
            ),

            // Tombol Submit
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(
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
      ),
    );
  }

  // --- TAB PANEL CUTI ---
  Widget _buildCutiForm(UserModel? user) {
    final sisaCuti = user?.sisaCuti ?? 14;
  final totalCuti = user?.totalCuti ?? 14;
return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
                    // 🔥 SEKARANG SUDAH DINAMIS MENGGUNAKAN VARIABEL
                    text: '$sisaCuti hari ', 
                    style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 20),
                    children: [
                      TextSpan(
                        // 🔥 SEKARANG SUDAH DINAMIS MENGGUNAKAN VARIABEL
                        text: 'dari $totalCuti hari/tahun', 
                        style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.normal),
                      ),
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
        _buildClickableTextField(_cutiMulaiController, 'Pilih Tanggal Mulai', Icons.calendar_today_outlined, () => _pickDate(context, _cutiMulaiController, 'start')),
        _buildFieldLabel('Tanggal Selesai'),
        _buildClickableTextField(_cutiSelesaiController, 'Pilih Tanggal Selesai', Icons.disabled_by_default_outlined, () => _pickDate(context, _cutiSelesaiController, 'end')),
        
        if (_hitungDurasiCuti > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFBBDEFB))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Text('Durasi: $_hitungDurasiCuti hari', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildFieldLabel('Keperluan / Alasan'),
        _buildNormalTextField(_cutiAlasanController, 'Tuliskan alasan cuti...', maxLines: 4),
        _buildFieldLabel('Kontak Darurat'),
        _buildNormalTextField(_cutiKontakController, 'Nomor HP yang bisa dihubungi', icon: Icons.phone_outlined, isPhone: true),
      ],
    );
  }

  // --- TAB PANEL IZIN ---
  Widget _buildIzinForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Jenis Izin'),
        DropdownButtonFormField<String>(
          // PERBAIKAN 4: Menggunakan 'initialValue' menggantikan 'value' yang sudah deprecated
          initialValue: _selectedJenisIzin,
          decoration: _inputDecoration('Pilih jenis izin', null),
          items: ['Sakit dengan Surat Dokter', 'Keperluan Keluarga', 'Lainnya']
              .map((label) => DropdownMenuItem(value: label, child: Text(label)))
              .toList(),
          onChanged: (value) => setState(() => _selectedJenisIzin = value),
          validator: (val) => val == null ? 'Pilih jenis izin terlebih dahulu' : null,
        ),
        _buildFieldLabel('Tanggal Izin'),
        _buildClickableTextField(_izinTanggalController, 'Pilih Tanggal Izin', Icons.calendar_today_outlined, () => _pickDate(context, _izinTanggalController, 'izin')),
        _buildFieldLabel('Alasan'),
        _buildNormalTextField(_izinAlasanController, 'Tuliskan alasan...', maxLines: 4),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
    );
  }

  Widget _buildNormalTextField(TextEditingController controller, String hint, {IconData? icon, int maxLines = 1, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: _inputDecoration(hint, icon),
      validator: (val) => val == null || val.isEmpty ? 'Field ini wajib diisi' : null,
    );
  }

  Widget _buildClickableTextField(TextEditingController controller, String hint, IconData icon, VoidCallback onTap) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: _inputDecoration(hint, icon),
      validator: (val) => val == null || val.isEmpty ? 'Silakan tentukan tanggal' : null,
    );
  }

  InputDecoration _inputDecoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      fillColor: Colors.white,
      filled: true,
      suffixIcon: icon != null ? Icon(icon, color: Colors.black54, size: 20) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDCDCDC))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDCDCDC))),
    );
  }
}