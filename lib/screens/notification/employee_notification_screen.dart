import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

/// Layar notifikasi khusus untuk karyawan.
/// Menonjolkan status pengajuan cuti/izin: disetujui atau ditolak oleh manager.
class EmployeeNotificationScreen extends StatelessWidget {
  const EmployeeNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;

    final sorted = [...notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notifProvider.unreadCount > 0)
            TextButton(
              onPressed: () => context.read<NotificationProvider>().markAllRead(),
              child: const Text(
                'Tandai semua dibaca',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: sorted.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final notif = sorted[index];
                final showDateHeader = index == 0 ||
                    !_isSameDay(sorted[index - 1].createdAt, notif.createdAt);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDateHeader) _buildDateHeader(notif.createdAt),
                    _EmployeeNotificationTile(
                      notification: notif,
                      onTap: () {
                        if (!notif.isRead) {
                          context.read<NotificationProvider>().markAsRead(notif.id);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);

    String label;
    if (targetDay == today) {
      label = 'Hari Ini';
    } else if (targetDay == today.subtract(const Duration(days: 1))) {
      label = 'Kemarin';
    } else {
      const bulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      label = '${date.day} ${bulan[date.month - 1]} ${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 36,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Info status absensi, cuti, dan izin kamu\nakan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

/// Tipe notifikasi yang didukung untuk karyawan:
/// 'absensi'        -> info absen masuk/pulang
/// 'cuti_disetujui' -> pengajuan cuti di-ACC manager
/// 'cuti_ditolak'   -> pengajuan cuti ditolak manager
/// 'izin_disetujui' -> pengajuan izin di-ACC manager
/// 'izin_ditolak'   -> pengajuan izin ditolak manager
/// 'umum'           -> pengumuman umum
class _EmployeeNotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _EmployeeNotificationTile({
    required this.notification,
    required this.onTap,
  });

  ({IconData icon, Color color, String? badge}) get _visual {
    switch (notification.type) {
      case 'cuti_disetujui':
      case 'izin_disetujui':
        return (
          icon: Icons.check_circle_rounded,
          color: Colors.green,
          badge: 'Disetujui',
        );
      case 'cuti_ditolak':
      case 'izin_ditolak':
        return (
          icon: Icons.cancel_rounded,
          color: Colors.red,
          badge: 'Ditolak',
        );
      case 'cuti':
        return (icon: Icons.calendar_month_rounded, color: Colors.orange, badge: null);
      case 'izin':
        return (icon: Icons.description_outlined, color: Colors.purple, badge: null);
      case 'absensi':
        return (icon: Icons.fingerprint_rounded, color: AppColors.primary, badge: null);
      default:
        return (icon: Icons.campaign_outlined, color: Colors.blueGrey, badge: null);
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final visual = _visual;
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread ? AppColors.primary.withOpacity(0.15) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: visual.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(visual.icon, color: visual.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8, top: 2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (visual.badge != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: visual.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            visual.badge!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: visual.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}