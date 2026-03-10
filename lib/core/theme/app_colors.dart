import 'package:flutter/material.dart';

class AppColors {
  // 1. BRAND COLORS (Identitas Nextech)
  static const Color primary = Color(0xFF1A1A1A); 
  
  
  // 2. NEUTRALS (Background & Elemen UI)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color backgroundLight = Color(0xFFF8F9FA); // Putih tulang buat bg layar
  static const Color backgroundDark = Color(0xFF121212); // Hitam gelap buat dark mode
  
  // Spektrum Abu-abu untuk Border & Kotak Input
  static const Color grey100 = Color(0xFFF3F4F6); // Bg kotak input
  static const Color grey300 = Color(0xFFD1D5DB); // Garis kotak input
  static const Color grey500 = Color(0xFF6B7280); // Ikon abu-abu
  
  // 3. SEMANTIC (Status)
  static const Color success = Color(0xFF10B981); // Hijau sukses
  static const Color error = Color(0xFFEF4444); // Merah error
  static const Color warning = Color(0xFFF59E0B); // Oranye peringatan
  
  // 4. TEXT COLORS
  static const Color textPrimaryLight = Color(0xFF111827); // Teks utama di Light Mode
  static const Color textSecondaryLight = Color(0xFF4B5563); // Teks deskripsi di Light Mode
  
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Teks utama di Dark Mode
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Teks deskripsi di Dark Mode
}