import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextech_mobile/ui/components/product_model.dart';
import '../../../routes/app_routes.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  String _formatPrice(int price) {
    final formatCurrency = NumberFormat.decimalPattern('id');
    return formatCurrency.format(price);
  }

  String _formatSold(String sold) {
    int parsedSold = int.tryParse(sold.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return NumberFormat.compact().format(parsedSold);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth / 2) - 20;
    if (cardWidth > 220) cardWidth = 220;

    final bool isPromo = product.isPromo;
    final bool hasDiscount = isPromo && product.discountPercentage > 0;

    String originalPrice = "Rp ${_formatPrice(product.originalPrice ?? 0)}";
    String promoPrice = "Rp ${_formatPrice(product.price)}";

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: product.id,
      ),
      child: Container(
        width: cardWidth,
        height: 210,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── IMAGE SECTION ──
            Stack(
              children: [
                // Product image
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 36,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),

                // ── DISCOUNT BADGE ──
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        // Gradient merah → oranye supaya lebih pop
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFFFF6F00)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer_rounded,
                            size: 9,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${product.discountPercentage}% OFF",
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

            // ── INFO SECTION ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product title — 2 baris max
                    Text(
                      product.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),

                    // ── HARGA ──
                    if (isPromo) ...[
                      // Harga promo (merah, bold)
                      Text(
                        promoPrice,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: colorScheme.error,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      // Harga asli (coret, abu)
                      Text(
                        originalPrice,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          decoration: TextDecoration.lineThrough,
                          decorationColor: colorScheme.onSurface.withValues(alpha: 0.4),
                          height: 1.1,
                        ),
                      ),
                    ] else ...[
                      Text(
                        originalPrice,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: colorScheme.onSurface,
                          height: 1.1,
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),

                    // ── RATING & SOLD ──
                    Row(
                      children: [
                        // Bintang
                        const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Color(0xFFFFD600),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                        // Divider titik
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            "·",
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        // Sold count
                        Expanded(
                          child: Text(
                            "${_formatSold(product.soldCount.toString())} sold",
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
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