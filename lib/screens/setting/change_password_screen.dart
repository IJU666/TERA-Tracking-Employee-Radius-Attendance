import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Indikator validasi password real-time
  bool _hasMinLength = false;
  bool _hasUpperLower = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk mengecek kekuatan password saat mengetik
    _newPasswordController.addListener(_validatePasswordStrength);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswordStrength() {
    final text = _newPasswordController.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasUpperLower = text.contains(RegExp(r'[A-Z]')) && text.contains(RegExp(r'[a-z]'));
      _hasNumber = text.contains(RegExp(r'[0-9]'));
      _hasSymbol = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  // Menghitung kekuatan password (0 - 4)
  int get _passwordStrengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUpperLower) score++;
    if (_hasNumber) score++;
    if (_hasSymbol) score++;
    return score;
  }

  String get _passwordStrengthText {
    if (_newPasswordController.text.isEmpty) return "Belum diisi";
    switch (_passwordStrengthScore) {
      case 1: return "Sangat Lemah";
      case 2: return "Lemah";
      case 3: return "Sedang";
      case 4: return "Kuat";
      default: return "Sangat Lemah";
    }
  }

  Color get _passwordStrengthColor {
    switch (_passwordStrengthScore) {
      case 1: return AppColors.error;
      case 2: return AppColors.warning;
      case 3: return Colors.lightGreen;
      case 4: return AppColors.success;
      default: return AppColors.border;
    }
  }

  Future<void> _submitChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordStrengthScore < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru belum memenuhi kriteria keamanan.')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    
    // Panggil fungsi ganti password
    final error = await authProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (error == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diubah. Silakan login ulang.'),
          backgroundColor: AppColors.success,
        ),
      );
      // Navigasi ke halaman login setelah berhasil dan dilogout
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Terjadi kesalahan.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Ganti Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Buat password baru yang kuat untuk\nmenjaga keamanan akun Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 32),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field 1: Password Saat Ini
                      _buildInputLabel('Password Saat Ini'),
                      _buildPasswordField(
                        controller: _currentPasswordController,
                        hint: '********',
                        isObscure: _obscureCurrent,
                        onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        validator: (val) => val == null || val.isEmpty ? 'Isi password saat ini' : null,
                      ),
                      const SizedBox(height: 20),

                      // Field 2: Password Baru
                      _buildInputLabel('Password Baru'),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        hint: 'SecureP@ss123',
                        isObscure: _obscureNew,
                        onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Isi password baru';
                          if (val == _currentPasswordController.text) return 'Password baru harus berbeda';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Field 3: Konfirmasi Password Baru
                      _buildInputLabel('Konfirmasi Password Baru'),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        hint: 'SecureP@ss123',
                        isObscure: _obscureConfirm,
                        onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Isi konfirmasi password';
                          if (val != _newPasswordController.text) return 'Password tidak cocok';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Password Strength Indicator
                      Row(
                        children: [
                          const Text(
                            'Kekuatan Password: ',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            _passwordStrengthText,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _passwordStrengthColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Bar Indikator Kekuatan
                      Row(
                        children: List.generate(4, (index) {
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: index < _passwordStrengthScore ? _passwordStrengthColor : AppColors.border,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),

                      // Checklist Validasi
                      _buildChecklistItem('Minimal 8 karakter', _hasMinLength),
                      _buildChecklistItem('Mengandung huruf besar & kecil', _hasUpperLower),
                      _buildChecklistItem('Mengandung angka', _hasNumber),
                      _buildChecklistItem('Mengandung simbol (opsional)', _hasSymbol),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Box Login Ulang
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB), // Kuning pudar sesuai gambar
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFEF3C7)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const Text(
                          'Anda akan diminta login ulang setelah mengganti password',
                          style: TextStyle(fontSize: 13, color: Color(0xFFB45309), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      
      // Bottom Navigation Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: isLoading ? null : _submitChangePassword,
            icon: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 20),
            label: Text(
              isLoading ? 'Menyimpan...' : 'Simpan Password Baru',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // Komponen Label Input
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  // Komponen Input Password
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  // Komponen Item Checklist
  Widget _buildChecklistItem(String text, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
            color: isChecked ? AppColors.success : AppColors.border,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isChecked ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}