import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import 'package:nextech_mobile/ui/components/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_routes.dart'; // Pastikan path import rute ini sesuai dengan project-mu

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = true;
  ProductModel? _product;
  final Map<String, dynamic> _selectedVariants = {};
  String _productId = "";

  @override

  //Menangkap data product ID
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String? id = ModalRoute.of(context)?.settings.arguments as String?;

    if (id != null && _isLoading) {
      _productId = id;
      _fetchProductDetail(id);
    }
  }


  //Mengambil data product detail dari firestore
  Future<void> _fetchProductDetail(String id) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('products').doc(id).get();
      if (doc.exists) {
        setState(() {
          _product = ProductModel.fromFirestore(doc);
          _product!.variants.forEach((key, options) {
            if (options is List && options.isNotEmpty) {
              _selectedVariants[key] = options.first;
            }
          });
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error detail: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- 1. FUNCTION ADD TO CART ---
  Future<void> _addToCart(int quantity) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan login terlebih dahulu.")));
      return;
    }

    String variantString = _selectedVariants.isEmpty ? "Standard" : _selectedVariants.values.join("-"); 
    String safeVariantString = variantString.replaceAll(' ', ''); 
    String cartDocId = "${_productId}_$safeVariantString"; //membuat id produk unik

    final DocumentReference cartRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid).collection('cart').doc(cartDocId);

    try {
      final DocumentSnapshot cartDoc = await cartRef.get();
      if (cartDoc.exists) {
        await cartRef.update({
          'quantity': FieldValue.increment(quantity),
          'selectedVariants': _selectedVariants,
        });
      } else {
        await cartRef.set({
          'productId': _productId,
          'title': _product!.title,
          'price': _product!.price,
          'imageUrl': _product!.images.isNotEmpty ? _product!.images.first : _product!.imageUrl,
          'quantity': quantity,
          'selectedVariants': _selectedVariants,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

     if (mounted) {
        Navigator.pop(context); // Tutup bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Item added to cart!",
              style: TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal menambahkan: $e",
              style: const TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white),
            ),
            backgroundColor: Colors.red, // Tambahan opsional biar errornya jelas
          ),
        );
      }
    }
  }
  // --- 2. FUNGSI BUY NOW ---
  void _buyNow(int quantity) {
    if (_product == null) return;

    String variantString = _selectedVariants.isEmpty ? "Standard" : _selectedVariants.values.join(", ");

    final Map<String, dynamic> checkoutItem = {
      "id": _productId,
      "name": _product!.title,
      "variant": variantString,
      "price": _product!.price.toDouble(),
      "qty": quantity,
      "image": _product!.images.isNotEmpty ? _product!.images.first : _product!.imageUrl,
      "isFromCart": false,
    };

    Navigator.pop(context); // Tutup bottom sheet
    Navigator.pushNamed(context, AppRoutes.checkout, arguments: [checkoutItem]);
  }

  // --- 3. FUNGSI MEMUNCULKAN BOTTOM SHEET ---
  void _showActionBottomSheet(bool isBuyNow) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar sheet bisa menyesuaikan ukuran saat keyboard muncul/konten panjang
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext context) {
        return ProductActionBottomSheet(
          product: _product!,
          initialVariants: _selectedVariants,
          isBuyNow: isBuyNow,
          onConfirm: (int quantity, Map<String, dynamic> finalVariants) {
            // Update varian di UI utama agar sinkron dengan pilihan di bottom sheet
            setState(() {
              _selectedVariants.clear();
              _selectedVariants.addAll(finalVariants);
            });

            // Eksekusi fungsinya
            if (isBuyNow) {
              _buyNow(quantity);
            } else {
              _addToCart(quantity);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(backgroundColor: colorScheme.surface, body: const Center(child: CircularProgressIndicator()));
    }

    if (_product == null) {
      return Scaffold(backgroundColor: colorScheme.surface, body: const Center(child: Text("Produk tidak ditemukan")));
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: _buildCustomAppBar(),
      // --- 4. SAMBUNGKAN TOMBOL BOTTOM BAR ---
      bottomNavigationBar: ProductBottomBar(
        onAddToCart: () => _showActionBottomSheet(false), 
        onBuyNow: () => _showActionBottomSheet(true),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageGallery(images: _product!.images, fallbackImageUrl: _product!.imageUrl),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductMainInfo(product: _product!),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  ProductVariantSelector(
                    variants: _product!.variants,
                    selectedVariants: _selectedVariants,
                    onVariantSelected: (title, option) {
                      setState(() => _selectedVariants[title] = option);
                    },
                  ),
                  
                  if (_product!.variants.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  ProductDescription(description: _product!.description),
                  const SizedBox(height: 24),
                  ProductSpecifications(specifications: _product!.specifications),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.cart);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}


class ProductActionBottomSheet extends StatefulWidget {
  final ProductModel product;
  final Map<String, dynamic> initialVariants;
  final bool isBuyNow;
  final Function(int quantity, Map<String, dynamic> finalVariants) onConfirm;

  const ProductActionBottomSheet({
    super.key,
    required this.product,
    required this.initialVariants,
    required this.isBuyNow,
    required this.onConfirm,
  });

  @override
  State<ProductActionBottomSheet> createState() => _ProductActionBottomSheetState();
}

class _ProductActionBottomSheetState extends State<ProductActionBottomSheet> {
  int _quantity = 1;
  late Map<String, dynamic> _localVariants;

  @override
  void initState() {
    super.initState();
    _localVariants = Map.from(widget.initialVariants);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle bar ──
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: colorScheme.surfaceContainerHighest,
                  image: DecorationImage(
                    image: NetworkImage(widget.product.images.isNotEmpty ? widget.product.images.first : widget.product.imageUrl),
                    fit: BoxFit.cover,
                  )
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.title, style: AppText.subtitle.copyWith(color: colorScheme.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(widget.product.price),
                      style: AppText.heading2.copyWith(
                        color: widget.product.isPromo ? const Color(0xFFE53935) : colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // TEKS STOK — ikut colorScheme, bukan hardcode biru
                    Text("Stock: ${widget.product.stock}", style: AppText.caption.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.45), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              IconButton(icon: Icon(Icons.close, color: colorScheme.onSurface.withValues(alpha: 0.6)), onPressed: () => Navigator.pop(context))
            ],
          ),
          Divider(height: 32, color: colorScheme.onSurface.withValues(alpha: 0.1)),

          // Panggil Variant Selector yang ada di file ini
          ProductVariantSelector(
            variants: widget.product.variants,
            selectedVariants: _localVariants,
            onVariantSelected: (title, option) {
              setState(() => _localVariants[title] = option);
            },
          ),
          
          if (widget.product.variants.isNotEmpty) const Divider(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Quantity", style: AppText.subtitle.copyWith(color: colorScheme.onSurface)),
              Container(
                decoration: BoxDecoration(border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.15)), borderRadius: BorderRadius.circular(9)),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 18, color: colorScheme.onSurface),
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(_quantity.toString(), style: AppText.body.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface), textAlign: TextAlign.center),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 18, color: colorScheme.onSurface),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onConfirm(_quantity, _localVariants);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(9))),
              ),
              child: Text(widget.isBuyNow ? "Buy Now" : "Add to Cart", style: AppText.subtitle.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ProductBottomBar extends StatelessWidget {
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const ProductBottomBar({super.key, required this.onAddToCart, required this.onBuyNow});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: onAddToCart,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: colorScheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Icon(Icons.add_shopping_cart, color: colorScheme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: onBuyNow,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "Buy Now",
                style: AppText.subtitle.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductImageGallery extends StatefulWidget {
  final List<dynamic> images;
  final String fallbackImageUrl;

  const ProductImageGallery({super.key, required this.images, required this.fallbackImageUrl});

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.45,
      child: Stack(
        children: [
          PageView.builder(
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemCount: widget.images.isNotEmpty ? widget.images.length : 1,
            itemBuilder: (context, index) {
              String imgUrl = widget.images.isNotEmpty ? widget.images[index] : widget.fallbackImageUrl;
              return Container(
                color: colorScheme.surfaceContainerHighest,
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.broken_image_outlined, size: 80, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                  ),
                ),
              );
            },
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 24, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (idx) {
                    final bool active = _currentImageIndex == idx;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: active ? 24 : 8,
                      decoration: BoxDecoration(
                        color: active ? colorScheme.primary : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProductMainInfo extends StatelessWidget {
  final ProductModel product;

  const ProductMainInfo({super.key, required this.product});

  String _formatRupiah(num number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  String _formatSold(int sold) {
    return NumberFormat.compact().format(sold);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isPromo = product.isPromo && product.originalPrice != null;
    final bool hasDiscount = isPromo && product.discountPercentage > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Discount badge pill (konsisten dengan ProductCard) ──
        if (hasDiscount) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFFF6F00)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53935).withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_offer_rounded, size: 11, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  "${product.discountPercentage}% OFF",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // ── Harga (merah kalau promo) ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatRupiah(product.price),
              style: AppText.heading1.copyWith(
                color: isPromo ? const Color(0xFFE53935) : colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            if (isPromo)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  _formatRupiah(product.originalPrice!),
                  style: AppText.caption.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Judul produk ──
        Text(product.title, style: AppText.heading2),
        const SizedBox(height: 12),

        // ── Rating & sold ──
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFD600), size: 18),
            const SizedBox(width: 4),
            Text("${product.rating}", style: AppText.subtitle.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Container(width: 1, height: 14, color: colorScheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(width: 10),
            Text(
              "${_formatSold(product.soldCount)} sold",
              style: AppText.body.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ],
    );
  }
}

class ProductVariantSelector extends StatelessWidget {
  final Map<String, dynamic> variants;
  final Map<String, dynamic> selectedVariants;
  final Function(String, String) onVariantSelected;

  const ProductVariantSelector({super.key, required this.variants, required this.selectedVariants, required this.onVariantSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: variants.entries.map((entry) {
        String title = entry.key;
        List<String> options = List<String>.from(entry.value);
        if (options.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.subtitle),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: options.map((option) {
                  final isSelected = selectedVariants[title] == option;
                  final colorScheme = Theme.of(context).colorScheme;
                  return GestureDetector(
                    onTap: () => onVariantSelected(title, option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                        border: Border.all(color: isSelected ? colorScheme.primary : Colors.grey.shade300, width: isSelected ? 1.5 : 1.0),
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
      }).toList(),
    );
  }
}

class ProductDescription extends StatelessWidget {
  final String description;
  const ProductDescription({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description", style: AppText.heading2),
        const SizedBox(height: 12),
        Text(description, style: AppText.body.copyWith(color: Colors.grey.shade700, height: 1.5)),
      ],
    );
  }
}

class ProductSpecifications extends StatelessWidget {
  final Map<String, dynamic> specifications;
  const ProductSpecifications({super.key, required this.specifications});

  @override
  Widget build(BuildContext context) {
    if (specifications.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Specifications", style: AppText.heading2),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: specifications.entries.map((entry) {
              final colorScheme = Theme.of(context).colorScheme;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.15))),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(entry.key, style: AppText.body.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(entry.value.toString(), style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}