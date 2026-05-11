import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../orders/admin_order_screen.dart';
import '../products/admin_product_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  String _formatCurrency(num amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return "Mon"; case 2: return "Tue"; case 3: return "Wed";
      case 4: return "Thu"; case 5: return "Fri"; case 6: return "Sat"; case 7: return "Sun";
      default: return "";
    }
  }

  Future<void> _logout(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            "Logout Admin?", 
            style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface, fontWeight: FontWeight.bold)
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), 
              child: Text("Cancel", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.55)))
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), 
              child: const Text("Logout", style: TextStyle(fontFamily: 'PlusJakartaSans', color: Color(0xFFE53935), fontWeight: FontWeight.bold))
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/'); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerHighest, 
        elevation: 0, 
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Dashboard", 
          style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 22)
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: colorScheme.onSurface), 
            onPressed: () => _logout(context)
          ),
        ],
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, orderSnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').orderBy('sold_count', descending: true).snapshots(),
            builder: (context, productSnap) {
              
              if (orderSnap.connectionState == ConnectionState.waiting || productSnap.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary));
              }

              // --- KALKULASI DATA ---
              int totalOrders = 0;
              int pendingOrders = 0;
              int totalSales = 0;
              
              List<double> weekSales = List.filled(7, 0.0);
              List<String> weekLabels = List.filled(7, "");
              DateTime now = DateTime.now();

              for (int i = 0; i < 7; i++) {
                weekLabels[i] = _getDayName(now.subtract(Duration(days: 6 - i)).weekday);
              }

              if (orderSnap.hasData) {
                totalOrders = orderSnap.data!.docs.length;
                for (var doc in orderSnap.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  String status = data['status'] ?? '';
                  
                  if (status == 'processing') pendingOrders++;
                  
                  if (status != 'unpaid' && status != 'cancelled') {
                    int amount = (data['payment']?['totalAmount'] as num?)?.toInt() ?? 0;
                    totalSales += amount;

                    if (data['createdAt'] != null) {
                      DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
                      DateTime dateOnlyCreated = DateTime(createdAt.year, createdAt.month, createdAt.day);
                      DateTime dateOnlyNow = DateTime(now.year, now.month, now.day);
                      int diffDays = dateOnlyNow.difference(dateOnlyCreated).inDays;
                      
                      if (diffDays >= 0 && diffDays < 7) {
                        weekSales[6 - diffDays] += amount;
                      }
                    }
                  }
                }
              }

              double maxSale = weekSales.reduce(max);
              if (maxSale == 0) maxSale = 1;

              int totalProducts = productSnap.hasData ? productSnap.data!.docs.length : 0;
              var topProducts = productSnap.hasData ? productSnap.data!.docs : [];

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TOTAL PENDAPATAN ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary, 
                            colorScheme.primary.withOpacity(0.7), 
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20), 
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Revenue", 
                            style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onPrimary.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatCurrency(totalSales), 
                            style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onPrimary, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 3 KARTU SEJAJAR ---
                    Row(
                      children: [
                        _buildClickableCard(context, "Orders", totalOrders.toString(), Icons.shopping_bag_outlined, null),
                        const SizedBox(width: 12),
                        _buildClickableCard(context, "Processing", pendingOrders.toString(), Icons.local_shipping_outlined, 
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen(initialIndex: 0)))
                        ),
                        const SizedBox(width: 12),
                        _buildClickableCard(context, "Products", totalProducts.toString(), Icons.inventory_2_outlined, 
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductsScreen()))
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- CHART PENJUALAN ---
                    Text(
                      "Last 7 Days Sales", 
                      style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 180,
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface, 
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (index) {
                          double heightPercentage = weekSales[index] / maxSale;
                          return _buildRealBarChart(context, heightPercentage, weekLabels[index], weekSales[index]);
                        }),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- PRODUK TERLARIS ---
                    Text(
                      "Top Selling Products", 
                      style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)
                    ),
                    const SizedBox(height: 16),
                    if (topProducts.isEmpty) 
                      Text("No sales data yet.", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.4))),
                    
                    ...topProducts.take(5).map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10), 
                              child: Image.network(
                                data['image_url'] ?? '', 
                                width: 55, height: 55, fit: BoxFit.cover, 
                                errorBuilder: (c,e,s) => Container(width: 55, height: 55, color: colorScheme.surfaceContainerHighest)
                              )
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'] ?? '', 
                                    style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface), 
                                    maxLines: 1, overflow: TextOverflow.ellipsis
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Stock Left: ${data['stock'] ?? 0}", 
                                    style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5))
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${data['sold_count'] ?? 0} Sold", 
                                style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11)
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }
          );
        },
      ),
    );
  }

  // WIDGET BARCHART DINAMIS
  Widget _buildRealBarChart(BuildContext context, double heightPercentage, String label, double amount) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: _formatCurrency(amount),
          triggerMode: TooltipTriggerMode.tap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 24,
            height: 110 * (heightPercentage.isNaN ? 0 : heightPercentage), 
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary, 
                  colorScheme.primary.withOpacity(0.4)
                ], 
                begin: Alignment.topCenter, 
                end: Alignment.bottomCenter
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label, 
          style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 11, color: colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold)
        ),
      ],
    );
  }

  // WIDGET 3 KARTU SEJAJAR BISA DIKLIK
  Widget _buildClickableCard(BuildContext context, String title, String value, IconData icon, VoidCallback? onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface, 
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(icon, color: colorScheme.primary, size: 26),
              const SizedBox(height: 12),
              Text(
                value, 
                style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
              ),
              const SizedBox(height: 2),
              Text(
                title, 
                style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12), 
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis
              ),
            ],
          ),
        ),
      ),
    );
  }
}