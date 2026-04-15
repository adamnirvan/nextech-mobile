import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import 'dart:async';
import 'package:nextech_mobile/ui/components/global_app_bar.dart';
import '../../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE VARIABLES ---
  int _currentBannerIndex = 0;
  late PageController _pageController;
  Timer? _timer;

  Duration _flashSaleTime = const Duration(hours: 2, minutes: 45, seconds: 12);
  Timer? _countdownTimer;

  final List<String> promoImages = [
    'https://images.unsplash.com/photo-1603302576837-37561b2e2302?q=80&w=1000',
    'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1000',
    'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=1000',
  ];

  // --- LIFECYCLE ---
  @override
  void initState() {
    super.initState();
    _startBannerAutoScroll();
    _startFlashSaleCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // --- LOGIC METHODS ---
  void _startBannerAutoScroll() {
    int startPage = promoImages.length * 333;
    _pageController = PageController(viewportFraction: 0.9, initialPage: startPage);

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeIn);
      }
    });
  }

  void _startFlashSaleCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_flashSaleTime.inSeconds > 0) {
        setState(() {
          _flashSaleTime = _flashSaleTime - const Duration(seconds: 1);
        });
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  // --- WIDGET BUILDER ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String hours = _flashSaleTime.inHours.toString().padLeft(2, '0');
    String minutes = _flashSaleTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = _flashSaleTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    // --- DUMMY DATA API (Siap diganti data dari Backend) ---
    final List<Map<String, dynamic>> dummyFlashSaleData = [
      {"title": "Elite Audio Pro X1", "origPrice": "Rp 4.165.000", "promoPrice": "Rp 2.499.000", "discount": "40% OFF", "rating": "4.9", "sold": "1.2k", "isPromo": true,"imageUrl": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500"},
      {"title": "Gamer Headset Z", "origPrice": "Rp 2.000.000", "promoPrice": "Rp 1.500.000", "discount": "25% OFF", "rating": "4.7", "sold": "850", "isPromo": true,"imageUrl": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500"},
      {"title": "Smartwatch V2", "origPrice": "Rp 1.500.000", "promoPrice": "Rp 750.000", "discount": "50% OFF", "rating": "4.8", "sold": "3.4k", "isPromo": true,"imageUrl": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500"},
      {"title": "Powerbank 20k", "origPrice": "Rp 500.000", "promoPrice": "Rp 400.000", "discount": "20% OFF", "rating": "4.6", "sold": "500", "isPromo": true,"imageUrl": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500"},
    ];

    final List<Map<String, dynamic>> dummyForYouData = List.generate(10, (index) {
      // Simulasi selang-seling antara barang promo dan harga normal
      bool isPromoData = index % 2 == 0; 
      return {
        "title": "Nextech Pro-Book 14 M3 Chipset - Varian ${index + 1}",
        "origPrice": "Rp 20.000.000",
        "promoPrice": isPromoData ? "Rp 18.999.000" : null,
        "discount": isPromoData ? "5% OFF" : null,
        "rating": "4.9",
        "sold": "${200 + (index * 15)}",
        "isPromo": isPromoData,
        "imageUrl": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500"
      };
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const GlobalAppBar(showSearchBar: true),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 16),

          // --- 1. PROMO BANNER ---
          Column(
            children: [
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerIndex = index % promoImages.length;
                    });
                  },
                  itemBuilder: (context, index) {
                    int realIndex = index % promoImages.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(promoImages[realIndex]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(promoImages.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentBannerIndex == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentBannerIndex == index ? colorScheme.primary : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- 2. CATEGORIES ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("CATEGORIES", style: AppText.heading1.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategoryIcon(context, theme, Icons.smartphone_sharp, "Smartphone"),
                        const SizedBox(width: 50),
                        _buildCategoryIcon(context, theme, Icons.laptop_chromebook, "Laptop"),
                        const SizedBox(width: 50),
                        _buildCategoryIcon(context, theme, Icons.earbuds, "Audio/TWS"),
                        const SizedBox(width: 50),
                        _buildCategoryIcon(context, theme, Icons.sports_esports, "Gaming"),
                        const SizedBox(width: 50),
                        _buildCategoryIcon(context, theme, Icons.watch_rounded, "Smartwatch"),
                        const SizedBox(width: 50),
                        _buildCategoryIcon(context, theme, Icons.usb, "Accessories"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // --- 3. FLASH SALE ---
          Container(
            width: double.infinity,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("FLASH SALE", style: AppText.heading1.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          _buildTimeBox(hours), _buildColon(),
                          _buildTimeBox(minutes), _buildColon(),
                          _buildTimeBox(seconds),
                        ],
                      ),
                      const Spacer(),
                      Text("SEE ALL", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 18,
                            children: List.generate(
                              dummyFlashSaleData.length, 
                              (index) {
                                var data = dummyFlashSaleData[index];
                                return _buildFlashSaleCard(
                                  context, 
                                  theme,
                                  title: data["title"]!,
                                  originalPrice: data["origPrice"]!,
                                  promoPrice: data["promoPrice"]!,
                                  discountTag: data["discount"]!,
                                  rating: data["rating"]!,
                                  sold: data["sold"]!,
                                  isPromo: data["isPromo"]!,
                                  imageUrl: data["imageUrl"]
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- 4. FOR YOU ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Text("FOR YOU", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 16,
                    children: List.generate(
                      dummyForYouData.length,
                      (index) {
                        var data = dummyForYouData[index];
                        return _buildForYouCard(
                          context, theme,
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  

  // --- HELPER COMPONENTS ---
  Widget _buildTimeBox(String timeText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
      child: Text(timeText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildColon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(":", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildCategoryIcon(BuildContext context, ThemeData theme, IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 25),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  // --- REUSABLE PRODUCT CARDS ---
  Widget _buildFlashSaleCard(
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
    double cardWidth = screenWidth * 0.4;
    
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail),
      child: Container(
        width: 150, height: 270, // PATEN
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  clipBehavior: Clip.hardEdge, 
                  child: Image.network(
                    imageUrl, // <-- Memanggil parameter URL tadi
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                      },
                      ),
                      ),
                if (isPromo && discountTag != null)
                  Positioned(
                    top: 0, left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8))),
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
                  const SizedBox(height: 1),
                  
                  // KUNCI PROPORSI HARGA: SizedBox untuk mengunci tinggi area harga
                  SizedBox(
                    height: 46,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start, // Menyejajarkan harga ke bawah
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Color(0xFFFFD500)),
                      const SizedBox(width: 4),
                      Text(rating, style: theme.textTheme.displayMedium?.copyWith(fontSize: 12)),
                      const Spacer(),
                      Expanded(child: Text("$sold Sold", style: TextStyle(fontSize: 11, color: Colors.grey.shade600))), 
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

  Widget _buildForYouCard(
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
                  height: 130, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  clipBehavior: Clip.hardEdge, 
                  child: Image.network(
                    imageUrl, // <-- Memanggil parameter URL tadi
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                      },
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
                        Expanded(child: Text("$sold Sold", style: TextStyle(fontSize: 11, color: Colors.grey.shade600),maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,)), 
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