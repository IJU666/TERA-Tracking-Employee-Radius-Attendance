import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // WAJIB TAMBAHKAN IMPORT INI

class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({super.key});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _divisiController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(text: 'GeoAbsen2024');

  String _selectedRole = 'Karyawan';
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _divisiController.dispose();
    _jabatanController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // FUNGSI UNTUK MENYIMPAN DATA KE AUTH DAN FIRESTORE 'users'
  Future<void> _simpanKaryawan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Buat akun di Firebase Authentication agar user bisa login
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 2. Simpan data detail ke collection 'users' menggunakan UID dari Auth
      // agar sinkron antara akun login dan data profil
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'nama': _namaController.text.trim(),
        'nik': _nikController.text.trim(),
        'email': _emailController.text.trim(),
        'divisi': _divisiController.text.trim(),
        'jabatan': _jabatanController.text.trim(),
        // Diubah menjadi huruf kecil agar seragam dengan data di gambar (contoh: 'admin')
        'role': _selectedRole.toLowerCase(), 
        'statusHariIni': 'Tidak Hadir',
        'avatarUrl': 'https://via.placeholder.com/150',
        'createdAt': FieldValue.serverTimestamp(),
        'ringkasanBulanan': {
          'hadir': 0,
          'telat': 0,
          'izin': 0,
        },
        'riwayatAbsensi': [],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat dan disimpan ke database users!'), 
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Menutup halaman form setelah sukses
      }
    } on FirebaseAuthException catch (e) {
      // Menangkap error khusus dari Firebase Auth (misal: email sudah terdaftar)
      if (mounted) {
        String errorMsg = 'Terjadi kesalahan saat mendaftar.';
        if (e.code == 'email-already-in-use') {
          errorMsg = 'Email ini sudah digunakan oleh akun lain.';
        } else if (e.code == 'weak-password') {
          errorMsg = 'Password terlalu lemah.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Menangkap error umum lainnya
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.only(
              top: 16,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tambah Karyawan', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('IDENTITAS DIRI'),
                          _buildTextField('Nama Lengkap', 'Masukkan nama lengkap', _namaController),
                          _buildTextField('Nomor Induk Karyawan (NIK)', 'Contoh: 2023001', _nikController, isNumeric: true),
                          _buildTextField('Email Perusahaan', 'karyawan@perusahaan.com', _emailController, isEmail: true),

                          _buildSectionTitle('PENEMPATAN'),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Divisi', 'Sales / IT', _divisiController)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildTextField('Jabatan', 'Manager', _jabatanController)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('Role Akses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                            ),
                            // Memastikan opsi role tertulis jelas
                            items: ['Karyawan', 'Admin'].map((role) {
                              return DropdownMenuItem(value: role, child: Text(role));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedRole = val);
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildSectionTitle('KEAMANAN'),
                          const Text('Password Sementara', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _isPasswordObscured,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Karyawan akan diminta mengubah password saat login pertama kali.',
                            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: _isLoading ? null : _simpanKaryawan,
                              icon: _isLoading 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.save_alt, color: Colors.white),
                              label: const Text('Simpan Akun', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1976D2), letterSpacing: 0.5)),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isNumeric = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return '$label wajib diisi';
              if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Format email salah';
              return null;
            },
          ),
        ],
      ),
    );
  }
}