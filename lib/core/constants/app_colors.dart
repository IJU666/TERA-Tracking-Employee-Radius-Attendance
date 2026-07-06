import 'package:flutter/material.dart';

/// Palet warna utama aplikasi.
/// Semua warna dipusatkan di sini agar konsisten di seluruh screen/widget.
class AppColors {
  AppColors._();

  // Warna utama (brand)
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E4FBF);
  static const Color primaryLight = Color(0xFFEFF4FF);

  // Background & surface
  static const Color background = Color(0xFFF4F6F9);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5E7EB);

  // Teks
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Status absensi / umum
  static const Color success = Color(0xFF16A34A); // Hadir
  static const Color warning = Color(0xFFF59E0B); // Belum Absen / Izin
  static const Color error = Color(0xFFDC2626); // Absen / Terlambat / gagal
  static const Color info = Color(0xFF2563EB); // Info / Lembur

  // Warna status spesifik (dipakai StatusBadge)
  static const Color statusHadirBg = Color(0xFFDCFCE7);
  static const Color statusHadirText = Color(0xFF16A34A);

  static const Color statusTerlambatBg = Color(0xFFFEE2E2);
  static const Color statusTerlambatText = Color(0xFFDC2626);

  static const Color statusBelumAbsenBg = Color(0xFFFEF3C7);
  static const Color statusBelumAbsenText = Color(0xFFD97706);

  static const Color statusIzinBg = Color(0xFFDCEAFE);
  static const Color statusIzinText = Color(0xFF2563EB);

  static const Color statusAbsenBg = Color(0xFFFEE2E2);
  static const Color statusAbsenText = Color(0xFFDC2626);
}