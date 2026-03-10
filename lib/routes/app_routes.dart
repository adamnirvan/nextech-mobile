import 'package:flutter/material.dart';

// Import semua layar yang kamu punya di sini
import '../ui/screens/splash/splash_screen.dart';
import '../ui/screens/onboarding/onboarding_screen.dart';
import '../ui/screens/auth/login_register_screen.dart';
import '../ui/screens/main/home_screen.dart';
import '../ui/screens/search/search_screen.dart';
import '../ui/screens/product/product_detail_screen.dart';
import '../ui/screens/cart/cart_screen.dart';




class AppRoutes {
  // 1. Bagian ini berfungsi seperti Screen.kt (Daftar Nama Rute)
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String adminDashboard = '/admin';
  static const String search = '/search';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';

// tess
  // 2. Bagian ini berfungsi seperti AppNavigation.kt (Peta Rute)
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      auth: (context) => const LoginRegisterScreen(),

      // Placeholder untuk rute yang belum kita buat utuh
      home: (context) => const HomeScreen(),
      adminDashboard: (context) =>
          const Scaffold(body: Center(child: Text("Ini Halaman Khusus Admin"))),

      search: (context) => const SearchScreen(),

      productDetail: (context) => const ProductDetailScreen(),

      cart: (context) => const CartScreen(),
    };
  }
}
