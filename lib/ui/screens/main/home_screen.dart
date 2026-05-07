import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import 'package:nextech_mobile/routes/app_routes.dart';
import 'package:nextech_mobile/ui/components/global_app_bar.dart';
import 'package:nextech_mobile/ui/components/product_model.dart';
import 'package:nextech_mobile/ui/components/product_card.dart';

class HomeScreen extends StatefulWidget {
  
  final Function(int categoryIndex)? onNavigateToDiscovery; 
  const HomeScreen({super.key, this.onNavigateToDiscovery,});
  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBannerIndex = 0;
  late PageController _pageController;
  Timer? _timer;

  Duration _flashSaleTime = const Duration(hours: 2, minutes: 45, seconds: 12);
  Timer? _countdownTimer;

  late Stream<QuerySnapshot> _flashSaleStream;
  late Stream<QuerySnapshot> _forYouStream;

  final List<String> promoImages = [
    'https://images.unsplash.com/photo-1603302576837-37561b2e2302?q=80&w=1000',
    'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1000',
    'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=1000',
  ];

  @override
  void initState() {
    super.initState();
    _initFlashSaleStream();
    _initForYouStream();
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

  void _initFlashSaleStream() {
    _flashSaleStream = FirebaseFirestore.instance
        .collection('products')
        .where('is_promo', isEqualTo: true)
        .snapshots();
  }

  void _initForYouStream() {
    _forYouStream = FirebaseFirestore.instance
        .collection('products')
        .snapshots();
  }

  void _startBannerAutoScroll() {
    int startPage = promoImages.length * 333;
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: startPage,
    );

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void _startFlashSaleCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_flashSaleTime.inSeconds > 0) {
        setState(() {
          _flashSaleTime -= const Duration(seconds: 1);
        });
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String hours = _flashSaleTime.inHours.toString().padLeft(2, '0');
    String minutes = _flashSaleTime.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String seconds = _flashSaleTime.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const GlobalAppBar(showSearchBar: true),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 16),
          _buildPromoBanner(colorScheme),
          const SizedBox(height: 20),
          _buildCategories(theme),
          const SizedBox(height: 20),
          _buildFlashSaleSection(theme, colorScheme, hours, minutes, seconds),
          const SizedBox(height: 24),
          _buildForYouSection(theme),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(ColorScheme colorScheme) {
    return Column(
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
                color: _currentBannerIndex == index
                    ? colorScheme.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategories(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "CATEGORIES",
            style: AppText.heading1.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
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
                      _buildCategoryIcon(
                        theme,
                        Icons.smartphone_sharp,
                        "Smartphone",
                        1,
                      ),
                      const SizedBox(width: 50),
                      _buildCategoryIcon(
                        theme,
                        Icons.laptop_chromebook,
                        "Laptop",
                        2,
                      ),
                      const SizedBox(width: 50),
                      _buildCategoryIcon(theme, Icons.earbuds, "Audio/TWS", 3),
                      const SizedBox(width: 50),
                      _buildCategoryIcon(
                        theme,
                        Icons.sports_esports,
                        "Gaming",
                        4,
                      ),
                      const SizedBox(width: 50),
                      _buildCategoryIcon(
                        theme,
                        Icons.watch_rounded,
                        "Smartwatch",
                        5,
                      ),
                      const SizedBox(width: 50),
                      _buildCategoryIcon(theme, Icons.usb, "Accessories", 6),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFlashSaleSection(
    ThemeData theme,
    ColorScheme colorScheme,
    String hours,
    String minutes,
    String seconds,
  ) {
    return Container(
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
                Text(
                  "FLASH SALE",
                  style: AppText.heading1.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    _buildTimeBox(hours),
                    _buildColon(),
                    _buildTimeBox(minutes),
                    _buildColon(),
                    _buildTimeBox(seconds),
                  ],
                ),
                const Spacer(),
                Text(
                  "SEE ALL",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _flashSaleStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Belum ada promo hari ini."),
                );
              }

              final products = snapshot.data!.docs.map((doc) {
                return ProductModel.fromFirestore(doc);
              }).toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: products.map((product) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 18.0),
                              // MEMANGGIL KOMPONEN PRODUCT CARD
                              child: ProductCard(product: product),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForYouSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          child: Text(
            "FOR YOU",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _forYouStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Belum ada produk"));
            }

            final products = snapshot.data!.docs.map((doc) {
              return ProductModel.fromFirestore(doc);
            }).toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 16,
                      children: products.map((product) {
                        // MEMANGGIL KOMPONEN PRODUCT CARD
                        return ProductCard(product: product);
                      }).toList(),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeBox(String timeText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        timeText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildColon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ":",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildCategoryIcon(
    ThemeData theme,
    IconData icon,
    String label,
    int index,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRoutes.discovery, 
          arguments: {'categoryIndex': index} // Bawa angka kategorinya
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 25),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
