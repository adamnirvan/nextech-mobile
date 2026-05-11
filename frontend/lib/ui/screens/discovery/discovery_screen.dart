import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import '../../../routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// 1. IMPORT PRODUCT MODEL DAN KARTU YANG SUDAH DIBUAT
import 'package:nextech_mobile/ui/components/product_model.dart';
import 'package:nextech_mobile/ui/components/product_card.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({
    super.key,
  });

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  // --- STATE VARIABLES ---
  int activeTabIndex = 0;
  int activeFilterIndex = 0;
  String searchQuery = ""; 

  late Stream<QuerySnapshot> _productStream;

  // --- INISIALISASI AWAL ---
  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 1. TANGKAP SEBAGAI MAP 
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      bool needUpdate = false;

      // 2. Jika bawa 'searchQuery' (Dari klik Search di Home)
      if (args.containsKey('searchQuery') && searchQuery.isEmpty) {
        searchQuery = args['searchQuery'];
        activeFilterIndex = 0; // Reset tab kategori ke "ALL"
        needUpdate = true;
      }

      // 3. Jika bawa 'categoryIndex' (Dari klik Ikon Kategori di Home)
      if (args.containsKey('categoryIndex')) {
        activeFilterIndex = args['categoryIndex'];
        needUpdate = true;
      }

      // 4. Jika ada data baru yang masuk, perbarui stream-nya!
      if (needUpdate) {
        _updateStream();
      }
    }
  }

  // --- PUSAT KENDALI FILTER & SORTING ---
  void _updateStream() {
    Query query = FirebaseFirestore.instance.collection('products');

    // Filter Kategori
    String selectedCategory = filterPills[activeFilterIndex].toLowerCase();
    if (selectedCategory == "audio/tws") selectedCategory = "audio";

    if (selectedCategory != "all") {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    // Sorting Tab
    if (activeTabIndex == 0) {
      // Latest
    } else if (activeTabIndex == 1) {
      query = query.orderBy('soldCount', descending: true);
    } else if (activeTabIndex == 2) {
      query = query.orderBy('price', descending: false);
    }

    setState(() {
      _productStream = query.snapshots();
    });
  }

  final List<String> sortTabs = ["Latest", "Best Selling", "Lowest Price"];
  final List<String> filterPills = [
    "ALL",
    "SMARTPHONE",
    "LAPTOP",
    "AUDIO/TWS",
    "GAMING",
    "SMARTWATCH",
    "ACCESSORIES",
  ];

  // --- WIDGET BUILDER ---
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildDiscoveryAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterPills(),

            _buildDynamicResultText(context),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _productStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.onSurface,
                      ),
                    );
                  }


                  // 1. Ambil data mentah dari Firestore dan ubah ke Model
                  List<ProductModel> products =
                      snapshot.data!.docs.map((doc) {
                    return ProductModel.fromFirestore(doc);
                  }).toList();

                  // 2. LOGIKA FILTERING (Penyaringan berdasarkan teks pencarian)
                  if (searchQuery.isNotEmpty) {
                    products = products.where((product) {
                      // Cek apakah judul produk mengandung kata yang dicari (ignore case)
                      return product.title
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase());
                    }).toList();
                  }

                  // 3. TAMPILAN JIKA HASIL FILTER KOSONG
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: colorScheme.onSurface.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results found for "$searchQuery"',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 16,
                          children: products.map((product) {
                            return ProductCard(product: product);
                          }).toList(),
                        ),
                      );
                    },
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
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Icon(Icons.search, color: Colors.transparent, size: 0),

          // --- FAKE SEARCH BAR ---
          Expanded(
            child: GestureDetector(
              onTap: () async {
                // 1. Tunggu user ngetik dan enter di Search Screen
                final result =
                    await Navigator.pushNamed(context, AppRoutes.search);

                // 2. Kalau user benar-benar nge-search sesuatu (bukan cuma back)
                if (result != null && result is String) {
                  setState(() {
                    searchQuery = result; // Simpan kata kuncinya
                    activeFilterIndex =
                        0; // Reset tab kategori ke "ALL" biar pencariannya luas
                  });
                  _updateStream(); // Refresh Stream
                }
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.onSurface.withOpacity(0.75),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: colorScheme.onSurface.withOpacity(0.75),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Find your next tech...",
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.45),
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          icon: Icon(
            Icons.shopping_cart,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(49.0),
        child: Column(
          children: [
            _buildSortingTabs(),
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.onSurface.withOpacity(0.07),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortingTabs() {
    final colorScheme = Theme.of(context).colorScheme;

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
                _updateStream();
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive
                          ? colorScheme.onSurface
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    sortTabs[index],
                    style: TextStyle(
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withOpacity(0.45),
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

  Widget _buildDynamicResultText(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (activeFilterIndex == 0 && searchQuery.isEmpty) {
      //hapus teks
      return const SizedBox.shrink();
    }

    String resultText = "";
    if (searchQuery.isNotEmpty) {
      resultText = '"$searchQuery"';
    } else {
      resultText = '"${filterPills[activeFilterIndex]}"';
    }

    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(
          horizontal: 16.0, vertical: 8.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
          children: [
            const TextSpan(text: "Showing results for"),
            const WidgetSpan(
              child: SizedBox(width: 6),
            ),
            TextSpan(
              text: resultText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPills() {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      _updateStream();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.onSurface
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filterPills[index],
                        style: TextStyle(
                          color: isActive
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withOpacity(0.75),
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w600,
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
}