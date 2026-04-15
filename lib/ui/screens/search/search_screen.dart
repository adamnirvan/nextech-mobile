import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Controller untuk membaca inputan teks
  final TextEditingController _searchController = TextEditingController();
  
  // State untuk melacak apakah user sedang mengetik atau tidak
  bool _isTyping = false;

  // --- DUMMY DATA ---
  final List<String> recentSearches = [
    "MacBook Pro M3", 
    "Mechanical Keyboard", 
    "TWS ANC", 
    "Monitor 4K"
  ];

  final List<String> popularSearches = [
    "iPhone 15 Pro Max", 
    "Samsung S24 Ultra", 
    "Sony WH-1000XM5", 
    "RTX 4090",
    "iPad Air 5"
  ];

  // Data Rekomendasi yang sudah API/Database Ready (dengan imageUrl)
  final List<Map<String, dynamic>> recommendedProducts = [
    {
      "title": "Elite Audio Pro X1", 
      "origPrice": "Rp 4.165.000", 
      "promoPrice": "Rp 2.499.000", 
      "discount": "40% OFF", 
      "rating": "4.9", 
      "sold": "1.2k", 
      "isPromo": true, 
      "imageUrl": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500"
    },
    {
      "title": "Gamer Headset Z", 
      "origPrice": "Rp 2.000.000", 
      "promoPrice": "Rp 1.500.000", 
      "discount": "25% OFF", 
      "rating": "4.7", 
      "sold": "850", 
      "isPromo": true, 
      "imageUrl": "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?q=80&w=500"
    },
    {
      "title": "Smartwatch V2", 
      "origPrice": "Rp 1.500.000", 
      "promoPrice": "Rp 750.000", 
      "discount": "50% OFF", 
      "rating": "4.8", 
      "sold": "3.4k", 
      "isPromo": true, 
      "imageUrl": "https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=500"
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildSearchAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. RECENT SEARCHES
            // ==========================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Searches",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Logika menghapus riwayat
                      setState(() {
                        recentSearches.clear();
                      });
                    },
                    child: const Text(
                      "Clear All",
                      style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            
            if (recentSearches.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("No recent searches", style: TextStyle(color: Colors.grey, fontSize: 13)),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: recentSearches.map((keyword) {
                    return _buildSearchChip(keyword, isPopular: false);
                  }).toList(),
                ),
              ),

            const SizedBox(height: 30),

            // ==========================================
            // 2. POPULAR SEARCHES
            // ==========================================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                "Popular Searches",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: popularSearches.map((keyword) {
                  return _buildSearchChip(keyword, isPopular: true);
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(height: 1, thickness: 8, color: Color(0xFFF8F9FA)), // Separator tebal

            // ==========================================
            // 3. RECOMMENDED PRODUCTS
            // ==========================================
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Text(
                "Recommended for you",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            
            // Horizontal scroll untuk rekomendasi
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  recommendedProducts.length,
                  (index) {
                    var data = recommendedProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildProductCard(
                        context, 
                        theme,
                        title: data["title"],
                        originalPrice: data["origPrice"],
                        promoPrice: data["promoPrice"],
                        discountTag: data["discount"],
                        rating: data["rating"],
                        sold: data["sold"],
                        isPromo: data["isPromo"],
                        imageUrl: data["imageUrl"], // Melempar URL gambar ke fungsi builder
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- APPBAR KHUSUS PENCARIAN ---
  PreferredSizeWidget _buildSearchAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true, 
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(fontSize: 14),
          onChanged: (value) {
            setState(() {
              _isTyping = value.isNotEmpty;
            });
          },
          decoration: InputDecoration(
            isDense: true,
            hintText: "Find your next tech...",
            hintStyle: const TextStyle(color: Color(0xFF7E7E7E)),
            prefixIcon: const Icon(Icons.search, color: Colors.black87, size: 20),
            suffixIcon: _isTyping 
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isTyping = false;
                      });
                    },
                  ) 
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(right: 10),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: CHIPS PENCARIAN ---
  Widget _buildSearchChip(String label, {required bool isPopular}) {
    return InkWell(
      onTap: () {
        _searchController.text = label;
        _searchController.selection = TextSelection.fromPosition(TextPosition(offset: label.length));
        setState(() {
          _isTyping = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isPopular ? Colors.red.withValues(alpha: 0.05) : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(20),
          border: isPopular ? Border.all(color: Colors.red.withValues(alpha: 0.2)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPopular) ...[
              const Icon(Icons.local_fire_department, color: Colors.red, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isPopular ? Colors.red.shade700 : Colors.black87,
                fontWeight: isPopular ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE PRODUCT CARD (API Ready & Rata Atas) ---
  Widget _buildProductCard(
    BuildContext context, ThemeData theme, {
    required String title,
    required String originalPrice,
    String? promoPrice,
    String? discountTag,
    required String rating,
    required String sold,
    required bool isPromo,
    required String imageUrl, // Parameter baru wajib diisi
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail),
      child: Container(
        width: 150, height: 270, 
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest, 
          borderRadius: BorderRadius.circular(8)
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Menggunakan Image.network untuk database ready
                Container(
                  height: 130, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  clipBehavior: Clip.hardEdge, 
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
                if (isPromo && discountTag != null)
                  Positioned(
                    top: 0, left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700, 
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8))
                      ),
                      child: Text(discountTag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 34,
                    child: Text(title, style: theme.textTheme.bodyMedium?.copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 6),
                  
                  // Kunci kelurusan harga: Rapat atas (MainAxisAlignment.start)
                  SizedBox(
                    height: 46,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start, 
                      children: [
                        if (isPromo) ...[
                          Text(promoPrice ?? "", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red.shade700)),
                          Text(originalPrice, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, decoration: TextDecoration.lineThrough)),
                        ] else ...[
                          Text(originalPrice, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Color(0xFFFFD500)),
                      const SizedBox(width: 4),
                      Text(rating, style: theme.textTheme.displayMedium?.copyWith(fontSize: 12)),
                      const Spacer(),
                      Expanded(
                        child: Text("$sold sold", style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)
                      ), 
                    ],
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