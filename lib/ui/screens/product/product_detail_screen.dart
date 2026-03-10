import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';   // Sesuaikan path

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // --- STATE ---
  int _currentImageIndex = 0;
  
  // State untuk menyimpan varian yang sedang dipilih user (Warna, Storage, dll)
  final Map<String, String> _selectedVariants = {};

  // --- DUMMY DATA (MVP Style) ---
  // Bayangkan data ini datang dari database MySQL/API kamu nanti
  final List<String> _images = ["Gambar 1", "Gambar 2", "Gambar 3"];
  final String _productName = "MacBook Pro M3 14-inch";
  final double _price = 24999000;
  final double _originalPrice = 27999000; // Harga sebelum diskon
  final double _rating = 4.9;
  final int _soldCount = 1250;
  final String _description = "The most advanced Mac laptop ever. Featuring the scary fast M3 chip, stunning Liquid Retina XDR display, and up to 22 hours of battery life. Perfect for rendering, coding, and everything in between.";

  // Data Varian Dinamis (Bisa nambah/kurang sesuai jenis produk)
  final Map<String, List<String>> _variants = {
    "Color": ["Space Black", "Silver"],
    "Storage": ["512GB", "1TB", "2TB"],
  };

  // Data Spesifikasi Dinamis (EAV Model)
  final Map<String, String> _specs = {
    "Brand": "Apple",
    "Chipset": "Apple M3 Pro (11-core CPU, 14-core GPU)",
    "RAM": "18GB Unified Memory",
    "Display": "14.2-inch Liquid Retina XDR",
    "OS": "macOS Sonoma",
  };

  @override
  void initState() {
    super.initState();
    // Set default varian yang dipilih (otomatis milih opsi pertama)
    _variants.forEach((key, options) {
      if (options.isNotEmpty) {
        _selectedVariants[key] = options.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // KUNCI HEADER TRANSPARAN: Bikin body menembus ke bawah AppBar
      extendBodyBehindAppBar: true, 
      
      // ==========================================
      // 1. TRANSPARENT HEADER
      // ==========================================
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
            onPressed: () {
              // Nanti bisa pakai package share_plus di sini
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link disalin!")));
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
              child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
            ),
            onPressed: () {}, // Navigasi ke Cart
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ==========================================
      // 2. STICKY BOTTOM ACTION BAR
      // ==========================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), // Padding bawah 32 agar aman dari poni iPhone
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            // Tombol Add to Cart (Outline)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masuk Keranjang!")));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Icon(Icons.add_shopping_cart, color: colorScheme.primary),
              ),
            ),
            const SizedBox(width: 16),
            // Tombol Buy Now (Solid)
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Buy Now", style: AppText.subtitle.copyWith(color: colorScheme.onPrimary)),
              ),
            ),
          ],
        ),
      ),

      // ==========================================
      // 3. BODY UTAMA (Scrollable)
      // ==========================================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- A. HERO IMAGE GALLERY ---
            SizedBox(
              height: screenHeight * 0.45, // Mengambil 45% layar
              child: Stack(
                children: [
                  PageView.builder(
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.grey.shade200, // Warna dummy, ganti Image.network nanti
                        child: Center(child: Icon(Icons.laptop_mac, size: 100, color: Colors.grey.shade400)),
                      );
                    },
                  ),
                  // Page Indicator
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _images.length,
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

            // Konten dibungkus agar punya padding yang rapi
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- B. MAIN INFO (Harga & Nama) ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Rp 24.999.000", style: AppText.heading1.copyWith(color: colorScheme.primary)),
                      const SizedBox(width: 8),
                      // Harga Coret
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          "Rp 27.999.000", 
                          style: AppText.caption.copyWith(
                            color: Colors.grey, 
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_productName, style: AppText.heading2),
                  const SizedBox(height: 12),
                  
                  // Social Proof (Rating & Terjual)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text("$_rating", style: AppText.subtitle.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 14, color: Colors.grey.shade300),
                      const SizedBox(width: 12),
                      Text("$_soldCount Terjual", style: AppText.body.copyWith(color: Colors.grey.shade600)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // --- C. VARIANT SELECTOR (Otomatis menyesuaikan data) ---
                  ..._variants.entries.map((entry) => _buildVariantSection(entry.key, entry.value)).toList(),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // --- D. DESCRIPTION ---
                  Text("Description", style: AppText.heading2),
                  const SizedBox(height: 12),
                  Text(
                    _description,
                    style: AppText.body.copyWith(color: Colors.grey.shade700, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // --- E. DYNAMIC SPECS TABLE ---
                  Text("Specifications", style: AppText.heading2),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: _specs.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: Text(entry.key, style: AppText.body.copyWith(color: Colors.grey.shade600))),
                              Expanded(flex: 3, child: Text(entry.value, style: AppText.body.copyWith(fontWeight: FontWeight.w600))),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 20), // Spasi ekstra di bawah biar nggak mepet tombol
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI BANTUAN UNTUK MERENDER VARIAN ---
  Widget _buildVariantSection(String title, List<String> options) {
    if (options.isEmpty) return const SizedBox.shrink(); // Jangan render kalau kosong

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.subtitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12, // Jarak antar kotak
            runSpacing: 12, // Jarak kalau turun baris
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
                    border: Border.all(
                      color: isSelected ? colorScheme.primary : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1.0,
                    ),
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