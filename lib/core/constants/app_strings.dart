class AppStrings {
  AppStrings._();

  // Umum
  static const String appName = 'TERA';
  static const String appTagline = 'Absensce Application';

  // Auth - Login
  static const String welcomeTitle = 'Selamat Datang';
  static const String welcomeSubtitle = 'Masuk ke akun Anda';
  static const String emailLabel = 'Email';
  static const String emailHint = 'Email kantor';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Password';
  static const String forgotPassword = 'Lupa Password?';
  static const String loginButton = 'Masuk';

  // Validasi (Sudah ditambahkan untuk NIK & Konfirmasi Password)
  static const String errorEmailRequired = 'Email tidak boleh kosong';
  static const String errorEmailInvalid = 'Format email tidak valid';
  static const String errorPasswordRequired = 'Password tidak boleh kosong';
  static const String errorPasswordTooShort = 'Password minimal 6 karakter';
  static const String errorFieldRequired = 'Bagian ini tidak boleh kosong';
  static const String errorNikInvalid = 'NIK harus 16 digit angka';
  static const String errorPasswordMismatch = 'Konfirmasi password tidak cocok';

  // Auth error umum
  static const String errorLoginFailed = 'Email atau password salah';
  static const String errorNetwork = 'Periksa koneksi internet Anda';
  static const String errorUnknown = 'Terjadi kesalahan, silakan coba lagi';

  // Home
  static const String statusKehadiran = 'Status Kehadiran';
  static const String presensiHariIni = 'Presensi Hari Ini';
  static const String jamMasuk = 'JAM MASUK';
  static const String jamPulang = 'JAM PULANG';
  static const String mulaiPresensi = 'Mulai Presensi Sekarang';
  static const String layananCepat = 'Layanan Cepat';
  static const String ajukanCuti = 'Ajukan Cuti';
  static const String ajukanIzin = 'Ajukan Izin';
  static const String absensiTerakhir = 'Absensi Terakhir';
  static const String lihatSemua = 'Lihat Semua';
  static const String ringkasanBulanIni = 'Ringkasan Bulan Ini';

  // Status label
  static const String statusHadir = 'Hadir';
  static const String statusTerlambat = 'Terlambat';
  static const String statusBelumAbsen = 'Belum Absen';
  static const String statusIzin = 'Izin';
  static const String statusCuti = 'Cuti';
  static const String statusAbsen = 'Absen';
}