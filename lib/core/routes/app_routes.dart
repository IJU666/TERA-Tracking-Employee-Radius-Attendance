import 'package:flutter/material.dart';

// --- IMPORT SCREENS: AUTH ---
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';

// --- IMPORT SCREENS: HOME ---
import '../../screens/home/home_screen.dart';

// --- IMPORT SCREENS: ATTENDANCE ---
import '../../screens/attendance/absen_screen.dart';
import '../../screens/attendance/absen_result_screen.dart';
import '../../screens/attendance/history_screen.dart';

// --- IMPORT SCREENS: LEAVE ---
import '../../screens/leave/leave_form_screen.dart';
import '../../screens/leave/leave_status_screen.dart';

// --- IMPORT SCREENS: SETTING ---
import '../../screens/setting/setting_screen.dart';
import '../../screens/setting/edit_profile_screen.dart';

// --- IMPORT SCREENS: ADMIN ---
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/office_setting_screen.dart';
import '../../screens/admin/leave_approval_screen.dart';
import '../../screens/admin/employee_management_screen.dart';
import '../../screens/admin/employee_form_screen.dart';
import '../../screens/admin/employee_detail_screen.dart';

// --- IMPORT SCREENS: NOTIFICATION ---
import '../../screens/notification/notification_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Route Names Constants
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

  // Map Routing ke Widget Screen
  static final Map<String, WidgetBuilder> routes = {
    // Auth
    // splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    // forgotPassword: (context) => const ForgotPasswordScreen(),

    // // Home
    // home: (context) => const HomeScreen(),

    // // Attendance
    // absen: (context) => const AbsenScreen(),
    // absenResult: (context) => const AbsenResultScreen(),
    // history: (context) => const HistoryScreen(),

    // // Leave
    // leaveForm: (context) => const LeaveFormScreen(),
    // leaveStatus: (context) => const LeaveStatusScreen(),

    // // Setting
    // setting: (context) => const SettingScreen(),
    // editProfile: (context) => const EditProfileScreen(),

    // // Admin
    // adminDashboard: (context) => const AdminDashboardScreen(),
    // officeSetting: (context) => const OfficeSettingScreen(),
    // leaveApproval: (context) => const LeaveApprovalScreen(),
    // employeeManagement: (context) => const EmployeeManagementScreen(),
    // employeeForm: (context) => const EmployeeFormScreen(),
    // employeeDetail: (context) => const EmployeeDetailScreen(),

    // // Notification
    // notification: (context) => const NotificationScreen(),
  };
}