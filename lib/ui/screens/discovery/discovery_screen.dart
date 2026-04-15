import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  // --- STATE VARIABLES ---
  int activeTabIndex = 0;
  int activeFilterIndex = 0;

  final List<String> sortTabs = ["Latest", "Best Selling", "Lowest Price"];
  final List<String> filterPills = ["SMARTPHONE", "LAPTOP", "AUDIO/TWS", "GAMING", "SMARTWATCH", "ACCESSORIES"];

  // --- WIDGET BUILDER ---
  @override
  Widget build(BuildContext context) {
    // 1. Ambil Theme agar desain card selaras dengan HomeScreen
    final theme = Theme.of(context);

    // DUMMY DATA API
    // Perhatikan: Value "sold" sekarang hanya berisi angka murni (tanpa kata "sold")
  final List<Map<String, dynamic>> latestData = [
      {"title": "Nextech Pro Max Ultra Titanium", "origPrice": "Rp 10.000.000", "promoPrice": "Rp 7.000.000", "discount": "30% OFF", "rating": "4.9", "sold": "1.2k", "isPromo": true, "imageUrl": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=500"},
      {"title": "Nextech Series X Smart Watch", "origPrice": "Rp 5.000.000", "promoPrice": null, "discount": null, "rating": "4.8", "sold": "856", "isPromo": false, "imageUrl": "https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=500"},
    ];

    // Tab 1: Best Selling
  final List<Map<String, dynamic>> bestSellingData = [
      {"title": "Nextech Audio Master Over-Ear", "origPrice": "Rp 3.250.000", "promoPrice": null, "discount": null, "rating": "4.7", "sold": "2.1k", "isPromo": false, "imageUrl": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500"},
      {"title": "Nextech Pro-Book 14", "origPrice": "Rp 20.000.000", "promoPrice": null, "discount": null, "rating": "5.0", "sold": "5.4k", "isPromo": false, "imageUrl": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=500"},
    ];

    // Tab 2: Lowest Price
  final List<Map<String, dynamic>> lowestPriceData = [
      {"title": "USB-C Fast Charging Cable", "origPrice": "Rp 150.000", "promoPrice": "Rp 99.000", "discount": "34% OFF", "rating": "4.9", "sold": "10k+", "isPromo": true, "imageUrl": "https://images.unsplash.com/photo-1615526659184-cc4d6c4495de?q=80&w=500"},
      {"title": "Nextech Phone Case Clear", "origPrice": "Rp 100.000", "promoPrice": null, "discount": null, "rating": "4.6", "sold": "8k", "isPromo": false, "imageUrl": "https://images.unsplash.com/photo-1541560052-5e137f229371?q=80&w=500"},
    ];

    List<Map<String, dynamic>> currentData = [];
    if (activeTabIndex == 0) {
      currentData = latestData;
    } else if (activeTabIndex == 1) {
      currentData = bestSellingData;
    } else {
      currentData = lowestPriceData;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildDiscoveryAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterPills(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                  children: [
                    TextSpan(text: "Showing results for "),
                    TextSpan(text: '"Smartphones"', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // --- PRODUCT GRID (MENGGUNAKAN WRAP PATEN) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 16,
                      children: List.generate(
                        currentData.length,
                        (index) {
                          var data = currentData[index];
                          return _buildProductCard(
                            context,
                            theme, // Mengirim theme ke dalam widget card
                            title: data["title"],
                            originalPrice: data["origPrice"],
                            promoPrice: data["promoPrice"],
                            discountTag: data["discount"],
                            rating: data["rating"],
                            sold: data["sold"],
                            isPromo: data["isPromo"],
                            imageUrl: data["imageUrl"]
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- HELPER COMPONENTS ---
PreferredSizeWidget _buildDiscoveryAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Icon(Icons.search, color: Colors.transparent, size: 0),
          
          // --- PERUBAHAN: FAKE SEARCH BAR ---
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigasi ke halaman SearchScreen saat di-klik
                Navigator.pushNamed(context, AppRoutes.search);
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12), // Menggantikan contentPadding TextField
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black87, width: 0.5),
                ),
                // Menggunakan Row biasa alih-alih TextField
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Find your next tech...",
                        style: TextStyle(color: Color(0xFF7E7E7E), fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // --- AKHIR PERUBAHAN ---
          
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          icon: const Icon(Icons.shopping_cart, color: Colors.black87),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(49.0),
        child: Column(
          children: [
            _buildSortingTabs(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          ],
        ),
      ),
    );
  }

  Widget _buildSortingTabs() {
    return SizedBox(
      height: 48,
      child: Row(
        children: List.generate(sortTabs.length, (index) {
          bool isActive = activeTabIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  activeTabIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isActive ? Colors.black : Colors.transparent, width: 2)),
                ),
                child: Center(
                  child: Text(
                    sortTabs[index],
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.black : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilterPills() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 12,
                children: List.generate(filterPills.length, (index) {
                  bool isActive = activeFilterIndex == index;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        activeFilterIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.black : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filterPills[index],
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black87,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- REUSABLE PRODUCT CARD (100% Identik dengan HomeScreen) ---
  Widget _buildProductCard(
    BuildContext context, ThemeData theme, {
    required String title,
    required String originalPrice,
    String? promoPrice,
    String? discountTag,
    required String rating,
    required String sold,
    required bool isPromo,
    required String imageUrl,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth / 2) - 20; 
    if (cardWidth > 220) cardWidth = 220; 

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail),
      child: Container(
        width: cardWidth, height: 300, // PATEN
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 160, width: double.infinity,
                  color: Colors.grey.shade300,
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8))),
                      child: Text(discountTag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 38,
                      child: Text(title, style: theme.textTheme.bodyMedium?.copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 6),
                    
                    // KUNCI PROPORSI HARGA
                    SizedBox(
                      height: 46,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (isPromo) ...[
                            Text(promoPrice ?? "", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red.shade700)),
                            Text(originalPrice, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, decoration: TextDecoration.lineThrough)),
                          ] else ...[
                            Text(originalPrice, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Color(0xFFFFD500)),
                        const SizedBox(width: 4),
                        Text(rating, style: theme.textTheme.displayMedium?.copyWith(fontSize: 12)),
                        // Teks Sold ditarik mentok ke kanan tanpa |
                        Expanded(child: Text("$sold Sold", style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,)), 
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}