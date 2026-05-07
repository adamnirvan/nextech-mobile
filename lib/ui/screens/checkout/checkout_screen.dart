import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import 'package:intl/intl.dart';
import 'package:nextech_mobile/ui/screens/checkout/payment_success_screen.dart';
import '../../../routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_service.dart'; // Pastikan path ini benar

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = true;
  bool _isLoadingShipping = false; // Loading khusus untuk ongkir
  Map<String, dynamic> _selectedAddress = {};
  
  List<Map<String, dynamic>> _checkoutItems = [];
  double _shippingFee = 0; // Ongkir sekarang dinamis!

  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _setupDeepLinkListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tarik data arguments hanya sekali saat layar dimuat
    if (_checkoutItems.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      
      // LOGIKA BARU: Tanpa Dummy!
      // Jika ada data dari keranjang, masukkan. Jika tidak ada, biarkan list kosong [].
      if (args != null && args is List<Map<String, dynamic>>) {
        _checkoutItems = args;
      } else {
        _checkoutItems = [];
      }
            
      // Setelah item siap (meskipun kosong), baru kita cari alamat user
      _fetchDefaultAddress();
    }
  }

  void _setupDeepLinkListener() {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'nextech' && uri.host == 'payment-success') {
        final String? orderId = uri.queryParameters['orderId'];
        final String? amount = uri.queryParameters['amount'];
        Navigator.pushReplacementNamed(context, AppRoutes.paymentSuccess, arguments: {'orderId': orderId, 'amount': amount});
      }
    });
  }

  // MENGAMBIL ALAMAT DEFAULT DARI FIRESTORE
  Future<void> _fetchDefaultAddress() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      var querySnapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .where('userId', isEqualTo: currentUser.uid)
          .where('is_default', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance.collection('addresses').where('userId', isEqualTo: currentUser.uid).limit(1).get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        data['id'] = doc.id; 

        setState(() {
          _selectedAddress = data;
          _isLoading = false;
        });
        
        // SETELAH ALAMAT KETEMU, LANGSUNG HITUNG ONGKIRNYA!
        _calculateShipping();
        
      } else {
        setState(() {
          _selectedAddress = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetch default address: $e");
      setState(() => _isLoading = false);
    }
  }

  // FUNGSI AJAIB: MENGHITUNG ONGKIR KE NODE.JS
  Future<void> _calculateShipping() async {
    if (_selectedAddress.isEmpty || _selectedAddress['areaId'] == null) {
      setState(() => _shippingFee = 0);
      return;
    }

    setState(() => _isLoadingShipping = true); // Nyalakan loading ongkir

    try {
      // Tembak API Service kita
      final fee = await ApiService().checkRates(_selectedAddress['areaId'], _checkoutItems);
      
      if (mounted) {
        setState(() {
          _shippingFee = fee;
          _isLoadingShipping = false; // Matikan loading ongkir
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _shippingFee = 0;
          _isLoadingShipping = false;
        });
      }
    }
  }

  // XENDIT LOGIC
  Future<void> payWithXendit(double totalAmount, double subtotal) async {
    final String orderId = 'NEXTECH-${DateTime.now().millisecondsSinceEpoch}';
    final int totalAmountInt = totalAmount.toInt();
    final String customerName = _selectedAddress['receiver'] ?? 'Pembeli Nextech';
    // INGAT: Pastikan IP di bawah ini sesuai dengan IP terbaru laptopmu!
    final Uri url = Uri.parse('http://192.168.1.7:3000/create-invoice'); 

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'userId': currentUser.uid,
        'status': 'unpaid',
        'createdAt': FieldValue.serverTimestamp(),
        'items': _checkoutItems.map((item) => {
          'productId': item['id'],
          'name': item['name'],
          'variant': item['variant'] ?? '',
          'price': item['price'],
          'qty': item['qty'],
          'image': item['image'],
          'weight': item['weight'], // Simpan juga weight-nya
        }).toList(),
        'shipping': {
          'receiverName': customerName,
          'phone': _selectedAddress['phone'],
          'fullAddress': "${_selectedAddress['full_address']}, ${_selectedAddress['areaName'] ?? ''}", 
          'areaId': _selectedAddress['areaId'] ?? '', 
          'courier': 'Nextech Standard Delivery', 
          'trackingNumber': '',
        },
        'payment': {
          'subtotal': subtotal,
          'shippingFee': _shippingFee,
          'totalAmount': totalAmountInt,
          'paymentMethod': '',
          'paymentChannel': '',
        },
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId, 'amount': totalAmountInt, 'customerName': customerName}),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        final Uri xenditUri = Uri.parse(responseData['checkoutUrl']);
        await launchUrl(xenditUri, mode: LaunchMode.externalApplication, webViewConfiguration: const WebViewConfiguration(enableJavaScript: true));
      }
    } catch (e) {
      print("🚨 Terjadi Kesalahan: $e");
    }
  }

  String _formatRupiah(double number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  @override
  Widget build(BuildContext context) {
    // Hitung Subtotal secara dinamis dari items
    double subtotal = _checkoutItems.fold(
      0, (sum, item) => sum + ((item['price'] as num).toDouble() * (item['qty'] as num).toInt()),
    );
    double totalPayment = subtotal + _shippingFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: Text("Checkout", style: AppText.heading1.copyWith(fontSize: 18)), centerTitle: true, backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- 1. ALAMAT PENGIRIMAN ---
                  InkWell(
                    onTap: () async {
                      final selectedAddress = await Navigator.pushNamed(context, AppRoutes.addressList, arguments: {'isSelectionMode': true, 'currentSelectedId': _selectedAddress['id']});
                      if (selectedAddress != null) {
                        setState(() {
                          _selectedAddress = selectedAddress as Map<String, dynamic>;
                        });
                        // KALAU USER GANTI ALAMAT, HITUNG ULANG ONGKIRNYA!
                        _calculateShipping();
                      }
                    },
                    child: _buildSection(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Shipping Address", style: AppText.subtitle.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                _selectedAddress.isEmpty
                                  ? Text("Pilih Alamat Pengiriman", style: AppText.body.copyWith(color: Colors.red, fontStyle: FontStyle.italic))
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${_selectedAddress['receiver']} | ${_selectedAddress['phone']}", style: AppText.body),
                                        const SizedBox(height: 4),
                                        Text("${_selectedAddress['full_address']}, ${_selectedAddress['areaName'] ?? ''}", style: AppText.caption.copyWith(color: Colors.grey.shade600)),
                                      ],
                                    ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  // --- 2. DAFTAR PESANAN ---
                  _buildSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order Summary", style: AppText.subtitle.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ..._checkoutItems.map((item) => _buildProductItem(item)).toList(),
                      ],
                    ),
                  ),

                  // --- 3. RINGKASAN PEMBAYARAN ---
                  _buildSection(
                    child: Column(
                      children: [
                        _buildPaymentRow("Subtotal", _formatRupiah(subtotal)),
                        const SizedBox(height: 8),
                        // ONGKIR MEMILIKI STATE LOADINGNYA SENDIRI
                        _buildPaymentRow("Shipping Fee", _formatRupiah(_shippingFee), isLoading: _isLoadingShipping),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                        _buildPaymentRow("Total Payment", _formatRupiah(totalPayment), isTotal: true, isLoading: _isLoadingShipping),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomSheet: _buildBottomAction(context, totalPayment, subtotal),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: (item['image'] != null && item['image'] is String && item['image'].toString().isNotEmpty)
                ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item['image'], fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey)))
                : const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: AppText.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("${item['qty']}x | ${item['variant']}", style: AppText.caption.copyWith(color: Colors.grey)),
                Text(_formatRupiah((item['price'] as num).toDouble()), style: AppText.body.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required Widget child}) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 8), color: Colors.white, child: child);
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false, bool isLoading = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isTotal ? AppText.subtitle.copyWith(fontWeight: FontWeight.bold) : AppText.body),
        
        // JIKA SEDANG LOADING, TAMPILKAN SPINNER. JIKA TIDAK, TAMPILKAN HARGA
        isLoading 
          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
          : Text(value, style: isTotal ? AppText.heading2.copyWith(color: Colors.red.shade700) : AppText.body),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, double total, double subtotal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Payment", style: AppText.caption),
                
                // JIKA LOADING, SPINNER JUGA MUNCUL DI TOTAL BAWAH
                _isLoadingShipping 
                 ? const Padding(padding: EdgeInsets.only(top: 4), child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red)))
                 : Text(_formatRupiah(total), style: AppText.subtitle.copyWith(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
              ],
            ),
          ),
          ElevatedButton(
            // Matikan tombol kalau ongkir lagi diproses (mencegah user bayar sebelum total harga fix)
            onPressed: _isLoadingShipping || _selectedAddress.isEmpty ? null : () => payWithXendit(total, subtotal),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Place Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}