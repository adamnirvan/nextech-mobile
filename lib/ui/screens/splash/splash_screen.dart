import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  // --- SEMUA LOGIKA PENGECEKAN KITA JADIKAN SATU DI DALAM FUNGSI INI ---
  Future<void> _checkLoginStatus() async {
    if (!mounted) return;

    // 1. Cek Deep Link Xendit Dulu
    try {
      final appLink = AppLinks();
      final Uri? initialUri = await appLink.getInitialLink();

      if (initialUri != null &&
          initialUri.scheme == 'nextech' &&
          initialUri.host == 'payment-success') {

            debugPrint("🔗 URL dari Xendit: $initialUri");
            
            final String? orderId = initialUri.queryParameters['orderId'];
            final String? amount = initialUri.queryParameters['amount'];

        Navigator.pushReplacementNamed(context, AppRoutes.paymentSuccess, arguments: {'orderId': orderId, 'amount': amount});
        return; 
      }
    } catch (e) {
      debugPrint("Gagal mengecek Deep Link: $e");
    }

    // 2. Kalau bukan dari Xendit, cek status Login Firebase
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Sudah login -> lempar ke Main
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      // Belum login -> lempar ke Onboarding
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/splash_anim.json',
          controller: _controller,
          width: screenWidth * 0.5,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(() async {
                // Jeda sedikit biar mulus
                await Future.delayed(const Duration(milliseconds: 300));

                if (context.mounted) {
                  // PANGGIL FUNGSI SAKTI KITA DI SINI!
                  _checkLoginStatus(); 
                }
              });
          },
        ),
      ),
    );
  }
}