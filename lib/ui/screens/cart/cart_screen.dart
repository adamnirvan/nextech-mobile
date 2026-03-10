import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';   // Sesuaikan path

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // --- DUMMY DATA ---
  // Data list keranjang yang bisa dimodifikasi
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
      "qty": 2, // Default beli 2 biar kelihatan hitungannya
      "image": Icons.headphones,
    },
  ];

  // --- LOGIKA PERHITUNGAN (Otomatis update) ---
  double get _totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += (item['price'] as double) * (item['qty'] as int);
    }
    return total;
  }

  void _increaseQty(int index) {
    setState(() {
      _cartItems[index]['qty']++;
    });
  }

  void _decreaseQty(int index) {
    setState(() {
      if (_cartItems[index]['qty'] > 1) {
        _cartItems[index]['qty']--;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      
      // ==========================================
      // 1. HEADER
      // ==========================================
      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      // ==========================================
      // 2. STICKY BOTTOM BAR (Checkout)
      // ==========================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Info Total Harga
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Price", style: AppText.caption.copyWith(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  // Nanti kalau ada waktu, angka ini bisa diformat jadi Rupiah beneran pakai package intl
                  "Rp ${_totalPrice.toStringAsFixed(0)}", 
                  style: AppText.heading2.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
            // Tombol Checkout
            FilledButton(
              onPressed: _cartItems.isEmpty ? null : () {
                // Logika kalau tombol checkout ditekan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Lanjut ke Pembayaran!")),
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Checkout", style: AppText.subtitle.copyWith(color: colorScheme.onPrimary)),
            ),
          ],
        ),
      ),

      // ==========================================
      // 3. BODY UTAMA (List Barang)
      // ==========================================
      body: _cartItems.isEmpty 
          // Jika keranjang kosong
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
          // Jika keranjang ada isinya
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _cartItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final item = _cartItems[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Gambar Kotak Kecil
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(item['image'], color: Colors.grey.shade400, size: 40),
                    ),
                    const SizedBox(width: 16),
                    
                    // B. Info Produk & Kontrol
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul & Tombol Delete
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'], 
                                  style: AppText.subtitle, 
                                  maxLines: 2, 
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _removeItem(index),
                                child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // Varian
                          Text(
                            item['variant'], 
                            style: AppText.caption.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          
                          // Harga & Tombol Plus Minus
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Rp ${(item['price'] as double).toStringAsFixed(0)}", 
                                style: AppText.body.copyWith(fontWeight: FontWeight.bold),
                              ),
                              
                              // Tombol Plus Minus
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    // Tombol Minus
                                    InkWell(
                                      onTap: () => _decreaseQty(index),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        child: Icon(Icons.remove, size: 16, color: item['qty'] == 1 ? Colors.grey : Colors.black),
                                      ),
                                    ),
                                    // Angka Quantity
                                    Container(
                                      color: Colors.grey.shade100,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      child: Text(item['qty'].toString(), style: AppText.body),
                                    ),
                                    // Tombol Plus
                                    InkWell(
                                      onTap: () => _increaseQty(index),
                                      child: const Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        child: Icon(Icons.add, size: 16),
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
    );
  }
}