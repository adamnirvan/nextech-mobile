import 'package:flutter/material.dart';
import 'routes/app_routes.dart'; // Cukup import file rute saja
import '../../../core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() {
  runApp(const NextechApp());
}

class NextechApp extends StatelessWidget {
  const NextechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nextech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Tema Terang
      darkTheme: AppTheme.darkTheme, // Tema Gelap
      // 3. FITUR SAKTI: Otomatis ikut pengaturan Dark/Light mode di HP user!
      themeMode: ThemeMode.system,

      // Pintu gerbang navigasi ditaruh di sini!
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.getRoutes(),
    );
  }
}
