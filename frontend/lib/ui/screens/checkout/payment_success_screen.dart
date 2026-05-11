import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import '../../../routes/app_routes.dart';
import 'package:lottie/lottie.dart';

// 👇 1. Tambahkan dua import ini untuk API
import 'package:http/http.dart' as http; 
import 'dart:convert'; 

// 👇 2. Ubah menjadi StatefulWidget
class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  String _paymentMethod = "Loading...";
  bool _isFetching = true;
  bool _hasFetched = false; // Rem agar tidak spam API

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 👇 3. Pasang Rem: Cek apakah sudah pernah fetch data?
    if (!_hasFetched) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['orderId'] != null) {
        _fetchPaymentStatus(args['orderId']);
        _hasFetched = true; // Tandai bahwa sudah fetch!
      }
    }
  }

  Future<void> _fetchPaymentStatus(String orderId) async {
    try {
      final response = await http.get(Uri.parse('https://nextech-mobile.vercel.app/get-payment-status/$orderId'));
      final data = jsonDecode(response.body);

      if (data['success']) {
        setState(() {
          _paymentMethod = "${data['paymentMethod']} (${data['channel']})";
          _isFetching = false;
        });
      }
    } catch (e) {
      setState(() {
        _paymentMethod = "Gagal memuat data";
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String orderId = args?['orderId'] ?? '-';
    final String amount = args?['amount'] ?? '0';

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                style: AppText.body.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 40),

              // 3. KOTAK RINCIAN SINGKAT
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildRowInfo("Transaction ID:", orderId),
                    const Divider(height: 24),
                    
                    // 👇 4. Masukkan variabel _paymentMethod di sini
                    _buildRowInfo("Payment Method", _paymentMethod), 
                    
                    const Divider(height: 24),
                    
                    // 👇 5. Implementasi style khusus untuk Total Harga
                    _buildRowInfo(
                      "Total Amount", 
                      "Rp $amount",
                      valueStyle: AppText.subtitle.copyWith(
                        color: const Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.order,
                      (route) => route.isFirst,
                      arguments: 1, 
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                  child: Text(
                    "Track My Order",
                    style: AppText.subtitle.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.main,
                    (route) => false,
                  );
                },
                child: Text(
                  "Back to Homepage",
                  style: AppText.body.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowInfo(String label, String value, {TextStyle? valueStyle}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppText.body.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          Text(
            value,
            style: valueStyle ?? AppText.body.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}