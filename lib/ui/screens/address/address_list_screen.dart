import 'package:flutter/material.dart';
import 'package:nextech_mobile/routes/app_routes.dart'; // Sesuaikan import ini
// import '../../../routes/app_routes.dart'; // Aktifkan ini nanti untuk navigasi ke form

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  bool _isLoading = true;

  // State untuk menyimpan data dari API
  List<Map<String, dynamic>> _addresses = [];

  // State untuk melacak ID alamat mana yang sedang di-klik (Khusus Selection Mode)
  String? _selectedAddressId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MENANGKAP ARGUMEN: Apakah mode pilihan atau mode manajemen?
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Jika ada ID yang dilempar dari Checkout, jadikan itu sebagai status awal Radio Button
    if (args != null &&
        args['currentSelectedId'] != null &&
        _selectedAddressId == null) {
      _selectedAddressId = args['currentSelectedId'];
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  // --- SIMULASI API GET DATA ALAMAT ---
  Future<void> _fetchAddresses() async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Simulasi loading network

    // Nanti diganti dengan: final response = await http.get(Uri.parse('api/addresses'));
    setState(() {
      _addresses = [
        {
          "id": "addr_1",
          "receiver": "ADAM NIRVANA",
          "phone": "(+62) 812-3456-7890",
          "full_address":
              "Jl. Teknologi No. 404, Cyber City, Jakarta Selatan, 12345",
          "is_default": true, // Ini alamat utama
        },
        {
          "id": "addr_2",
          "receiver": "Adam Nirvana (Kantor)",
          "phone": "(+62) 819-9988-7766",
          "full_address":
              "Gedung Nextech Tower Lt. 12, Sudirman CBD, Jakarta Pusat, 10110",
          "is_default": false,
        },
      ];

      // Jika _selectedAddressId masih null (misal buka dari Profil),
      // kita otomatis pilih alamat yang is_default == true sebagai fallback.
      if (_selectedAddressId == null) {
        final defaultAddr = _addresses.firstWhere(
          (addr) => addr['is_default'] == true,
          orElse: () => _addresses.first,
        );
        _selectedAddressId = defaultAddr['id'];
      }

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Membaca mode dari arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool isSelectionMode = args?['isSelectionMode'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isSelectionMode
              ? "Pilih Alamat"
              : "Alamat Saya", // Judul AppBar Dinamis
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? const Center(child: Text("Belum ada alamat tersimpan."))
          : ListView.builder(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 100,
              ), // Bottom padding agar tidak tertutup tombol
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return _buildAddressCard(address, isSelectionMode);
              },
            ),

      // TOMBOL TAMBAH ALAMAT DI BAWAH (Mengambang)
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addressForm);
            },
            icon: const Icon(Icons.add, color: Colors.red),
            label: const Text(
              "Tambah Alamat Baru",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.shade400, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER KARTU ALAMAT ---
  Widget _buildAddressCard(Map<String, dynamic> address, bool isSelectionMode) {
    final bool isSelected = _selectedAddressId == address['id'];
    final bool isDefault = address['is_default'] == true;

    return InkWell(
      onTap: () {
        if (isSelectionMode) {
          // Jika mode pilih, update UI radio button lalu kembali ke Checkout sambil membawa data alamat ini!
          setState(() {
            _selectedAddressId = address['id'];
          });

          // Jeda sedikit agar user melihat animasi radio button ter-klik sebelum pindah layar
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted)
              Navigator.pop(
                context,
                address,
              ); // Melempar data kembali ke Checkout
          });
        } else {
          // Jika mode profil, klik kartu mungkin membuka form Edit
          // Navigator.pushNamed(context, AppRoutes.addressForm, arguments: address);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        color: Colors.white, // Latar kartu putih
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RADIO BUTTON (HANYA MUNCUL DI SELECTION MODE)
            if (isSelectionMode) ...[
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? Colors.red : Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 12),
            ],

            // DETAIL ALAMAT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address['receiver'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "|  ${address['phone']}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address['full_address'],
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // BADGE "UTAMA"
                  if (isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Utama",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // TOMBOL UBAH
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.addressForm,
                  arguments: address,
                );
              },
              child: const Text(
                "Ubah",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
