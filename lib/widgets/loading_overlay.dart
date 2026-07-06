import 'package:flutter/material.dart';

/// Widget generic full-screen loading indicator.
/// Dipakai membungkus konten screen (via Stack), lalu menampilkan
/// overlay semi-transparan + spinner saat [isLoading] bernilai true.
///
/// Contoh pemakaian:
/// ```dart
/// LoadingOverlay(
///   isLoading: _isLoading,
///   child: SafeArea(child: ...),
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  /// Konten utama screen yang akan dibungkus.
  final Widget child;

  /// Jika true, overlay + spinner ditampilkan di atas [child].
  final bool isLoading;

  /// Warna overlay gelap di belakang spinner. Default hitam transparan.
  final Color overlayColor;

  /// Widget custom untuk indikator loading, jika ingin selain
  /// kartu putih + CircularProgressIndicator bawaan.
  final Widget? loadingWidget;

  /// Pesan opsional yang ditampilkan di bawah spinner.
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.overlayColor = Colors.black26,
    this.loadingWidget,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Konten asli screen.
        child,

        // Overlay loading, hanya dirender saat isLoading true
        // supaya tidak menghalangi interaksi ketika idle.
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              // Mencegah user menekan tombol/field lain saat proses
              // sedang berjalan (misal saat login).
              absorbing: true,
              child: Container(
                color: overlayColor,
                alignment: Alignment.center,
                child: loadingWidget ?? _buildDefaultIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}