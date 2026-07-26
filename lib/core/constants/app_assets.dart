class AppAssets {
  // Private constructor agar class tidak bisa di-instantiate
  AppAssets._();

  // Base Path
  static const String _baseImagePath = 'assets/images';
  static const String _baseIconPath = 'assets/icons';

  // ==================== LOGO & BRANDING ====================
  static const String logo = '$_baseImagePath/logo.png';
  static const String logoWhite = '$_baseImagePath/logo_white.png';
  static const String logoApp = '$_baseImagePath/app_logo.png';
  

  // ==================== PLACEHOLDERS ====================
  static const String avatarPlaceholder = '$_baseImagePath/avatar_placeholder.png';
  static const String imagePlaceholder = '$_baseImagePath/image_placeholder.png';

  // ==================== ILLUSTRATIONS / STATES ====================
  static const String emptyState = '$_baseImagePath/empty_state.png';
  static const String noInternet = '$_baseImagePath/no_internet.png';
  static const String successCheck = '$_baseImagePath/success_check.png';
  static const String errorState = '$_baseImagePath/error_state.png';

  // ==================== CUSTOM ICONS (PNG/SVG) ====================
  // Jika ke depannya ada ikon kustom luar dari Material Icons
  // static const String icAttendance = '$_baseIconPath/ic_attendance.svg';
}