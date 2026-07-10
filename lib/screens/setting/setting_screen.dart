import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../leave/leave_form_screen.dart';
import '../widgets/confirm_dialog.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini segera hadir')),
    );
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
          'Settings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
            onPressed: () => _comingSoon(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _profileCard(
              context,
              nama: user?.nama ?? '-',
              jabatanDivisi: '${user?.jabatan ?? '-'} - ${user?.divisi ?? '-'}',
              nik: user?.nik ?? '-',
              fotoUrl: user?.fotoUrl,
            ),
            const SizedBox(height: 24),
            _sectionLabel('Absensi'),
            const SizedBox(height: 10),
            _menuGroup([
              _MenuItemData(
                icon: Icons.calendar_month_outlined,
                iconColor: AppColors.primary,
                label: 'Riwayat Absensi',
                onTap: () => _comingSoon(context),
              ),
              _MenuItemData(
                icon: Icons.event_busy_outlined,
                iconColor: AppColors.primary,
                label: 'Cuti & Izin',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LeaveFormScreen()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('Akun'),
            const SizedBox(height: 10),
            _menuGroup([
              _MenuItemData(
                icon: Icons.account_circle_outlined,
                iconColor: AppColors.primary,
                label: 'Edit Profil',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.lock_outline_rounded,
                iconColor: AppColors.primary,
                label: 'Ganti Password',
                 onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.notifications_none_rounded,
                iconColor: AppColors.primary,
                label: 'Notifikasi',
                onTap: () => _comingSoon(context),
              ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('Lainnya'),
            const SizedBox(height: 10),
            _menuGroup([
              _MenuItemData(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                label: 'Tentang Aplikasi',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'TERA',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.primary,
                label: 'Bantuan',
                onTap: () => _comingSoon(context),
              ),
            ]),
            const SizedBox(height: 20),
            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
    );
  }

  Widget _profileCard(
    BuildContext context, {
    required String nama,
    required String jabatanDivisi,
    required String nik,
    String? fotoUrl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty) ? NetworkImage(fotoUrl) : null,
                child: (fotoUrl == null || fotoUrl.isEmpty)
                    ? Icon(Icons.person_rounded, size: 40, color: AppColors.primary)
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
                  child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            nama,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            jabatanDivisi,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Text(
            'NIK: $nik',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            child: Text(
              'Edit Profil',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuGroup(List<_MenuItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: item.iconColor, size: 22),
                title: Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
                onTap: item.onTap,
              ),
              if (i != items.length - 1)
                Divider(height: 1, indent: 56, color: Colors.grey.shade100),
            ],
          );
        }),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.logout_rounded, color: Colors.red, size: 22),
        title: const Text(
          'Keluar dari Akun',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red),
        ),
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => ConfirmDialog(
              title: 'Keluar Akun',
              message: 'Apakah Anda yakin ingin keluar dari aplikasi?',
              confirmLabel: 'Keluar',
            ),
          );
          if (confirmed == true && context.mounted) {
            await context.read<AuthProvider>().logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            }
          }
        },
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });
}