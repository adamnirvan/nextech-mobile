import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_text.dart'; // Sesuaikan path
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // --- 1. STATE VARIABLES (API READY) ---
  bool _isLoading = true; // Status untuk nunggu data dari API
  int _currentImageIndex = 0;
  final Map<String, String> _selectedVariants = {};
  
  // Wadah kosong yang nanti akan diisi oleh respon Database
  Map<String, dynamic> _productData = {}; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Normalnya, kita menangkap ID produk dari halaman sebelumnya
    // final String productId = ModalRoute.of(context)?.settings.arguments as String;
    // _fetchProductDetail(productId);
    
    // Karena belum nyambung beneran, kita panggil fungsi simulasi
    if (_isLoading) {
      _fetchProductDetail("dummy_id");
    }
  }

  // --- 2. FUNGSI SIMULASI AMBIL DATA DARI DATABASE (FIRESTORE) ---
  Future<void> _fetchProductDetail(String id) async {
    // Simulasi delay internet 1 detik
    await Future.delayed(const Duration(seconds: 1)); 

    setState(() {
      // Data yang seolah-olah baru turun dari server Firebase
      _productData = {
        "id": "prod_mac_01",
        "name": "MacBook Pro M3 14-inch",
        "price": 24999000,
        "original_price": 27999000, // Bisa null jika tidak diskon
        "rating": 4.9,
        "sold_count": 1250,
        "description": "The most advanced Mac laptop ever. Featuring the scary fast M3 chip, stunning Liquid Retina XDR display, and up to 22 hours of battery life. Perfect for rendering, coding, and everything in between.",
        "images": [
          "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=1000",
          "https://images.unsplash.com/photo-1531297172864-fb57025816bb?q=80&w=1000",
          "https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?q=80&w=1000"
        ],
        "variants": {
          "Color": ["Space Black", "Silver"],
          "Storage": ["512GB", "1TB", "2TB"],
        },
        "specifications": {
          "Brand": "Apple",
          "Chipset": "Apple M3 Pro (11-core CPU, 14-core GPU)",
          "RAM": "18GB Unified Memory",
          "Display": "14.2-inch Liquid Retina XDR",
          "OS": "macOS Sonoma",
        }
      };

      // Set default varian (Otomatis pilih opsi pertama setelah data masuk)
      Map<String, dynamic> variants = _productData['variants'];
      variants.forEach((key, options) {
        if ((options as List).isNotEmpty) {
          _selectedVariants[key] = options.first;
        }
      });

      _isLoading = false; // Matikan loading
    });
  }

  // Format Rupiah Helper
  String _formatRupiah(num number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true, 
      
      // HEADER TETAP SAMA
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
              child: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
              child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
            ),
            onPressed: () {}, 
          ),
          const SizedBox(width: 8),
        ],
      ),

      // BOTTOM NAVBAR: Jangan tampilkan tombol Buy kalau datanya masih loading
      bottomNavigationBar: _isLoading ? const SizedBox.shrink() : Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Icon(Icons.add_shopping_cart, color: colorScheme.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Buy Now", style: AppText.subtitle.copyWith(color: colorScheme.onPrimary)),
              ),
            ),
          ],
        ),
      ),

      // --- 3. BODY UTAMA (DILINDUNGI OLEH LOADING STATE) ---
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- A. HERO IMAGE GALLERY ---
                SizedBox(
                  height: screenHeight * 0.45, 
                  child: Stack(
                    children: [
                      PageView.builder(
                        onPageChanged: (index) => setState(() => _currentImageIndex = index),
                        itemCount: (_productData['images'] as List).length,
                        itemBuilder: (context, index) {
                          // IMPLEMENTASI IMAGE.NETWORK DI SINI
                          return Container(
                            color: Colors.grey.shade200,
                            child: Image.network(
                              _productData['images'][index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey.shade400)),
                            ),
                          );
                        },
                      ),
                      // Page Indicator
                      Positioned(
                        bottom: 24, left: 0, right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            (_productData['images'] as List).length,
                            (idx) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentImageIndex == idx ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == idx ? colorScheme.primary : Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- B. MAIN INFO ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_formatRupiah(_productData['price']), style: AppText.heading1.copyWith(color: colorScheme.primary)),
                          const SizedBox(width: 8),
                          // Logika Harga Coret (Tampil jika original_price ada)
                          if (_productData['original_price'] != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                _formatRupiah(_productData['original_price']), 
                                style: AppText.caption.copyWith(color: Colors.grey, decoration: TextDecoration.lineThrough),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_productData['name'], style: AppText.heading2),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text("${_productData['rating']}", style: AppText.subtitle.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Container(width: 1, height: 14, color: Colors.grey.shade300),
                          const SizedBox(width: 12),
                          Text("${_productData['sold_count']} Terjual", style: AppText.body.copyWith(color: Colors.grey.shade600)),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // --- C. VARIANT SELECTOR ---
                      ...(_productData['variants'] as Map<String, dynamic>).entries.map(
                        (entry) => _buildVariantSection(entry.key, List<String>.from(entry.value))
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // --- D. DESCRIPTION ---
                      Text("Description", style: AppText.heading2),
                      const SizedBox(height: 12),
                      Text(_productData['description'], style: AppText.body.copyWith(color: Colors.grey.shade700, height: 1.5)),

                      const SizedBox(height: 24),

                      // --- E. DYNAMIC SPECS TABLE ---
                      Text("Specifications", style: AppText.heading2),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: (_productData['specifications'] as Map<String, dynamic>).entries.map((entry) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 2, child: Text(entry.key, style: AppText.body.copyWith(color: Colors.grey.shade600))),
                                  Expanded(flex: 3, child: Text(entry.value.toString(), style: AppText.body.copyWith(fontWeight: FontWeight.w600))),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildVariantSection(String title, List<String> options) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.subtitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: options.map((option) {
              final isSelected = _selectedVariants[title] == option;
              final colorScheme = Theme.of(context).colorScheme;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedVariants[title] = option);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                    border: Border.all(color: isSelected ? colorScheme.primary : Colors.grey.shade300, width: isSelected ? 1.5 : 1.0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    option,
                    style: AppText.body.copyWith(
                      color: isSelected ? colorScheme.primary : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}