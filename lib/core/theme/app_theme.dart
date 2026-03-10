import 'package:flutter/material.dart';
import 'app_colors.dart'; // Import Gudang Cat kita
import 'app_text.dart'; // Buka komen ini kalau kamu punya file app_font.dart

class AppTheme {
  
  // =========================================
  // BUKU PANDUAN 1: TEMA TERANG (LIGHT MODE)
  // =========================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // 1. SERAGAM UTAMA (Color Scheme)
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary, // Warna utama (hitam)
        onPrimary: AppColors.white, // Teks di atas warna utama (putih)
        surface: AppColors.white, // Background kotak/card (putih)
        onSurface: AppColors.textPrimaryLight, // Teks biasa (hitam/gelap)
        error: AppColors.error,
      ),

      // 2. Font
      textTheme: AppText.textTheme.apply(
        bodyColor: AppColors.textPrimaryLight, // Warna teks biasa (Hitam/Gelap)
        displayColor: AppColors.textPrimaryLight, // Warna judul (Hitam/Gelap)
      ),

      // 3. TUKANG JAHIT TOMBOL (Otomatis se-aplikasi)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // 4. TUKANG JAHIT KOTAK INPUT (Biar nggak nulis manual di tiap form!)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: AppColors.grey500),
        prefixIconColor: AppColors.grey500,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        
        // Garis normal
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        // Garis saat diklik
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // =========================================
  // BUKU PANDUAN 2: TEMA GELAP (DARK MODE)
  // =========================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark, // Latar belakang hitam pekat
      
      // 1. SERAGAM UTAMA (Dibalik warnanya!)
      colorScheme: const ColorScheme.dark(
        primary: AppColors.white, // Warna utama di Dark Mode jadi putih
        onPrimary: AppColors.black, // Teks di atas tombol putih jadi hitam
        surface: AppColors.primary, // Background kotak jadi hitam agak abu
        onSurface: AppColors.textPrimaryDark, // Teks biasa jadi terang
        error: AppColors.error,
      ),

      // 2. Font
      textTheme: AppText.textTheme.apply(
        bodyColor: AppColors.textPrimaryDark, // Warna teks biasa (Putih/Terang)
        displayColor: AppColors.textPrimaryDark, // Warna judul (Putih/Terang)
      ),

      // 3. TUKANG JAHIT TOMBOL (Otomatis se-aplikasi)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.white, // Tombolnya jadi putih
          foregroundColor: AppColors.black, // Teksnya jadi hitam
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // 4. TUKANG JAHIT KOTAK INPUT (Versi Gelap)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primary, // Kotaknya hitam
        hintStyle: const TextStyle(color: AppColors.textSecondaryDark),
        prefixIconColor: AppColors.textSecondaryDark,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey500),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.white, width: 1.5),
        ),
      ),
    );
  }
}