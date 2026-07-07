import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Firebase Options (Dihasilkan oleh FlutterFire CLI)
import 'firebase_options.dart';

// Konfigurasi Inti (Route saja, Theme dihapus)
import 'core/routes/app_routes.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/office_provider.dart';
import 'providers/leave_provider.dart';
import 'providers/notification_provider.dart';

void main() async {
  // Wajib dipanggil sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase menggunakan konfigurasi dari firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Jalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Daftarkan semua provider yang ada di folder lib/providers/
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => OfficeProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Employee Attendance App',
        debugShowCheckedModeBanner: false,
        
        // Menggunakan tema default Flutter karena app_theme dihapus
        theme: ThemeData(), 
        
        // Konfigurasi Routing
        // Langsung diarahkan ke halaman Login (pastikan variabel AppRoutes.login ada di file routes kamu)
        initialRoute: AppRoutes.login, 
        routes: AppRoutes.routes,       
      ),
    );
  }
}