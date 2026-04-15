import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _initialTabIndex = 0;

  // --- 1. DUMMY DATA API (Tabel Order_Items / Snapshot) ---
  // Perhatikan bahwa setiap status punya data ekstra yang berbeda
  final List<Map<String, dynamic>> dummyOrders = [
    {
      "order_id": "NX-9982310",
      "status": "UNPAID",
      "title": "Nextech Pro Max Ultra Titanium",
      "specs": "Graphite Black | 256GB",
      "qty": 1,
      "price": 18999000,
      "image_url":
          "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=500",
    },
    {
      "order_id": "NX-9982442",
      "status": "SHIPPED",
      "title": "Nextech Vision 34\" Ultrawide",
      "specs": "OLED | 175Hz",
      "qty": 1,
      "price": 8999000,
      "image_url":
          "https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=500",
      "estimated_arrival": "Estimasi tiba: 15 Apr 2026", // Khusus Shipped
    },
    {
      "order_id": "NX-9981111",
      "status": "COMPLETED",
      "title": "Nextech Audio Master Over-Ear",
      "specs": "Silver | Wireless",
      "qty": 2,
      "price": 3250000,
      "image_url":
          "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500",
      "completed_at": "Diterima pada: 12 Apr 2026, 14:30", // Khusus Completed
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is int) {
      _initialTabIndex = args;
    }

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Format Rupiah Helper
  String _formatRupiah(num number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          indicatorWeight: 2.0,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: "Unpaid"),
            Tab(text: "Shipped"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList("UNPAID"),
          _buildOrderList("SHIPPED"),
          _buildOrderList("COMPLETED"),
        ],
      ),
    );
  }

  // --- 2. LOGIKA FILTER DATA BERDASARKAN TAB ---
  Widget _buildOrderList(String targetStatus) {
    // Saring data dummy yang statusnya cocok dengan tab saat ini
    final filteredOrders = dummyOrders
        .where((order) => order['status'] == targetStatus)
        .toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          "Belum ada pesanan dengan status $targetStatus.",
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Render semua card yang lolos filter
          ...filteredOrders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildOrderCard(order),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- 3. KARTU PESANAN DINAMIS ---
  Widget _buildOrderCard(Map<String, dynamic> orderData) {
    final String status = orderData['status'];

    // Variabel dinamis untuk warna dan label
    Color badgeColor;
    Color badgeTextColor;
    String statusLabel;

    if (status == "UNPAID") {
      badgeColor = Colors.red.shade50;
      badgeTextColor = Colors.red.shade700;
      statusLabel = "WAITING FOR PAYMENT";
    } else if (status == "SHIPPED") {
      badgeColor = Colors.orange.shade50;
      badgeTextColor = Colors.orange.shade800;
      statusLabel = "SHIPPED";
    } else {
      badgeColor = Colors.green.shade50;
      badgeTextColor = Colors.green.shade700;
      statusLabel = "COMPLETED";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER (Order ID & Status Badge)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag, size: 18, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  orderData['order_id'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BODY (Gambar, Detail, Harga)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    orderData['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderData['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderData['specs'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${orderData['qty']} item",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatRupiah(orderData['price']),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // INFO TAMBAHAN (ETA atau Tanggal Selesai)
          // INFO TAMBAHAN (ETA atau Tanggal Selesai)
          if (status == "SHIPPED" && orderData['estimated_arrival'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12),
              child: Text(
                orderData['estimated_arrival'],
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (status == "COMPLETED" && orderData['completed_at'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12),
              child: Text(
                orderData['completed_at'],
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // --- REVISI: FOOTER (HANYA MUNCUL UNTUK UNPAID) ---
          if (status == "UNPAID") ...[
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "CANCEL ORDER",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "PAY NOW",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Beri sedikit jarak bawah untuk card yang Shipped & Completed agar tidak terlalu mepet
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
