import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Mendapatkan UID dari user yang sedang login
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Helper untuk mengubah Map variants menjadi String (Contoh: "Space Black, 512GB")
  String _formatVariants(Map<String, dynamic>? variants) {
    if (variants == null || variants.isEmpty) return "Standard";
    return variants.values.join(", ");
  }

  // Helper Format Rupiah
  String _formatRupiah(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  // --- FUNGSI UPDATE FIRESTORE ---
  Future<void> _updateQty(String docId, int currentQty, int change) async {
    if (currentUser == null) return;

    final int newQty = currentQty + change;
    if (newQty < 1) return; // Jangan biarkan minus atau nol

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('cart')
          .doc(docId)
          .update({'quantity': newQty});
    } catch (e) {
      debugPrint("Error update qty: $e");
    }
  }

  // --- FUNGSI HAPUS ITEM FIRESTORE ---
  Future<void> _removeItem(String docId) async {
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('cart')
          .doc(docId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item dihapus dari keranjang")),
        );
      }
    } catch (e) {
      debugPrint("Error remove item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // JIKA USER BELUM LOGIN
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            "My Cart",
            style: AppText.heading1.copyWith(fontSize: 22),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: Text("Silakan login untuk melihat keranjang."),
        ),
      );
    }

    // STREAM UNTUK MENGAMBIL DATA KERANJANG SECARA REAL-TIME
    final Stream<QuerySnapshot> cartStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: AppText.heading1.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: cartStream,
          builder: (context, snapshot) {
            // Tampilan Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error Handling
            if (snapshot.hasError) {
              return Center(
                child: Text("Terjadi kesalahan: ${snapshot.error}"),
              );
            }

            // Ambil data dokumennya
            final List<QueryDocumentSnapshot> cartDocs =
                snapshot.data?.docs ?? [];

            // ==========================================
            // LOGIKA PERHITUNGAN TOTAL HARGA
            // ==========================================
            double totalPrice = 0;
            for (var doc in cartDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final price = (data['price'] as num?)?.toDouble() ?? 0;
              final qty = (data['quantity'] as num?)?.toInt() ?? 1;
              totalPrice += (price * qty);
            }

            return Column(
              children: [
                // ==========================================
                // 1. AREA LIST PRODUK
                // ==========================================
                Expanded(
                  child: cartDocs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Keranjangmu masih kosong",
                                style: AppText.subtitle.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: cartDocs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            // Data dari Firestore
                            final docId = cartDocs[index].id;
                            final item =
                                cartDocs[index].data() as Map<String, dynamic>;

                            final String title = item['title'] ?? 'Produk';
                            final double price =
                                (item['price'] as num?)?.toDouble() ?? 0;
                            final int qty =
                                (item['quantity'] as num?)?.toInt() ?? 1;
                            final String imageUrl = item['imageUrl'] ?? '';
                            final Map<String, dynamic>? variants =
                                item['selectedVariants']
                                    as Map<String, dynamic>?;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail dari Network Image
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            Icons.image,
                                            color: Colors.grey.shade400,
                                            size: 40,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Detail
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: AppText.subtitle,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => _removeItem(
                                              docId,
                                            ), // Hapus dari Firestore
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatVariants(
                                          variants,
                                        ), // Tampilkan varian
                                        style: AppText.caption.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatRupiah(price),
                                            style: AppText.body.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          // KOTAK COUNTER
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GestureDetector(
                                                  onTap: () => _updateQty(
                                                    docId,
                                                    qty,
                                                    -1,
                                                  ), // Kurangi 1 ke Firestore
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    color: Colors.transparent,
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 16,
                                                      color: qty <= 1
                                                          ? Colors.grey
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 36,
                                                  height: 32,
                                                  color: Colors.grey.shade100,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    qty.toString(),
                                                    style: AppText.body,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () => _updateQty(
                                                    docId,
                                                    qty,
                                                    1,
                                                  ), // Tambah 1 ke Firestore
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    color: Colors.transparent,
                                                    child: const Icon(
                                                      Icons.add,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),

                // ==========================================
                // 2. AREA CHECKOUT BAR
                // ==========================================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Price",
                            style: AppText.caption.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatRupiah(totalPrice), // Total harga real-time!
                            style: AppText.heading2.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),

                      GestureDetector(
                        onTap: cartDocs.isEmpty
                            ? null
                            : () {
                                List<Map<String, dynamic>>
                                checkoutItems = cartDocs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  return {
                                    "id": data['productId'] ?? doc.id,
                                    "name": data['title'] ?? 'Produk',
                                    "variant": _formatVariants(
                                      data['selectedVariants']
                                          as Map<String, dynamic>?,
                                    ),
                                    "price":
                                        (data['price'] as num?)?.toDouble() ??
                                        0.0,
                                    "qty":
                                        (data['quantity'] as num?)?.toInt() ??
                                        1,
                                    "image": data['imageUrl'] ?? '',
                                    "cartDocId": doc.id,
                                    "isFromCart": true,
                                  };
                                }).toList();

                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.checkout,
                                  arguments: checkoutItems
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: cartDocs.isEmpty
                                ? Colors.grey.shade400
                                : colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Checkout",
                            style: AppText.subtitle.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
