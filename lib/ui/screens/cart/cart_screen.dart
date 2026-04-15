import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_text.dart'; 
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // --- DUMMY DATA ---
  final List<Map<String, dynamic>> _cartItems = [
    {
      "id": "1",
      "name": "MacBook Pro M3 14-inch",
      "variant": "Space Black, 512GB",
      "price": 24999000.0,
      "qty": 1,
      "image": Icons.laptop_mac,
    },
    {
      "id": "2",
      "name": "Sony WH-1000XM5",
      "variant": "Black",
      "price": 5499000.0,
      "qty": 2, 
      "image": Icons.headphones,
    },
  ];

  // --- LOGIKA PERHITUNGAN ---
  double get _totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += (item['price'] as num).toDouble() * (item['qty'] as num).toInt();
    }
    return total;
  }

  void _increaseQty(int index) {
    setState(() => _cartItems[index]['qty']++);
  }

  void _decreaseQty(int index) {
    setState(() {
      if (_cartItems[index]['qty'] > 1) {
        _cartItems[index]['qty']--;
      }
    });
  }

  void _removeItem(int index) {
    setState(() => _cartItems.removeAt(index));
  }

  String _formatRupiah(double number) {
    // Menggunakan NumberFormat dari package intl
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID', // Format Indonesia (menggunakan titik untuk ribuan)
      symbol: 'Rp ',     // Tambahkan simbol Rp di depan
      decimalDigits: 0,  // Tidak ada angka di belakang koma
    );
    return formatCurrency.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "My Cart",
            style: AppText.heading1.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. AREA LIST PRODUK
            // ==========================================
            Expanded(
              child: _cartItems.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text("Keranjangmu masih kosong", style: AppText.subtitle.copyWith(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _cartItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            Container(
                              height: 80, width: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Icon(item['image'] as IconData, color: Colors.grey.shade400, size: 40),
                            ),
                            const SizedBox(width: 16),
                            
                            // Detail
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['name'].toString(), 
                                          style: AppText.subtitle, 
                                          maxLines: 2, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _removeItem(index),
                                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['variant'].toString(), 
                                    style: AppText.caption.copyWith(color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatRupiah((item['price'] as num).toDouble()), 
                                        style: AppText.body.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      
                                      // ==========================================
                                      // KOTAK COUNTER (100% GESTURE DETECTOR - ANTI CRASH)
                                      // ==========================================
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () => _decreaseQty(index),
                                              child: Container(
                                                width: 32, height: 32,
                                                color: Colors.transparent, // Transparan tapi tetap bisa diklik
                                                child: Icon(Icons.remove, size: 16, color: item['qty'] == 1 ? Colors.grey : Colors.black),
                                              ),
                                            ),
                                            Container(
                                              width: 36, height: 32,
                                              color: Colors.grey.shade100,
                                              alignment: Alignment.center,
                                              child: Text(item['qty'].toString(), style: AppText.body),
                                            ),
                                            GestureDetector(
                                              onTap: () => _increaseQty(index),
                                              child: Container(
                                                width: 32, height: 32,
                                                color: Colors.transparent, 
                                                child: const Icon(Icons.add, size: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // ==========================================
            // 2. AREA CHECKOUT BAR (100% GESTURE DETECTOR)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Price", style: AppText.caption.copyWith(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        _formatRupiah(_totalPrice), 
                        style: AppText.heading2.copyWith(color: colorScheme.primary),
                      ),
                    ],
                  ),
                  
                  // Tombol Checkout Custom (Dibuat manual, bukan FilledButton)
                  GestureDetector(
                    onTap: _cartItems.isEmpty ? null : () {
                      Navigator.pushNamed(context, AppRoutes.checkout);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: _cartItems.isEmpty ? Colors.grey.shade400 : colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text("Checkout", style: AppText.subtitle.copyWith(color: colorScheme.onPrimary)),
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