import 'package:flutter/material.dart';
import '../constants/app_colors.dart'; // Buka komentar ini jika file app_colors.dart sudah siap

class AppTheme {
  // Konstanta warna sementara (Nantinya bisa dihapus dan diganti menggunakan AppColors)
  static const Color _primaryColor = Color(0xFF212121); 
  static const Color _accentColor = Color(0xFF4CAF50);
  static const Color _backgroundColor = Color(0xFFF5F5F5);
  static const Color _surfaceColor = Colors.white;
  static const Color _errorColor = Color(0xFFE53935);
  static const Color _textColor = Color(0xFF333333);

  /// -------------------------------------------
  /// LIGHT THEME
  /// -------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        secondary: _accentColor,
        surface: _surfaceColor,
        error: _errorColor,
      ),
      
      // Typography yang bersih
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 32),
        titleLarge: TextStyle(color: _textColor, fontWeight: FontWeight.w600, fontSize: 20),
        bodyLarge: TextStyle(color: _textColor, fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF666666), fontSize: 14),
      ),

      // Desain AppBar minimalis (flat)
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // PERBAIKAN: Menggunakan CardThemeData (bukan CardTheme)
      cardTheme: CardThemeData(
        color: _surfaceColor,
        elevation: 2.0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Desain Button bergaya modern dan flat
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0, // Dibuat flat
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Form input (TextField) dengan outline bersih
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _errorColor),
        ),
      ),
    );
  }

  /// -------------------------------------------
  /// DARK THEME
  /// -------------------------------------------
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: _accentColor,
        surface: Color(0xFF1E1E1E),
        error: _errorColor,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      
      // PERBAIKAN: Menggunakan CardThemeData (bukan CardTheme)
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2C2C2C)),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // Teks gelap di atas tombol putih
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }
}