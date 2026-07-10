import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../widgets/confirm_dialog.dart';
import 'employee_management_screen.dart';
import 'office_setting_screen.dart';
import 'leave_approval_screen.dart';

class AdminSettingScreen extends StatefulWidget {
  const AdminSettingScreen({super.key});

  @override
  State<AdminSettingScreen> createState() => _AdminSettingScreenState();
}

class _AdminSettingScreenState extends State<AdminSettingScreen> {
  bool _pushNotifEnabled = true; // TODO: sambungkan ke shared_preferences / notification_provider agar persist

  // TODO: ganti dengan LeaveProvider.pendingCount setelah leave_provider.dart dibuat
  final int _pendingLeaveCount = 5;

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
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notification),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _buildProfileCard(
              context,
              nama: user?.nama ?? '-',
              email: user?.email ?? '-',
              fotoUrl: user?.fotoUrl,
            ),
            const SizedBox(height: 24),
            _sectionLabel('Manajemen'),
            const SizedBox(height: 10),
            _menuGroup([
              _MenuItemData(
                icon: Icons.groups_rounded,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: 'Data Karyawan',
                subtitle: 'Kelola akun & profil karyawan',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmployeeManagementScreen()),
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.location_on_rounded,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: 'Lokasi & Radius Kantor',
                subtitle: 'Atur titik koordinat & radius absensi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OfficeSettingScreen()),
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.fact_check_rounded,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: 'Persetujuan Cuti & Izin',
                subtitle: 'Setujui/tolak pengajuan',
                badgeCount: _pendingLeaveCount,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LeaveApprovalScreen()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('Notifikasi'),
            const SizedBox(height: 10),
            _buildPushNotifToggle(),
            const SizedBox(height: 20),
            _sectionLabel('Akun'),
            const SizedBox(height: 10),
            _menuGroup([
              _MenuItemData(
                icon: Icons.lock_outline_rounded,
                iconBg: Colors.grey.shade100,
                iconColor: Colors.grey.shade700,
                title: 'Ganti Password',
                onTap: () => _comingSoon(context),
              ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('Lainnya'),
            const SizedBox(height: 10),
            _menuGroup([
              _MenuItemData(
                icon: Icons.info_outline_rounded,
                iconBg: Colors.grey.shade100,
                iconColor: Colors.grey.shade700,
                title: 'Tentang Aplikasi',
                subtitle: 'Versi 1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'TERA',
                    applicationVersion: '1.0.0',
                  );
                },
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
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String nama,
    required String email,
    String? fotoUrl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty) ? NetworkImage(fotoUrl) : null,
            child: (fotoUrl == null || fotoUrl.isEmpty)
                ? Icon(Icons.person_rounded, color: AppColors.primary, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nama,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Administrator',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuGroup(List<_MenuItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.badgeCount != null && item.badgeCount! > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${item.badgeCount}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
                  ],
                ),
                onTap: item.onTap,
              ),
              if (i != items.length - 1)
                Divider(height: 1, indent: 66, color: Colors.grey.shade100),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPushNotifToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Notifikasi Push',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          'Terima notifikasi absensi & pengajuan baru',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        value: _pushNotifEnabled,
        activeColor: AppColors.primary,
        onChanged: (value) {
          setState(() => _pushNotifEnabled = value);
          // TODO: simpan preferensi ke shared_preferences / Firestore user doc,
          // dan aktifkan/nonaktifkan subscribe FCM topic setelah fcm_service.dart dibuat
        },
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => ConfirmDialog(
              title: 'Keluar Akun',
              message: 'Apakah Anda yakin ingin keluar dari aplikasi?',
              confirmLabel: 'Keluar',
              confirmColor: AppColors.error,
              icon: Icons.logout_rounded,
            ),
          );
          if (confirmed == true && context.mounted) {
            await context.read<AuthProvider>().logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            }
          }
        },
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('Keluar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final int? badgeCount;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.badgeCount,
    required this.onTap,
  });
}