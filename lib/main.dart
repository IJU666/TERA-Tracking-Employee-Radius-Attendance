import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_besar/screens/attendance/history_screen.dart';

import 'core/constants/app_colors.dart';
import 'core/routes/app_routes.dart';
import 'firebase_options.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/leave/leave_form_screen.dart'; 
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/office_setting_screen.dart';
import '../../screens/admin/employee_management_screen.dart';
import '../../screens/attendance/absen_result_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'TERA - Absensce Application',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),

        // Sementara initialRoute langsung ke login karena splash_screen.dart
        // belum dibuat (lihat PROGRESS.md). Setelah splash_screen ada,
        // ganti initialRoute jadi AppRoutes.splash.
        initialRoute: AppRoutes.login,

        // Hanya route yang screen-nya sudah dibuat yang didaftarkan di sini.
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.history: (_) => const HistoryScreen(),
          AppRoutes.adminDashboard:(_) => const AdminDashboardScreen(), 
          AppRoutes.officeSetting:(_) => const OfficeSettingScreen(),
          AppRoutes.employeeManagement:(_) => const EmployeeManagementScreen(),
          AppRoutes.absenResult: (_) => const AbsenResultScreen(
                success: true,
                isCheckOut: false,
                latitude: 0.0,
                longitude: 0.0,
              ),
          // 2. DAFTARKAN ROUTE LEAVE FORM DI SINI
          AppRoutes.leaveForm: (_) => const LeaveFormScreen(),
        },

        // Fallback supaya app tidak crash kalau ada route yang dipanggil
        // tapi screen-nya belum didaftarkan di atas
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Halaman Belum Tersedia')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Route "${settings.name}" belum didaftarkan di main.dart.\n'
                    'Cek PROGRESS.md untuk status pengembangan screen ini.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}