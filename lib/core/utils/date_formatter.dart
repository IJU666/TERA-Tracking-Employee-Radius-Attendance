import 'package:flutter/material.dart';
// --- TAMBAHKAN IMPORT INI ---
import 'package:intl/intl.dart'; 

class DateFormatter {
  DateFormatter._();

  static const List<String> _hariList = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    "Jum'at",
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _bulanList = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _bulanSingkat = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MEI',
    'JUN',
    'JUL',
    'AGU',
    'SEP',
    'OKT',
    'NOV',
    'DES',
  ];

  /// Sapaan berdasarkan jam saat ini: Pagi / Siang / Sore / Malam.
  static String greeting([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  /// Format lengkap: "Senin, 29 Juni 2026 • 08:14"
  static String formatFullDateTime(DateTime date) {
    final hari = _hariList[date.weekday - 1];
    final bulan = _bulanList[date.month - 1];
    final jam = DateFormat('HH:mm').format(date); // Aman setelah di-import
    return '$hari, ${date.day} $bulan ${date.year} • $jam';
  }

  /// Format tanggal saja: "29 Juni 2026"
  static String formatDate(DateTime date) {
    final bulan = _bulanList[date.month - 1];
    return '${date.day} $bulan ${date.year}';
  }

  /// Format nama hari saja: "Senin"
  static String formatDayName(DateTime date) {
    return _hariList[date.weekday - 1];
  }

  /// Format jam saja: "08:14"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date); // Aman setelah di-import
  }

  /// Format singkat untuk kartu riwayat: bulan 3 huruf, contoh "JUN"
  static String formatMonthShort(DateTime date) {
    return _bulanSingkat[date.month - 1];
  }

  /// Format tanggal untuk kartu riwayat, dipakai berdampingan dengan
  /// formatMonthShort. Contoh dipakai: "JUN" + "26".
  static String formatDayNumber(DateTime date) {
    return date.day.toString().padLeft(2, '0');
  }
}