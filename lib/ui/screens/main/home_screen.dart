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
  const HomeScreen({super.key, this.onNavigateToDiscovery});

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

  StreamSubscription<QuerySnapshot>? _bannerSubscription;

  List<String> promoImages = [];

  @override
  void initState() {
    super.initState();
    _initBannerStream();
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
    _bannerSubscription?.cancel();
    super.dispose();
  }

  void _initBannerStream() {
    _bannerSubscription = FirebaseFirestore.instance
        .collection('banners')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          if (snapshot.docs.isEmpty) {
            promoImages = [];
          } else {
            promoImages = snapshot.docs.map((doc) => doc['image_url'] as String).toList();
            if (promoImages.isNotEmpty) {
              _currentBannerIndex = 999 % promoImages.length;
            }
          }
        });
      }
    });
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
    _pageController = PageController(
      viewportFraction: 0.95,
      initialPage: 999,
    );

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients && promoImages.length > 1) {
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }

  Widget _buildPromoBanner(ColorScheme colorScheme) {
    if (promoImages.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            physics: promoImages.length == 1
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index % promoImages.length;
              });
            },
            itemBuilder: (context, index) {
              int realIndex = index % promoImages.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // ── Shadow supaya banner terasa floating ──
                  
                  image: DecorationImage(
                    image: NetworkImage(promoImages[realIndex]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        if (promoImages.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(promoImages.length, (index) {
              final bool active = _currentBannerIndex == index;
              // ── Dot: aktif → pill animasi, tidak aktif → lingkaran kecil ──
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ]
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
                      _buildCategoryIcon(theme, Icons.smartphone_sharp, "Smartphone", 1),
                      const SizedBox(width: 50),
                      _buildCategoryIcon(theme, Icons.laptop_chromebook, "Laptop", 2),
                      const SizedBox(width: 50),
                      _buildCategoryIcon(theme, Icons.earbuds, "Audio/TWS", 3),
                      const SizedBox(width: 50),
                      _buildCategoryIcon(theme, Icons.sports_esports, "Gaming", 4),
                      const SizedBox(width: 50),
                      _buildCategoryIcon(theme, Icons.watch_rounded, "Smartwatch", 5),
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
                // ── Vertical accent bar merah di kiri judul ──
                Container(
                  width: 4,
                  height: 20,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
                    _buildTimeBox(hours, colorScheme),
                    _buildColon(colorScheme),
                    _buildTimeBox(minutes, colorScheme),
                    _buildColon(colorScheme),
                    _buildTimeBox(seconds, colorScheme),
                  ],
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
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Belum ada promo hari ini.", style: AppText.body.copyWith(color: Colors.grey)),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "FOR YOU",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 10),
              
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _forYouStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("Belum ada produk", style: AppText.body.copyWith(color: Colors.grey)));
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

  Widget _buildTimeBox(String timeText, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        // ── Gradient merah konsisten dengan badge ProductCard ──
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFC62828)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        timeText,
        style: AppText.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildColon(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ":",
        style: AppText.heading2.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
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
          arguments: {'categoryIndex': index},
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              // ── Border tipis supaya container lebih defined ──
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            // ── Icon pakai warna primary ──
            child: Icon(icon, size: 25, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}