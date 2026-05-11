import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isTyping = false;

  // --- HISTORI PENELUSURAN ---
  List<String> recentSearches = ["MacBook Pro", "Headphone"];

  // --- REKOMENDASI PENELUSURAN ---
  final List<String> popularSearches = [
    "iPhone 15 Pro Max",
    "Samsung S24 Ultra",
    "Sony WH-1000XM5",
    "RTX 4090",
    "iPad Air 5"
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // LOGIKA SAAT ENTER DITEKAN
  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;

    // 1. Simpan ke histori
    setState(() {
      recentSearches.removeWhere(
          (item) => item.toLowerCase() == query.toLowerCase());
      recentSearches.insert(0, query.trim());
      if (recentSearches.length > 8) recentSearches.removeLast();
    });

    // 2. LEMPAR KE DISCOVERY SCREEN
    Navigator.pop(context, query.trim());
  }

  String _formatRupiah(double number) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(number);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildSearchAppBar(context, colorScheme),
      // PENGKONDISIAN: Jika sedang mengetik, layar kosong. Jika tidak, munculkan history/rekomendasi
      body: _isTyping
          ? Center(
              child: Text(
                "Tekan enter/search di keyboard untuk mencari...",
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            )
          : _buildIdleState(colorScheme),
    );
  }

  Widget _buildIdleState(ColorScheme colorScheme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HISTORI ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Searches",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => recentSearches.clear()),
                  child: const Text(
                    "Clear All",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (recentSearches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "No recent searches",
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 13,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: recentSearches
                    .map((k) => _buildSearchChip(k,
                        isPopular: false, colorScheme: colorScheme))
                    .toList(),
              ),
            ),

          const SizedBox(height: 30),

          // --- POPULAR ---
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 12.0),
            child: Text(
              "Popular Searches",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: popularSearches
                  .map((k) => _buildSearchChip(k,
                      isPopular: true, colorScheme: colorScheme))
                  .toList(),
            ),
          ),

          const SizedBox(height: 30),
          Divider(
            height: 1,
            thickness: 8,
            color: colorScheme.surfaceContainerHighest,
          ),

          // --- REKOMENDASI (DARI FIRESTORE) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Text(
              "Recommended for you",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(
            height: 240,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.onSurface,
                    ),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    data['id'] = snapshot.data!.docs[index].id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildProductCard(context, colorScheme, data),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────
  PreferredSizeWidget _buildSearchAppBar(
      BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(
              Icons.search,
              color: colorScheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (value) =>
                    setState(() => _isTyping = value.isNotEmpty),
                onSubmitted: _onSearchSubmitted,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: "Find your next tech...",
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            // Tombol clear hanya muncul saat mengetik
            if (_isTyping)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSurface.withOpacity(0.45),
                  size: 18,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _isTyping = false);
                },
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  // ── SEARCH CHIP ───────────────────────────────────────────────────────
  Widget _buildSearchChip(String label,
      {required bool isPopular, required ColorScheme colorScheme}) {
    return InkWell(
      onTap: () => _onSearchSubmitted(label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isPopular
              ? Colors.red.withOpacity(0.05)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: isPopular
              ? Border.all(color: Colors.red.withOpacity(0.2))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPopular) ...[
              const Icon(
                Icons.local_fire_department,
                color: Colors.red,
                size: 14,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isPopular
                    ? Colors.red.shade700
                    : colorScheme.onSurface.withOpacity(0.65),
                fontWeight:
                    isPopular ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PRODUCT CARD ──────────────────────────────────────────────────────
  // Mengikuti struktur ProductCard widget yang asli
  String _formatSold(dynamic sold) {
    int parsedSold =
        int.tryParse(sold.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return NumberFormat.compact().format(parsedSold);
  }

  Widget _buildProductCard(BuildContext context, ColorScheme colorScheme,
      Map<String, dynamic> productData) {
    String imageUrl = '';
    if (productData['images'] != null &&
        (productData['images'] as List).isNotEmpty) {
      imageUrl = productData['images'][0];
    } else if (productData['image_url'] != null) {
      imageUrl = productData['image_url'];
    }

    final int price = (productData['price'] as num?)?.toInt() ?? 0;
    final int? originalPrice =
        (productData['original_price'] as num?)?.toInt();
    final int discount =
        (productData['discount_percentage'] as num?)?.toInt() ?? 0;
    final bool isPromo = discount > 0;
    final double rating = (productData['rating'] as num?)?.toDouble() ?? 0.0;
    final dynamic soldCount = productData['soldCount'] ?? 0;

    final String priceFormatted =
        "Rp ${NumberFormat.decimalPattern('id').format(price)}";
    final String originalPriceFormatted = originalPrice != null
        ? "Rp ${NumberFormat.decimalPattern('id').format(originalPrice)}"
        : priceFormatted;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: productData['id'],
      ),
      child: Container(
        width: 150,
        height: 210,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── IMAGE + BADGE ──
            Stack(
              children: [
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 36,
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                        )
                      : Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 36,
                            color: colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                ),
                if (isPromo)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFFFF6F00)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFE53935).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_offer_rounded,
                              size: 9, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            "$discount% OFF",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ── INFO ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    Text(
                      productData['title'] ?? 'No Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Harga
                    if (isPromo) ...[
                      Text(
                        priceFormatted,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: colorScheme.error,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        originalPriceFormatted,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurface.withOpacity(0.4),
                          decoration: TextDecoration.lineThrough,
                          decorationColor:
                              colorScheme.onSurface.withOpacity(0.4),
                          height: 1.1,
                        ),
                      ),
                    ] else ...[
                      Text(
                        priceFormatted,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: colorScheme.onSurface,
                          height: 1.1,
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),

                    // Rating & sold
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 12, color: Color(0xFFFFD600)),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withOpacity(0.75),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            "·",
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${_formatSold(soldCount)} sold",
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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