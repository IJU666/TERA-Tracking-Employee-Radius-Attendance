import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controller untuk animasi masuk (Scale & Fade)
  late AnimationController _entryController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  // Controller untuk animasi bernafas / denyut lingkaran background
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi Animasi Masuk (Entry Animation)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutBack, // Efek membal halus
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeIn,
      ),
    );

    // 2. Inisialisasi Animasi Denyut (Continuous Pulse Animation)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true); // Bergerak maju-mundur secara terus menerus

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Jalankan animasi masuk
    _entryController.forward();

    // 3. Panggil proses Auth Check dengan delay loading 2.5 Detik
    _handleAuthCheck();
  }

  Future<void> _handleAuthCheck() async {
    // Timer Loading tepat 2,5 detik (2500 milidetik)
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Cek status sesi login pengguna
    if (authProvider.currentUser != null) {
      final user = authProvider.currentUser!;

      if (user.isManager) {
        Navigator.pushReplacementNamed(context, AppRoutes.managerDashboard);
      } else if (user.isAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ===================================================================
          // DEKORASI LINGKARAN BACKGROUND (ANIMATED BLOBS)
          // ===================================================================
          // Lingkaran Kiri Atas
          Positioned(
            top: -size.width * 0.2,
            left: -size.width * 0.2,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: size.width * 0.75,
                height: size.width * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.06),
                ),
              ),
            ),
          ),

          // Lingkaran Kanan Bawah
          Positioned(
            bottom: -size.width * 0.25,
            right: -size.width * 0.25,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: size.width * 0.85,
                height: size.width * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
              ),
            ),
          ),

          // ===================================================================
          // KONTEN UTAMA (LOGO, TEKS, & LOADING)
          // ===================================================================
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // LOGO BERDINDING BULAT + EFEK PULSING RING
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Pulsing Glow (Lingkaran luar yang berdenyut)
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withOpacity(0.12),
                              ),
                            ),
                          ),

                          // Inner Container Logo dengan Border Bulat
                          Container(
                            width: 120,
                            height: 120,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface, // Warna Background Logo
                              border: Border.all(
                                color: AppColors.primary, // Warna Border Bulat
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.change_history_rounded,
                                  size: 50,
                                  color: AppColors.primary,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // TEKS NAMA APLIKASI
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: const Text(
                      'TERA',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8.0,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ANIMASI LOADING INDIKATOR (Berlangsung selama 2,5 Detik)
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary.withOpacity(0.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Memuat...',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.2,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}