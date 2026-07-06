import '../constants/app_strings.dart';
class ValidatorUtil {
  ValidatorUtil._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');

  static final RegExp _nikRegex = RegExp(r'^\d{16}$');

  /// Validasi email kantor.
  static String? validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppStrings.errorEmailRequired;
    if (!_emailRegex.hasMatch(text)) return AppStrings.errorEmailInvalid;
    return null;
  }

  /// Validasi password (dipakai saat login: hanya cek tidak kosong).
  static String? validateNotEmpty(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppStrings.errorFieldRequired;
    return null;
  }

  /// Validasi password saat registrasi/ganti password (ada aturan panjang).
  static String? validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return AppStrings.errorPasswordRequired;
    if (text.length < 6) return AppStrings.errorPasswordTooShort;
    return null;
  }

  /// Validasi NIK (16 digit angka).
  static String? validateNik(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppStrings.errorFieldRequired;
    if (!_nikRegex.hasMatch(text)) return 'NIK harus 16 digit angka';
    return null;
  }

  /// Validasi konfirmasi password harus sama dengan password asli.
  static String? Function(String?) validateConfirmPassword(String original) {
    return (String? value) {
      final text = value ?? '';
      if (text.isEmpty) return AppStrings.errorFieldRequired;
      if (text != original) return 'Konfirmasi password tidak cocok';
      return null;
    };
  }
}