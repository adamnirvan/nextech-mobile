import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart'; // Sesuaikan lokasi file routemu
import 'package:nextech_mobile/ui/components/global_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- STATE VARIABLES ---
  bool _isLoading = true;

  // Ini adalah wadah penampung data (Model JSON) dari API nantinya
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Panggil fungsi API saat halaman pertama dibuka
  }

  // --- SIMULASI FUNGSI API ---
  Future<void> _fetchUserData() async {
    // Simulasi jeda waktu internet selama 1 detik
    await Future.delayed(const Duration(seconds: 1));
    // Simulasi response JSON dari Backend
    setState(() {
      _userData = {
        "name": "Adam Nirvana",
        "email": "adam.nirvana@gmail.com",
        "avatarUrl": null, // Nanti bisa diisi URL foto profil
        "orders": {
          "unpaid": 0,
          "shipped": 1, // Angka badge dinamis
          "completed": 5,
        },
      };
      _isLoading = false; // Matikan loading setelah data didapat
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan indikator loading jika data sedang diambil
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E1E),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // Background abu-abu sangat muda

      appBar: const GlobalAppBar(
        title: "Profile",
        backgroundColor: Color(0xFF1E1E1E),
        contentColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER PROFIL
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 40,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(color: Color(0xFF1E1E1E)),
              child: Row(
                children: [
                  // Foto Profil
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(8),
                      // Jika ada gambar asli dari API, pakai DecorationImage
                      // image: _userData['avatarUrl'] != null ? DecorationImage(image: NetworkImage(_userData['avatarUrl'])) : null,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Teks Nama & Email (DINAMIS DARI DATA)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData['name'] ?? "Guest User",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData['email'] ?? "No email provided",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // ==========================================
                    // 2. CARD UTAMA (MY ORDERS + ADDRESSES)
                    // ==========================================
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 16.0,
                              top: 20.0,
                              right: 16.0,
                            ),
                            child: Text(
                              "MY ORDERS",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          // MENGIRIMKAN DATA API KE FUNGSI ORDERS
                          _buildResponsiveOrders(context, _userData['orders']),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFF0F0F0),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 8.0,
                            ),
                            child: _buildMenuListTile(
                              icon: Icons.location_on,
                              title: "Addresses",
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.addressList);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==========================================
                    // 3. TOMBOL LOGOUT
                    // ==========================================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.auth,
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.red.shade200,
                            width: 1.5,
                          ),
                          backgroundColor: Colors.red.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "NEXTECH MARKETPLACE",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w100,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET HELPER
  // ==========================================

  // Perhatikan parameter ordersData ditambahkan di sini
  Widget _buildResponsiveOrders(
    BuildContext context,
    Map<String, dynamic> ordersData,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 20.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildOrderAction(
              Icons.account_balance_wallet,
              "UNPAID",
              badgeCount: ordersData['unpaid'] ?? 0, // Ambil dari API
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.order, arguments: 0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildOrderAction(
              Icons.local_shipping,
              "SHIPPED",
              badgeCount: ordersData['shipped'] ?? 0, // Ambil dari API
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.order, arguments: 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildOrderAction(
              Icons.inventory_2,
              "COMPLETED",
              badgeCount: ordersData['completed'] ?? 0, // Ambil dari API
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.order, arguments: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderAction(
    IconData icon,
    String label, {
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(icon, size: 30, color: Colors.black87),
                  ),
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.white, spreadRadius: 2),
                      ],
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
