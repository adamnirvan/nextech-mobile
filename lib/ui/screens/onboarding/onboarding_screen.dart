import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import '../../../routes/app_routes.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "image": "assets/lottie/onboard_1_anim.json",
      "title": "Welcome to Nextech",
      "description": "Your ultimate destination for top-tier gadgets and tech essentials, right at your fingertips.",
    },
    {
      "image": "assets/lottie/onboard_2_anim.json",
      "title": "Find Your Dream Tech",
      "description": "Easily search, filter, and discover the perfect gadgets to match your digital lifestyle.",
    },
    {
      "image": "assets/lottie/onboard_3_anim.json",
      "title": "Safe & Secure Checkout",
      "description": "Enjoy a seamless transaction experience with multiple payment options and top-notch security.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Ambil tinggi layar untuk proporsi gambar Lottie
    final screenHeight = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        // KUNCI PERBAIKAN: Gunakan Stack agar tombol menempel di bawah
        child: Stack(
          children: [
            // --- 1. KONTEN UTAMA (Lottie + Teks) ---
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 100), // Beri ruang kosong (100) di bawah agar tidak tertutup tombol
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten
                    children: [
                      // Lottie dibungkus SizedBox agar tingginya terkontrol stabil
                      SizedBox(
                        height: screenHeight * 0.45, 
                        child: Lottie.asset(
                          page["image"],
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Text(
                        page["title"],
                        style: AppText.heading1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        page["description"],
                        style: AppText.body.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),

            // --- 2. NAVIGASI BAWAH (Selalu menempel di dasar layar) ---
            Positioned(
              bottom: 24, // Jarak dari batas bawah layar
              left: 24,   // Jarak dari kiri
              right: 24,  // Jarak dari kanan
              child: _currentPage == 2
                  // KONDISI 1: Halaman Terakhir (Tombol Get Started)
                  ? FilledButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.auth),
                      child: Text(
                        "Get Started",
                        style: AppText.subtitle.copyWith(color: colorScheme.onPrimary),
                      ),
                    )
                  // KONDISI 2: Halaman 1 & 2 (Skip, Titik, Next)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.auth),
                          child: Text(
                            "Skip",
                            style: AppText.body.copyWith(color: Colors.grey),
                          ),
                        ),
                        
                        // Indikator Titik
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            _pages.length,
                            (index) => Transform.rotate(
                              angle: 
                              0.7854,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  ),
                              height: 10,
                              width: 10, 
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? colorScheme.primary
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        ),

                        FilledButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          // Bikin tombol 'Next' jadi lebih langsing
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(80, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(
                            "Next",
                            style: AppText.subtitle.copyWith(color: colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}