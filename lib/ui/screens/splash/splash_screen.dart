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
          'assets/lottie/splash_anim.json', // Sesuaikan dengan nama file-mu
          controller: _controller,

          //Size Lottie
          width: screenWidth * 0.5,
          fit: BoxFit.contain,

          onLoaded: (composition) {
            // Mengatur durasi sesuai animasi asli
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(() async {

                //Delay splash 0.3s
                await Future.delayed(const Duration(milliseconds: 300));

                // Pengecekan sebelum pindahh
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
                }
              });
          },
        ),
      ),
    );
  }
}
