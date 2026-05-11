import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatelessWidget {
  final int initialIndex;
  const AdminOrdersScreen({super.key, this.initialIndex = 0});

  String _formatCurrency(num price) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);

  Future<void> _shipOrder(BuildContext context, String orderId) async {
    final colorScheme = Theme.of(context).colorScheme;
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'shipped',
        'shippedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Order successfully processed for shipping!", 
          style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onPrimary, fontWeight: FontWeight.bold)
        ),
        backgroundColor: colorScheme.primary, 
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed: $e", 
          style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onError)
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerHighest,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          title: Text(
            "Order Management",
            style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          bottom: TabBar(
            labelColor: colorScheme.onSurface,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.4),
            indicatorColor: colorScheme.onSurface,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600, fontSize: 13),
            dividerColor: colorScheme.onSurface.withOpacity(0.08),
            tabs: const [
              Tab(text: "Processing"),
              Tab(text: "Shipped"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderStream("processing"),
            _buildOrderStream("shipped"),
            _buildOrderStream("completed"),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStream(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        final colorScheme = Theme.of(context).colorScheme;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: colorScheme.onSurface.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text(
                  "No $status orders found",
                  style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 40), 
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;
            return _buildOrderCard(context, doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, String docId, Map<String, dynamic> data) {
    final colorScheme = Theme.of(context).colorScheme;
    String status = data['status'];
    var items = data['items'] as List;
    
    var firstItem = items.isNotEmpty ? items[0] : null;
    String itemImage = firstItem != null ? (firstItem['image'] ?? firstItem['imageUrl'] ?? '') : '';
    String itemName = firstItem != null ? (firstItem['name'] ?? firstItem['title'] ?? 'Product') : 'Product';
    int additionalItems = items.length - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colorScheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "#${data['orderId']}",
                style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface),
              ),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    data['shipping']['receiverName'] ?? 'Customer',
                    style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600, fontSize: 13, color: colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.08)),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: itemImage.isNotEmpty
                    ? Image.network(itemImage, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: 50, height: 50, color: colorScheme.surfaceContainerHighest, child: Icon(Icons.broken_image, size: 20, color: colorScheme.onSurface.withOpacity(0.3))))
                    : Container(width: 50, height: 50, color: colorScheme.surfaceContainerHighest, child: Icon(Icons.image, size: 20, color: colorScheme.onSurface.withOpacity(0.3))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (additionalItems > 0)
                      Text(
                        "+$additionalItems more items",
                        style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Amount", style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 11, color: colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(data['payment']['totalAmount'] ?? 0),
                    style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w800, fontSize: 15, color: colorScheme.primary),
                  ),
                ],
              ),

              if (status == 'processing')
                SizedBox(
                  height: 38,
                  child: FilledButton(
                    onPressed: () => _shipOrder(context, docId),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)), 
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text("SHIP ORDER", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
                  ),
                ),

              if (status == 'shipped')
                _buildStatusBadge("Shipped", Icons.local_shipping_outlined, colorScheme),

              if (status == 'completed')
                _buildStatusBadge("Completed", Icons.check_circle_outline_rounded, colorScheme, isSuccess: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, IconData icon, ColorScheme colorScheme, {bool isSuccess = false}) {
    final baseColor = isSuccess ? Colors.green.shade600 : colorScheme.onSurface;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: baseColor.withOpacity(0.8), size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontFamily: 'PlusJakartaSans', color: baseColor.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}