import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';

enum _HistoryFilter { hariIni, mingguIni, bulanIni, pilih }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryFilter _selectedFilter = _HistoryFilter.hariIni;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadHistoryByFilter(
            filter: AttendanceHistoryFilter.today,
          );
    });
  }

  Future<void> _onFilterTap(_HistoryFilter filter) async {
    if (filter == _HistoryFilter.pilih) {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 1),
        lastDate: now,
        initialDateRange: _customRange,
      );
      if (picked == null) return;
      setState(() {
        _selectedFilter = filter;
        _customRange = picked;
      });
      if (!mounted) return;
      context.read<AttendanceProvider>().loadHistoryByRange(
            start: picked.start,
            end: picked.end,
          );
      return;
    }

    setState(() => _selectedFilter = filter);

    final provider = context.read<AttendanceProvider>();
    switch (filter) {
      case _HistoryFilter.hariIni:
        provider.loadHistoryByFilter(filter: AttendanceHistoryFilter.today);
        break;
      case _HistoryFilter.mingguIni:
        provider.loadHistoryByFilter(filter: AttendanceHistoryFilter.thisWeek);
        break;
      case _HistoryFilter.bulanIni:
        provider.loadHistoryByFilter(filter: AttendanceHistoryFilter.thisMonth);
        break;
      case _HistoryFilter.pilih:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final history = attendance.historyList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: export riwayat ke PDF/Excel (belum diimplementasi)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur unduh segera hadir')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildFilterChips(),
            const SizedBox(height: 12),
            _buildStatChips(attendance),
            const SizedBox(height: 12),
            Expanded(
              child: attendance.isLoadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : history.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () => _onFilterTap(_selectedFilter),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            itemCount: history.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) => _HistoryCard(
                              attendance: history[index],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _filterChip('Hari Ini', _HistoryFilter.hariIni),
          const SizedBox(width: 8),
          _filterChip('Minggu Ini', _HistoryFilter.mingguIni),
          const SizedBox(width: 8),
          _filterChip('Bulan Ini', _HistoryFilter.bulanIni),
          const SizedBox(width: 8),
          _filterChip('Pilih', _HistoryFilter.pilih),
        ],
      ),
    );
  }

  Widget _filterChip(String label, _HistoryFilter filter) {
    final bool active = _selectedFilter == filter;
    return InkWell(
      onTap: () => _onFilterTap(filter),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (filter == _HistoryFilter.pilih) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChips(AttendanceProvider attendance) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _statChip('Hadir', attendance.periodHadir, AppColors.statusHadirText),
          const SizedBox(width: 8),
          _statChip('Terlambat', attendance.periodTerlambat, AppColors.statusTerlambatText),
          const SizedBox(width: 8),
          _statChip('Absen', attendance.periodAbsen, AppColors.statusAbsenText),
          const SizedBox(width: 8),
          _statChip('Izin', attendance.periodIzin, AppColors.statusIzinText),
        ],
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label $count',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.border),
          const SizedBox(height: 12),
          Text(
            'Belum ada riwayat pada periode ini',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AttendanceModel attendance;

  const _HistoryCard({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final status = attendance.status;
    final config = _statusConfig(status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 6,
            decoration: BoxDecoration(
              color: config.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateBlock(config.color),
                  const SizedBox(width: 14),
                  Expanded(child: _buildContent(status, config)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBlock(Color color) {
    return SizedBox(
      width: 44,
      child: Column(
        children: [
          Text(
            DateFormatter.formatDayNumber(attendance.date),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            DateFormatter.formatMonthShort(attendance.date),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormatter.formatDayName(attendance.date).toUpperCase(),
            style: TextStyle(fontSize: 9, color: color.withOpacity(0.7), letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String status, _StatusConfig config) {
    if (status == 'izin' || status == 'cuti') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.description_outlined, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"${attendance.leaveNote ?? 'Pengajuan izin disetujui'}"',
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _badge(config),
        ],
      );
    }

    if (status == 'absen') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: config.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tidak ada data kehadiran',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: config.color),
            ),
          ),
          const SizedBox(width: 8),
          _badge(config),
        ],
      );
    }

    // hadir / terlambat
    final checkIn = attendance.checkIn != null
        ? DateFormatter.formatTime(attendance.checkIn!)
        : '--:--';
    final checkOut = attendance.checkOut != null
        ? DateFormatter.formatTime(attendance.checkOut!)
        : '--:--';
    final isLate = status == 'terlambat';
    final distance = attendance.checkInLocation?.distance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.access_time_rounded, size: 16, color: AppColors.textHint),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Masuk', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                      const SizedBox(width: 24),
                      Text('Pulang', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        checkIn,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isLate ? config.color : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        '',
                      ),
                      Text(
                        checkOut,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _badge(config),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text(
              'Jarak ${distance != null ? distance.toStringAsFixed(0) : '-'} m',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _badge(_StatusConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        config.label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: config.color),
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status) {
      case 'hadir':
        return _StatusConfig(label: 'HADIR', color: AppColors.statusHadirText);
      case 'terlambat':
        return _StatusConfig(label: 'TERLAMBAT', color: AppColors.statusTerlambatText);
      case 'izin':
      case 'cuti':
        return _StatusConfig(label: 'IZIN', color: AppColors.statusIzinText);
      case 'absen':
      default:
        return _StatusConfig(label: 'ABSEN', color: AppColors.statusAbsenText);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;

  _StatusConfig({required this.label, required this.color});
}