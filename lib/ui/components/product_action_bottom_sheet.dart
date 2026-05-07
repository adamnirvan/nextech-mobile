import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import 'package:nextech_mobile/ui/components/product_model.dart';
// Sesuaikan import ProductVariantSelector jika kamu memisahnya di file lain.
// Jika ProductVariantSelector masih di product_detail_screen.dart, kamu harus memindahkannya juga ke file komponen terpisah agar bisa di-import ke sini.

class ProductActionBottomSheet extends StatefulWidget {
  final ProductModel product;
  final Map<String, dynamic> initialVariants;
  final bool isBuyNow;
  
  // Callback untuk mengirim data (jumlah & varian terbaru) kembali ke Detail Screen
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
    // Kita buat "salinan" dari varian yang dipilih di layar utama
    _localVariants = Map.from(widget.initialVariants);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Info Produk
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(widget.product.images.isNotEmpty ? widget.product.images.first : widget.product.imageUrl),
                    fit: BoxFit.cover,
                  )
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.title, style: AppText.subtitle, maxLines: 2),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(widget.product.price),
                      style: AppText.heading2.copyWith(color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
            ],
          ),
          const Divider(height: 32),

          // 2. Varian Selector
          // (Pastikan widget ini sudah bisa diakses/di-import di file ini)
          /* ProductVariantSelector(
            variants: widget.product.variants,
            selectedVariants: _localVariants,
            onVariantSelected: (title, option) {
              setState(() => _localVariants[title] = option);
            },
          ),
          const Divider(height: 32),
          */

          // 3. Counter Jumlah
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Jumlah", style: AppText.subtitle),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                    ),
                    Text(_quantity.toString(), style: AppText.body.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // 4. Tombol Aksi
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                // Eksekusi Callback! Kirim data ke Detail Screen
                widget.onConfirm(_quantity, _localVariants);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
              ),
              child: Text(widget.isBuyNow ? "Beli Sekarang" : "Masukkan Keranjang", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}