import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _initialTabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tabController == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is int) _initialTabIndex = args;
      _tabController = TabController(
        length: 4,
        vsync: this,
        initialIndex: _initialTabIndex,
      );
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  String _formatRupiah(num number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  Future<void> _cancelOrder(String orderId) async {
    final colorScheme = Theme.of(context).colorScheme;
    final bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Text(
              "Cancel Order?",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "This order will be cancelled and is non-refundable.",
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "No",
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Yes, Cancel",
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({
          'status': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pesanan berhasil dibatalkan")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal membatalkan: $e")),
          );
        }
      }
    }
  }

  Future<void> _confirmReceipt(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order complete! Thank you for shopping."),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error completing order: $e");
    }
  }

Future<void> _payNow(BuildContext context, String orderId, int amount, String name) async {
    // 1. Munculkan Loading Dialog 
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      ),
    );

    try {
      // ⚠️ GANTI URL INI!
      // Jika backend sudah di-deploy ke Render/Railway, masukkan URL-nya di sini.
      // Jika masih lokal, pastikan IP-nya (192.168.1.x) sesuai dengan IPv4 komputermu HARI INI.
      final String backendUrl = 'https://nextech-mobile.vercel.app/create-invoice';

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'amount': amount,
          'customerName': name,
        }),
      ).timeout(const Duration(seconds: 15)); // Batas waktu 15 detik biar tidak nge-hang

      // Tutup loading
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['checkoutUrl'] != null) {
          final Uri url = Uri.parse(data['checkoutUrl']);
          // Lempar ke browser (Xendit)
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            throw Exception('Failed to open browser for payment.');
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to get link from Xendit');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
     
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pembayaran gagal: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
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
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Orders",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
            indicatorColor: colorScheme.onSurface,
            indicatorWeight: 2,
            labelColor: colorScheme.onSurface,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.4),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: "Unpaid"),
              Tab(text: "Processing"),
              Tab(text: "Shipped"),
              Tab(text: "Completed"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList("unpaid", colorScheme),
          _buildOrderList("processing", colorScheme),
          _buildOrderList("shipped", colorScheme),
          _buildOrderList("completed", colorScheme),
        ],
      ),
    );
  }

  // ── ORDER LIST ────────────────────────────────────────────────────────
  Widget _buildOrderList(String targetStatus, ColorScheme colorScheme) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Text(
          "Please login to your account",
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: targetStatus)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.onSurface),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(targetStatus, colorScheme);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final order = snapshot.data!.docs[index].data()
                as Map<String, dynamic>;
            return _buildOrderCard(order, colorScheme);
          },
        );
      },
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────
  Widget _buildEmptyState(String status, ColorScheme colorScheme) {
    final Map<String, Map<String, dynamic>> emptyConfig = {
      'unpaid': {
        'icon': Icons.account_balance_wallet_outlined,
        'text': 'No orders\nwaiting for payment',
      },
      'processing': {
        'icon': Icons.autorenew_rounded,
        'text': 'No orders\nin process',
      },
      'shipped': {
        'icon': Icons.local_shipping_outlined,
        'text': 'No orders\nbeing shipped',
      },
      'completed': {
        'icon': Icons.inventory_2_outlined,
        'text': 'No orders\ncompleted',
      },
    };

    final config = emptyConfig[status] ??
        {'icon': Icons.inbox_outlined, 'text': 'No orders'};

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              config['icon'] as IconData,
              size: 32,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            config['text'] as String,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.4),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── ORDER CARD ────────────────────────────────────────────────────────
  Widget _buildOrderCard(
      Map<String, dynamic> order, ColorScheme colorScheme) {
    final String status = order['status'] ?? '';
    final dynamic itemsRaw = order['items'];
    if (itemsRaw == null || (itemsRaw as List).isEmpty) return const SizedBox();
    final firstItem = itemsRaw[0] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['orderId'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.5),
                    letterSpacing: 0.3,
                  ),
                ),
                _buildStatusBadge(status, colorScheme),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.onSurface.withOpacity(0.07),
          ),

          // ── Item ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    firstItem['image'] ?? '',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: colorScheme.onSurface.withOpacity(0.3),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem['name'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${firstItem['qty']} item · ${firstItem['variant']}",
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.45),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Total & Actions ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRupiah(
                        order['payment']?['totalAmount'] ?? 0,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),

                // Action buttons
                _buildActionButtons(order, status, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ACTION BUTTONS ────────────────────────────────────────────────────
  Widget _buildActionButtons(
    Map<String, dynamic> order,
    String status,
    ColorScheme colorScheme,
  ) {
    if (status == 'unpaid') {
      return Row(
        children: [
          // Cancel — outlined, subtle
          OutlinedButton(
            onPressed: () => _cancelOrder(order['orderId']),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: colorScheme.onSurface.withOpacity(0.25),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _payNow(
              context,
              order['orderId'],
              order['payment']['totalAmount'],
              order['shipping']['receiverName'],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.onSurface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Pay now",
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    }

    if (status == 'shipped') {
      return ElevatedButton(
        onPressed: () => _confirmReceipt(order['orderId']),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.onSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          "Order received",
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ── STATUS BADGE ──────────────────────────────────────────────────────
  Widget _buildStatusBadge(String status, ColorScheme colorScheme) {
    final Map<String, Color> statusColors = {
      'unpaid': const Color(0xFFE53935),       // merah
      'processing': const Color(0xFF1E88E5),   // biru
      'shipped': const Color(0xFFF57C00),      // oranye
      'completed': const Color(0xFF43A047),    // hijau
      'cancelled': const Color(0xFF9E9E9E),    // abu
    };

    final Map<String, String> statusLabel = {
      'unpaid': 'Unpaid',
      'processing': 'Processing',
      'shipped': 'Shipped',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
    };

    final Color color = statusColors[status] ?? colorScheme.onSurface.withOpacity(0.5);
    final String label = statusLabel[status] ?? status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}