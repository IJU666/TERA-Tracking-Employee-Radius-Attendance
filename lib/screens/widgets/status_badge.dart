import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Pill badge status absensi/cuti/izin dengan warna sesuai status.
/// Contoh pemakaian: StatusBadge(status: 'Belum Absen')
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  ({Color bg, Color text}) get _colors {
    switch (status.toLowerCase()) {
      case 'hadir':
        return (bg: AppColors.statusHadirBg, text: AppColors.statusHadirText);
      case 'terlambat':
        return (
          bg: AppColors.statusTerlambatBg,
          text: AppColors.statusTerlambatText
        );
      case 'izin':
      case 'cuti':
        return (bg: AppColors.statusIzinBg, text: AppColors.statusIzinText);
      case 'absen':
        return (bg: AppColors.statusAbsenBg, text: AppColors.statusAbsenText);
      case 'belum absen':
      default:
        return (
          bg: AppColors.statusBelumAbsenBg,
          text: AppColors.statusBelumAbsenText
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
      ),
    );
  }
}
