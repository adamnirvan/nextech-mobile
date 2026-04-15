import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import '../../../routes/app_routes.dart';
import 'package:lottie/lottie.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // PopScope mencegah user menekan tombol 'Back' HP dan kembali ke halaman Checkout yang sudah lunas
      body: PopScope(
        canPop: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. ANIMASI/IKON SUKSES
              Lottie.asset(
                'assets/lottie/paymentsuccess_anim.json',
                width: 200,
                height: 200,
                repeat: false,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),

              // 2. TEKS STATUS
              Text(
                "Payment Successful!",
                style: AppText.heading1.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 12),
              Text(
                "Hooray! Your payment was successful.\nWe are now preparing your order.",
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // 3. KOTAK RINCIAN SINGKAT
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildRowInfo("Transaction ID", "#NT-882931"),
                    const Divider(height: 24),
                    _buildRowInfo("Payment Method", "GoPay"),
                    const Divider(height: 24),
                    _buildRowInfo("Total Amount", "Rp 25.050.000"),
                  ],
                ),
              ),
              const SizedBox(height: 60),

              // 4. TOMBOL AKSI
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman Order (Tab Shipped)
                    Navigator.pushNamedAndRemoveUntil(
                      context, 
                      AppRoutes.order, 
                      (route) => route.isFirst,
                      arguments: 1 // Bersihkan history agar tidak bisa back ke checkout
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Track My Order",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Kembali ke Home
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
                },
                child: Text(
                  "Back to Homepage",
                  style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}