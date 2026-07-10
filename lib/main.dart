import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_besar/screens/attendance/history_screen.dart';

import 'core/constants/app_colors.dart';
import 'core/routes/app_routes.dart';
import 'firebase_options.dart';

// Import semua provider yang dibutuhkan
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/office_provider.dart'; // Tambahan untuk lokasi kantor
import 'providers/leave_provider.dart';   // Tambahan (antisipasi fitur izin)
import 'providers/user_provider.dart';    // Tambahan (antisipasi fitur karyawan)

import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/leave/leave_form_screen.dart'; 
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/office_setting_screen.dart';
import 'screens/admin/employee_management_screen.dart';
import 'screens/admin/leave_approval_screen.dart';

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
        
        // =====================================================================
        // PENDAFTARAN PROVIDER BARU AGAR TIDAK TERJADI PROVIDERNOTFOUNDERROR
        // =====================================================================
        ChangeNotifierProvider(create: (_) => OfficeProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // =====================================================================
      ],
      child: MaterialApp(
        title: 'GeoAbsen',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'PlusJakartaSans',
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.history: (_) => const HistoryScreen(),
          AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(), 
          AppRoutes.officeSetting: (_) => const OfficeSettingScreen(),
          AppRoutes.employeeManagement: (_) => const EmployeeManagementScreen(),
          AppRoutes.leaveForm: (_) => const LeaveFormScreen(),
          AppRoutes.leaveApproval: (_) => const LeaveApprovalScreen(), 
        },

        // Fallback jika ada route yang tidak terdefinisi
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