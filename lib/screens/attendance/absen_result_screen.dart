import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';

class AbsenResultScreen extends StatelessWidget {
  final bool success;
  final bool isCheckOut;
  final double latitude;
  final double longitude;
  final String? errorMessage;

  const AbsenResultScreen({
    super.key,
    required this.success,
    required this.isCheckOut,
    required this.latitude,
    required this.longitude,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final color = success ? Colors.green : Colors.red;
    final icon = success ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final title = success
        ? (isCheckOut ? 'Presensi Pulang Berhasil' : 'Presensi Masuk Berhasil')
        : 'Presensi Gagal';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                success
                    ? DateFormatter.formatFullDateTime(now)
                    : (errorMessage ?? 'Terjadi kesalahan saat memproses presensi.'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 28),
              if (success) _buildDetailCard(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _detailRow(Icons.access_time_rounded, 'Waktu', DateFormatter.formatTime(DateTime.now())),
          const Divider(height: 20),
          _detailRow(
            Icons.location_on_outlined,
            'Koordinat',
            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}