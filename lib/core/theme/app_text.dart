import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText {
  // =========================================
  // 1. TEMA TEKS DASAR
  // =========================================
  static TextTheme get textTheme {
    return GoogleFonts.plusJakartaSansTextTheme();
  }

  // =========================================
  // 2. KOLEKSI GAYA KHUSUS (Jalan pintas untuk dipakai di UI)
  // =========================================

  // H1: Untuk Judul Paling Besar (Misal: Teks "Nextech" di halaman Login jika tidak pakai gambar)
  static TextStyle get heading1 =>
      GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold);

  // H2: Untuk Judul Halaman / Section
  static TextStyle get heading2 =>
      GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold);

  // Subtitle: Untuk sub-judul atau teks yang butuh penekanan
  static TextStyle get subtitle =>
      GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600);

  // Body: Untuk teks biasa, paragraf, atau deskripsi
  static TextStyle get body =>
      GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.normal);

  // Caption: Untuk teks kecil (Misal: "Forgot password?" atau teks "Remember me")
  static TextStyle get caption =>
      GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.normal);
}
