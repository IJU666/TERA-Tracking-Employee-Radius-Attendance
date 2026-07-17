import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validator_util.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../widgets/loading_overlay.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _nikController;
  late TextEditingController _divisiController;
  late TextEditingController _jabatanController;

  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = context.read<AuthProvider>().currentUser;
      _namaController = TextEditingController(text: user?.nama ?? '');
      _nikController = TextEditingController(text: user?.nik ?? '');
      _divisiController = TextEditingController(text: user?.divisi ?? '');
      _jabatanController = TextEditingController(text: user?.jabatan ?? '');
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _divisiController.dispose();
    _jabatanController.dispose();
    super.dispose();
  }

Future<void> _handleSave() async {
  if (!_formKey.currentState!.validate()) return;

  final currentUser = context.read<AuthProvider>().currentUser;
  if (currentUser == null) return;

  setState(() => _saving = true);

  final success = await context.read<UserProvider>().updateProfile(
        uid: currentUser.uid,
        nama: _namaController.text.trim(),
        nik: _nikController.text.trim(),
        divisi: _divisiController.text.trim(),
        jabatan: _jabatanController.text.trim(),
      );

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      // refresh currentUser di AuthProvider supaya konsisten di seluruh app
      await context.read<AuthProvider>().refreshCurrentUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui profil. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _saving,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                            ? Icon(Icons.person_rounded, size: 44, color: AppColors.primary)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: implementasi ganti foto via storage_service.dart (belum dibuat)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur ganti foto belum tersedia')),
                      );
                    },
                    child: const Text('Ganti Foto'),
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Nama Lengkap',
                  controller: _namaController,
                  icon: Icons.person_outline_rounded,
                  validator: ValidatorUtil.validateNotEmpty,
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'NIK',
                  controller: _nikController,
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: ValidatorUtil.validateNik,
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Divisi',
                  controller: _divisiController,
                  icon: Icons.apartment_outlined,
                  validator: ValidatorUtil.validateNotEmpty,
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Jabatan',
                  controller: _jabatanController,
                  icon: Icons.work_outline_rounded,
                  validator: ValidatorUtil.validateNotEmpty,
                ),
                const SizedBox(height: 14),
                _buildReadOnlyField(
                  label: 'Email',
                  value: user?.email ?? '-',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _saving ? null : _handleSave,
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade500),
              const SizedBox(width: 10),
              Text(value, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}