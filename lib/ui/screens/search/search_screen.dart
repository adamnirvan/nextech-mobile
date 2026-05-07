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
    "iPhone 15 Pro Max", "Samsung S24 Ultra", "Sony WH-1000XM5", "RTX 4090", "iPad Air 5"
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
      recentSearches.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
      recentSearches.insert(0, query.trim());
      if (recentSearches.length > 8) recentSearches.removeLast();
    });

    // 2. LEMPAR KE DISCOVERY SCREEN
    // Kita pop (tutup Search Screen) lalu kembalikan data string ke Discovery Screen
    Navigator.pop(context, query.trim()); 
  }

  String _formatRupiah(double number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildSearchAppBar(context),
      // PENGKONDISIAN: Jika sedang mengetik, layar kosong. Jika tidak, munculkan history/rekomendasi
      body: _isTyping 
          ? const Center(
              child: Text("Tekan enter/search di keyboard untuk mencari...", style: TextStyle(color: Colors.grey)),
            )
          : _buildIdleState(theme), 
    );
  }

  Widget _buildIdleState(ThemeData theme) {
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
                const Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                GestureDetector(
                  onTap: () => setState(() => recentSearches.clear()),
                  child: const Text("Clear All", style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          if (recentSearches.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text("No recent searches", style: TextStyle(color: Colors.grey, fontSize: 13)))
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(spacing: 10, runSpacing: 10, children: recentSearches.map((k) => _buildSearchChip(k, isPopular: false)).toList()),
            ),

          const SizedBox(height: 30),

          // --- POPULAR ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text("Popular Searches", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(spacing: 10, runSpacing: 10, children: popularSearches.map((k) => _buildSearchChip(k, isPopular: true)).toList()),
          ),

          const SizedBox(height: 30),
          const Divider(height: 1, thickness: 8, color: Color(0xFFF8F9FA)),

          // --- REKOMENDASI (DARI FIRESTORE) ---
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Text("Recommended for you", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          SizedBox(
            height: 270,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').limit(5).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    data['id'] = snapshot.data!.docs[index].id;
                    return Padding(padding: const EdgeInsets.only(right: 16), child: _buildFirestoreProductCard(context, theme, data));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSearchAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
      title: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(8)),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search, // Ubah tombol enter jadi icon "Search"
          onChanged: (value) => setState(() => _isTyping = value.isNotEmpty),
          onSubmitted: _onSearchSubmitted, // PANGGIL FUNGSI SUBMIT SAAT ENTER
          decoration: InputDecoration(
            isDense: true, hintText: "Find your next tech...", border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.black87, size: 20),
            suffixIcon: _isTyping 
                ? IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 18), onPressed: () {
                    _searchController.clear();
                    setState(() => _isTyping = false);
                  }) 
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchChip(String label, {required bool isPopular}) {
    return InkWell(
      onTap: () {
        _onSearchSubmitted(label); // Langsung kirim kalau di-tap
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isPopular ? Colors.red.withOpacity(0.05) : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(20),
          border: isPopular ? Border.all(color: Colors.red.withOpacity(0.2)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPopular) const Icon(Icons.local_fire_department, color: Colors.red, size: 14),
            if (isPopular) const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 13, color: isPopular ? Colors.red.shade700 : Colors.black87, fontWeight: isPopular ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildFirestoreProductCard(BuildContext context, ThemeData theme, Map<String, dynamic> productData) {
    String imageUrl = '';
    if (productData['images'] != null && (productData['images'] as List).isNotEmpty) {
      imageUrl = productData['images'][0];
    } else if (productData['image_url'] != null) {
      imageUrl = productData['image_url'];
    }
    double price = (productData['price'] as num?)?.toDouble() ?? 0;
    int discount = (productData['discount_percentage'] as num?)?.toInt() ?? 0;
    bool isPromo = discount > 0;
    
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail, arguments: productData['id']),
      child: Container(
        width: 150, decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130, width: double.infinity, color: Colors.grey.shade300,
              child: imageUrl.isNotEmpty ? Image.network(imageUrl, fit: BoxFit.cover) : const Icon(Icons.image),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 34, child: Text(productData['title'] ?? 'No Name', style: theme.textTheme.bodyMedium, maxLines: 2)),
                  const SizedBox(height: 6),
                  Text(_formatRupiah(price), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}