import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _selectedAddress = {};

  @override
  void initState() {
    super.initState();
    _fetchDefaultAddress();
  }

  Future<void> _fetchDefaultAddress() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _selectedAddress = {
        "id": "addr_1",
        "receiver": "Adam Nirvana",
        "phone": "(+62) 812-3456-7890",
        "full_address": "Jl. Teknologi No. 404, Cyber City, Jakarta Selatan, 12345"
      };
      _isLoading = false;
    });
  }

  String _formatRupiah(double number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  @override
  Widget build(BuildContext context) {
    // --- PROTEKSI & DATA DUMMY ---
    final args = ModalRoute.of(context)?.settings.arguments;
    
    // Jika args null, kita beri data dummy agar layar tidak kosong
    final List<Map<String, dynamic>> checkoutItems = (args != null) 
        ? args as List<Map<String, dynamic>> 
        : [
            {
              "id": "1",
              "name": "Nextech Pro-Book 14 M3 Chipset",
              "variant": "Space Black, 1TB",
              "price": 25000000.0,
              "qty": 1,
              "image": Icons.laptop_mac,
            },
            {
              "id": "2",
              "name": "Elite Audio Pro X1",
              "variant": "Midnight Blue",
              "price": 2499000.0,
              "qty": 1,
              "image": Icons.headphones,
            },
          ];

    double subtotal = checkoutItems.fold(0, (sum, item) => 
        sum + ((item['price'] as num).toDouble() * (item['qty'] as num).toInt()));
    double shippingFee = 50000;
    double totalPayment = subtotal + shippingFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Checkout", style: AppText.heading1.copyWith(fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- 1. ALAMAT PENGIRIMAN ---
                  InkWell(
                    onTap: () async {
                      final selectedAddress = await Navigator.pushNamed(
                        context, 
                        AppRoutes.addressList,
                        arguments: {
                          'isSelectionMode': true, 
                          'currentSelectedId': _selectedAddress['id'] // ID alamat yang sedang dipakai di checkout
                          },
                          );
                          
                          if (selectedAddress != null) {
                            setState(() {
                              _selectedAddress = selectedAddress as Map<String, dynamic>;
                              });
                              }
                    },
                    child: _buildSection(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Shipping Address", style: AppText.subtitle.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text("${_selectedAddress['receiver']} | ${_selectedAddress['phone']}", style: AppText.body),
                                const SizedBox(height: 4),
                                Text(_selectedAddress['full_address'], style: AppText.caption.copyWith(color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  // --- 2. DAFTAR PESANAN ---
                  _buildSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order Summary", style: AppText.subtitle.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...checkoutItems.map((item) => _buildProductItem(item)).toList(),
                      ],
                    ),
                  ),

                  // --- 3. RINGKASAN PEMBAYARAN ---
                  _buildSection(
                    child: Column(
                      children: [
                        _buildPaymentRow("Subtotal", _formatRupiah(subtotal)),
                        const SizedBox(height: 8),
                        _buildPaymentRow("Shipping Fee", _formatRupiah(shippingFee)),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                        _buildPaymentRow("Total Payment", _formatRupiah(totalPayment), isTotal: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomSheet: _buildBottomAction(context, totalPayment),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: item['image'] is IconData 
                ? Icon(item['image'] as IconData, color: Colors.grey)
                : const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: AppText.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("${item['qty']}x | ${item['variant']}", style: AppText.caption.copyWith(color: Colors.grey)),
                Text(_formatRupiah((item['price'] as num).toDouble()), style: AppText.body.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: child,
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isTotal ? AppText.subtitle.copyWith(fontWeight: FontWeight.bold) : AppText.body),
        Text(value, style: isTotal ? AppText.heading2.copyWith(color: Colors.red.shade700) : AppText.body),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Payment", style: AppText.caption),
                Text(_formatRupiah(total), style: AppText.subtitle.copyWith(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Simulasi Klik Bayar
              Navigator.pushNamed(context, AppRoutes.paymentSuccess);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Place Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}