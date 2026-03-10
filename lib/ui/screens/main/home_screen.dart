import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_colors.dart';
import 'package:nextech_mobile/core/theme/app_text.dart'; // Sesuaikan path-nya
import '../../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE UNTUK INTERAKSI ---
  int _currentBottomNavIndex = 0;
  int _currentPromoIndex = 0;
  int _selectedTabIndex = 0;

  // Data Dummy untuk Slider Promo
  final List<String> _promoBanners = ["Promo 1", "Promo 2", "Promo 3"];

  // Data Dummy untuk Scrollable Tabs
  final List<String> _tabs = ["All", "Phones", "Laptops", "Audio", "Wearables"];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ==========================================
      // 1. BOTTOM NAVIGATION BAR
      // ==========================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentBottomNavIndex,
        indicatorColor: Colors.grey.shade300,
        onDestinationSelected: (index) {
          setState(() => _currentBottomNavIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 2. HEADER (Background Hitam Primary)
            // ==========================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: AppColors
                  .primary, // Background warna tema utama (Hitam di Light Mode)
              child: Row(
                children: [
                  // Search Bar Fake (Bisa diklik untuk pindah ke halaman search asli)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimaryDark, // Kotak putih
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Find your Next gear",
                            style: AppText.body.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Icon Cart di kanan
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: colorScheme
                        .onPrimary, // Otomatis putih di atas background hitam
                  ),
                ],
              ),
            ),

            // ==========================================
            // 3. BODY UTAMA (Bisa di-scroll)
            // ==========================================
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // --- SLIDER PROMO GAMBAR ---
                    _buildPromoSlider(),

                    const SizedBox(height: 28),

                    // --- QUICK MENU (4 Ikon Statis) ---
                    _buildQuickMenu(colorScheme),

                    const SizedBox(height: 32),

                    // --- SCROLLABLE TABS ---
                    _buildScrollableTabs(colorScheme),

                    const SizedBox(height: 24),

                    // --- NEW PRODUCT (Horizontal Scroll) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text("New Product", style: AppText.heading2),
                    ),
                    const SizedBox(height: 16),
                    _buildHorizontalProducts(),

                    const SizedBox(height: 32),

                    // --- RANDOM PRODUCT (Vertical Grid) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text("Discover", style: AppText.heading2),
                    ),
                    const SizedBox(height: 16),
                    _buildVerticalProducts(),

                    const SizedBox(height: 40), // Spasi bawah biar lega
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FUNGSI KOMPONEN (Pecahan Kepingan UI)
  // ==========================================

  Widget _buildPromoSlider() {
    return SizedBox(
      height: 160,
      child: Stack(
        // <--- STACK DITARUH DI SINI SEBAGAI PEMBUNGKUS UTAMA
        children: [
          // 1. Slider Gambarnya (Berada di lapisan bawah)
          PageView.builder(
            onPageChanged: (index) =>
                setState(() => _currentPromoIndex = index),
            itemCount: _promoBanners.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      _promoBanners[index],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),

          // 2. Page Indicator (Berada di lapisan atas, melayang bebas)
          Positioned(
            bottom: 12, // Atur jarak dari bawah kotak gambar
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _promoBanners.length,
                (idx) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentPromoIndex == idx ? 16 : 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      _currentPromoIndex == idx ? 0.9 : 0.4,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu(ColorScheme colorScheme) {
    // List menu untuk mapping
    final List<Map<String, dynamic>> menus = [
      {"icon": Icons.smartphone, "label": "Phones"},
      {"icon": Icons.laptop_mac, "label": "Laptops"},
      {"icon": Icons.headphones, "label": "Audio"},
      {"icon": Icons.watch, "label": "Wearables"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: menus.map((menu) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(
                    0.05,
                  ), // Latar belakang ikon transparan elegan
                  shape: BoxShape.circle,
                ),
                child: Icon(menu["icon"], color: colorScheme.primary, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                menu["label"],
                style: AppText.caption.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScrollableTabs(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),

            child: Theme(
              data: Theme.of(context).copyWith(
                // 1. splashColor: Warna animasi memudar saat dilepas
                splashColor: Colors.transparent,
                // 2. highlightColor: Warna saat tombol ditahan/ditekan lama
                highlightColor: Colors.transparent,
              ),

              child: ChoiceChip(
                label: Text(_tabs[index]),
                selected: isSelected,
                showCheckmark: false, //hilangkan checkmark
                onSelected: (selected) {
                  if (selected) setState(() => _selectedTabIndex = index);
                },
                backgroundColor: Colors.transparent,
                // 2. TAMBAHKAN INI UNTUK MENGGANTI WARNA BACKGROUND SAAT DIKLIK
                selectedColor: colorScheme.primary,
                labelStyle: TextStyle(
                  // Warna teks saat diklik vs tidak diklik
                  color: isSelected
                      ? colorScheme.onPrimary
                      : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    // Garis pinggir saat diklik vs tidak diklik
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHorizontalProducts() {
    return SizedBox(
      height: 220, // Tinggi kartu menyamping
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5, // Dummy 5 produk
        itemBuilder: (context, index) {

          return GestureDetector(
            onTap: () {
              // Navigasi ke halaman detail produk
              Navigator.pushNamed(context, AppRoutes.productDetail);
            },

          child: Container(
            width: 140, // Lebar kartu
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Area Gambar (Kotak abu-abu dummy)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_outlined, color: Colors.grey),
                    ),
                  ),
                ),
                // Area Teks Detail
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nextech Pro ${index + 1}",
                        style: AppText.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rp 14.999.000",
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          );
        },
      ),
    );
  }

  Widget _buildVerticalProducts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      // GridView dibungkus agar bisa di-scroll bersamaan dengan body utama
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // Mematikan scroll internal grid
        itemCount: 6, // Dummy 6 produk
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 Kolom menyamping
          mainAxisSpacing: 16, // Jarak vertikal
          crossAxisSpacing: 16, // Jarak horizontal
          childAspectRatio: 0.75, // Rasio panjang x lebar kartu
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigasi ke halaman detail produk
              Navigator.pushNamed(context, AppRoutes.productDetail);
            },
        

          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_outlined, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gadget Random ${index + 1}",
                        style: AppText.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rp 5.499.000",
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          );
        },
      ),
    );
  }
}
