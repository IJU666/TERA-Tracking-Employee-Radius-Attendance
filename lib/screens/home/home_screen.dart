import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../attendance/absen_screen.dart';
import '../widgets/attendance_list_tile.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_badge.dart';
import '../setting/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final List<Widget> _pages = [
    const _HomeContent(),
    AbsenScreen(),
    SettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadTodayStatus();
      context.read<AttendanceProvider>().loadRecentHistory();
      context.read<AttendanceProvider>().loadMonthlySummary();
      context.read<NotificationProvider>().listen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _pages[_navIndex]),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final attendance = context.watch<AttendanceProvider>();
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    return RefreshIndicator(
      onRefresh: () async {
        await attendance.loadTodayStatus();
        await attendance.loadRecentHistory();
        await attendance.loadMonthlySummary();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _buildAppBar(context, unreadCount),
          const SizedBox(height: 16),
          _buildGreetingCard(user?.nama ?? 'Karyawan'),
          const SizedBox(height: 16),
          _buildAttendanceStatusCard(context, attendance),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Layanan Cepat'),
          const SizedBox(height: 12),
          _buildQuickServices(context, attendance.remainingLeaveDays),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Absensi Terakhir',
            actionLabel: 'Lihat Semua',
            onActionTap: () {
              Navigator.pushNamed(context, AppRoutes.history);
            },
          ),
          const SizedBox(height: 12),
          _buildLastAttendance(attendance),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Ringkasan Bulan Ini'),
          const SizedBox(height: 12),
          _buildMonthlySummary(attendance),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, int unreadCount) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.badge_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TERA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Absensce Application',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notification);
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreetingCard(String nama) {
    final now = DateTime.now();
    return _cardWrapper(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormatter.greeting()}, $nama',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      DateFormatter.formatFullDateTime(now),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatusCard(BuildContext context, AttendanceProvider attendance) {
    final today = attendance.todayAttendance;
    final checkIn = today?.checkIn != null
        ? DateFormatter.formatTime(today!.checkIn!)
        : '--:--';
    final checkOut = today?.checkOut != null
        ? DateFormatter.formatTime(today!.checkOut!)
        : '--:--';

    return _cardWrapper(
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
                    'Status Kehadiran',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Presensi Hari Ini',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              StatusBadge(status: attendance.todayStatusLabel),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  icon: Icons.access_time_rounded,
                  iconColor: AppColors.primary,
                  label: 'JAM MASUK',
                  time: checkIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeInfo(
                  icon: Icons.exit_to_app_rounded,
                  iconColor: Colors.grey.shade700,
                  label: 'JAM PULANG',
                  time: checkOut,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.absen);
              },
              icon: const Icon(Icons.location_on_outlined, size: 20),
              label: const Text(
                'Mulai Presensi Sekarang',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600, letterSpacing: 0.4),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServices(BuildContext context, int remainingLeaveDays) {
    return Row(
      children: [
        Expanded(
          child: _quickServiceCard(
            icon: Icons.calendar_month_rounded,
            iconBg: Colors.orange.shade50,
            iconColor: Colors.orange,
            title: 'Ajukan Cuti',
            subtitle: 'Sisa: $remainingLeaveDays hari',
            subtitleColor: Colors.orange,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.leaveForm, arguments: 'cuti');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickServiceCard(
            icon: Icons.description_outlined,
            iconBg: Colors.blue.shade50,
            iconColor: AppColors.primary,
            title: 'Ajukan Izin',
            subtitle: 'Lihat status',
            subtitleColor: AppColors.primary,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.leaveForm, arguments: 'izin');
            },
          ),
        ),
      ],
    );
  }

  Widget _quickServiceCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastAttendance(AttendanceProvider attendance) {
    final last = attendance.lastAttendance;

    if (last == null) {
      return _cardWrapper(
        child: Text(
          'Belum ada riwayat absensi.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      );
    }

    return AttendanceListTile(attendance: last);
  }

  Widget _buildMonthlySummary(AttendanceProvider attendance) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'HADIR',
            value: attendance.monthlyHadir.toString(),
            valueColor: Colors.green,
            progress: attendance.hadirProgress,
            progressColor: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'LEMBUR',
            value: attendance.monthlyLembur.toString(),
            valueColor: Colors.orange,
            progress: attendance.lemburProgress,
            progressColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'ABSEN',
            value: attendance.monthlyAbsen.toString(),
            valueColor: Colors.red,
            progress: attendance.absenProgress,
            progressColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _cardWrapper({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: child,
    );
  }
}