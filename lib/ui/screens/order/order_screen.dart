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

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _initialTabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is int) {
      _initialTabIndex = args;
    }
    _tabController = TabController(length: 4, vsync: this, initialIndex: _initialTabIndex);
  }

  String _formatRupiah(num number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  // --- LOGIKA BATALKAN PESANAN ---
  Future<void> _cancelOrder(String orderId) async {
    // 1. Tampilkan Dialog Konfirmasi
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Pesanan?"),
        content: const Text("Pesanan ini akan dibatalkan dan dihapus dari daftar."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Tidak", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    // 2. Jika user klik "Ya, Batalkan"
    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
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
            SnackBar(content: Text("Gagal membatalkan pesanan: $e")),
          );
        }
      }
    }
  }

  // --- LOGIKA PESANAN DITERIMA ---
  Future<void> _confirmReceipt(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan selesai! Terima kasih sudah berbelanja.")));
    } catch (e) {
      print("Error completing order: $e");
    }
  }

  // --- LOGIKA PAY NOW (RE-OPEN XENDIT) ---
  Future<void> _payNow(String orderId, int amount, String name) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.9:3000/create-invoice'), // Pastikan IP ini sesuai dengan IP terbarumu
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId, 'amount': amount, 'customerName': name}),
      );
      final data = jsonDecode(response.body);
      if (data['success']) {
        launchUrl(Uri.parse(data['checkoutUrl']), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print("Error paying again: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("My Orders", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, 
          tabAlignment: TabAlignment.start, 
          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          tabs: const [
            Tab(text: "Unpaid"),
            Tab(text: "Processing"),
            Tab(text: "Shipped"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList("unpaid"),
          _buildOrderList("processing"),
          _buildOrderList("shipped"),
          _buildOrderList("completed"),
        ],
      ),
    );
  }

  Widget _buildOrderList(String targetStatus) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Please Login"));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: targetStatus)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No orders in ${targetStatus.toUpperCase()}"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var order = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    String status = order['status'];
    var firstItem = order['items'][0];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order['orderId'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              _buildStatusBadge(status),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Image.network(firstItem['image'], width: 60, height: 60, fit: BoxFit.cover),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(firstItem['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("${firstItem['qty']} item | ${firstItem['variant']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text(_formatRupiah(order['payment']['totalAmount']), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          
          // --- TOMBOL AKSI BERDASARKAN STATUS ---
          if (status == 'unpaid')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TOMBOL CANCEL DITAMBAHKAN DI SINI
                OutlinedButton(
                  onPressed: () => _cancelOrder(order['orderId']),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _payNow(order['orderId'], order['payment']['totalAmount'], order['shipping']['receiverName']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                  child: const Text("PAY NOW", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            
          if (status == 'shipped')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _confirmReceipt(order['orderId']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                  child: const Text("ORDER RECEIVED", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'unpaid') color = Colors.red;
    if (status == 'processing') color = Colors.blue;
    if (status == 'shipped') color = Colors.orange;
    if (status == 'completed') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}