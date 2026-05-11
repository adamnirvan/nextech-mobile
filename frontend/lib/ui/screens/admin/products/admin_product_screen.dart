import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'admin_product_form.dart'; 

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  String _formatCurrency(num number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  // FUNCTION TO DELETE PRODUCT
  Future<void> _deleteProduct(BuildContext context, String docId) async {
    final colorScheme = Theme.of(context).colorScheme;

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          "Delete Product?", 
          style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface, fontWeight: FontWeight.bold)
        ),
        content: Text(
          "This product will be permanently deleted from the database.", 
          style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.7))
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text("Cancel", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.5)))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text("Delete", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.error, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseFirestore.instance.collection('products').doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Product deleted!", style: TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 4,
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text(
          "Product Management", 
          style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: colorScheme.onSurface.withOpacity(0.08)),
        ),
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colorScheme.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    "No products available", 
                    style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w600, fontSize: 14)
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Biar list tidak tertutup FAB
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var product = doc.data() as Map<String, dynamic>;

              String name = product['title'] ?? product['name'] ?? 'Unnamed Product';
              num price = product['price'] ?? 0;
              int stock = product['stock'] ?? 0; 
              String imageUrl = product['image_url'] ?? '';

              return Material(
                color: colorScheme.surface,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminProductFormScreen(
                          productData: product,
                          productId: doc.id,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.08)),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl, 
                                  width: 65, 
                                  height: 65, 
                                  fit: BoxFit.cover, 
                                  errorBuilder: (c, e, s) => Container(width: 65, height: 65, color: colorScheme.surfaceContainerHighest, child: Icon(Icons.broken_image, color: colorScheme.onSurface.withOpacity(0.3)))
                                )
                              : Container(
                                  width: 65, 
                                  height: 65, 
                                  color: colorScheme.surfaceContainerHighest, 
                                  child: Icon(Icons.image, color: colorScheme.onSurface.withOpacity(0.3))
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name, 
                                style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.onSurface), 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatCurrency(price), 
                                style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w800, color: colorScheme.primary, fontSize: 14)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Stock: $stock", 
                                style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w500)
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: colorScheme.error.withOpacity(0.8)),
                          onPressed: () => _deleteProduct(context, doc.id), 
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        icon: Icon(Icons.add, color: colorScheme.onPrimary),
        label: Text("New Product", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onPrimary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductFormScreen()));
        },
      ),
    );
  }
}