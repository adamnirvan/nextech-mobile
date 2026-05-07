import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextech_mobile/ui/components/product_model.dart';
import '../../../routes/app_routes.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  // Fungsi helper otomatis pindah ke sini
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
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth / 2) - 20;
    if (cardWidth > 220) cardWidth = 220;

    String originalPrice = "Rp ${_formatPrice(product.originalPrice ?? 0)}";
    String? promoPrice = product.isPromo ? "Rp ${_formatPrice(product.price)}" : null;
    String? discountTag = (product.isPromo && product.discountPercentage > 0) 
        ? "${product.discountPercentage}% OFF" 
        : null;

    return GestureDetector(
      // MENGIRIMKAN ID PRODUK KE DETAIL SCREEN
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product.id),
      child: Container(
        width: cardWidth,
        height: 300,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2),
            ),
          ],
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
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
                if (product.isPromo && discountTag != null)
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
                      child: Text(product.title, style: theme.textTheme.bodyMedium?.copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 46,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (product.isPromo) ...[
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
                        Text(product.rating.toString(), style: theme.textTheme.displayMedium?.copyWith(fontSize: 12)),
                        Expanded(
                          child: Text("${_formatSold(product.soldCount.toString())} Sold", style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),
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