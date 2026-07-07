/// Kumpulan nama route yang dipakai di seluruh aplikasi.
///
/// Catatan: sengaja hanya berisi konstanta nama route (bukan mapping ke
/// Widget) supaya file ini bisa langsung dipakai oleh login_screen.dart &
/// home_screen.dart tanpa perlu semua screen lain sudah dibuat.
///
/// Setelah semua screen selesai dibuat, tambahkan `routes` map di
/// main.dart / app_router terpisah, contoh:
///
/// MaterialApp(
///   initialRoute: AppRoutes.splash,
///   routes: {
///     AppRoutes.login: (_) => const LoginScreen(),
///     AppRoutes.home: (_) => const HomeScreen(),
///     ...
///   },
/// )
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';

  static const String absen = '/absen';
  static const String absenResult = '/absen-result';
  static const String history = '/history';

  static const String leaveForm = '/leave-form';
  static const String leaveStatus = '/leave-status';

  static const String setting = '/setting';
  static const String editProfile = '/edit-profile';

  static const String adminDashboard = '/admin-dashboard';
  static const String officeSetting = '/office-setting';
  static const String leaveApproval = '/leave-approval';
  static const String employeeManagement = '/employee-management';
  static const String employeeForm = '/employee-form';
  static const String employeeDetail = '/employee-detail';

  static const String notification = '/notification';
}
