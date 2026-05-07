import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_routes.dart'; 

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  // Variabel untuk menyimpan ID alamat yang dipilih sementara (visual radio button)
  String? _selectedAddressId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // =========================================================================
    // LOGIKA 1: PENANGKAPAN MODE (SURAT TUGAS)
    // =========================================================================
    // Kita cek apakah ada 'pesan' yang dikirim saat Navigator memanggil layar ini.
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Jika dipanggil dari Checkout, biasanya akan mengirim 'currentSelectedId'
    if (args != null && args['currentSelectedId'] != null && _selectedAddressId == null) {
      _selectedAddressId = args['currentSelectedId'];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menentukan apakah saat ini sedang dalam mode 'Pilih Alamat' (dari Checkout)
    // atau mode 'Manajemen Alamat' (dari Profil).
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool isSelectionMode = args?['isSelectionMode'] ?? false;

    // Identitas user yang sedang login untuk memfilter data di Firestore
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // =========================================================================
        // LOGIKA 2: UI KONDISIONAL (JUDUL)
        // =========================================================================
        title: Text(
          isSelectionMode ? "Pilih Alamat Pengiriman" : "Alamat Saya",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      
      // =========================================================================
      // LOGIKA 3: KONEKSI REAL-TIME (STREAMBUILDER)
      // =========================================================================
      body: currentUser == null
          ? const Center(child: Text("Silakan login terlebih dahulu."))
          : StreamBuilder<QuerySnapshot>(
              // Kita 'mendengarkan' koleksi addresses milik user ini secara terus menerus
              stream: FirebaseFirestore.instance
                  .collection('addresses')
                  .where('userId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.red));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(); // Tampilan jika belum ada alamat
                }

                final List<DocumentSnapshot> addressDocs = snapshot.data!.docs;

                // LOGIKA SORTIR: Alamat 'Utama' (is_default) selalu muncul paling atas
                addressDocs.sort((a, b) {
                  bool isADefault = (a.data() as Map<String, dynamic>)['is_default'] ?? false;
                  bool isBDefault = (b.data() as Map<String, dynamic>)['is_default'] ?? false;
                  if (isADefault && !isBDefault) return -1;
                  if (!isADefault && isBDefault) return 1;
                  return 0;
                });

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: addressDocs.length,
                  itemBuilder: (context, index) {
                    final doc = addressDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    // Masukkan ID dokumen Firestore agar bisa dipakai saat klik
                    data['id'] = doc.id; 

                    return _buildAddressCard(data, isSelectionMode);
                  },
                );
              },
            ),

      // TOMBOL TAMBAH ALAMAT (Sama untuk kedua mode)
      bottomSheet: _buildBottomButton(),
    );
  }

  // =========================================================================
  // LOGIKA 4: UI & PERILAKU KARTU (CARD LOGIC)
  // =========================================================================
  Widget _buildAddressCard(Map<String, dynamic> address, bool isSelectionMode) {
    final bool isSelected = _selectedAddressId == address['id'];
    final bool isDefault = address['is_default'] == true;

    return InkWell(
      onTap: () {
        // PERILAKU BERCABANG BERDASARKAN MODE:
        if (isSelectionMode) {
          // MODE CHECKOUT: Update centang, lalu LANGSUNG BALIK ke Checkout bawa data alamat
          setState(() => _selectedAddressId = address['id']);
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) Navigator.pop(context, address); 
          });
        } else {
          // MODE PROFIL: Klik mungkin membuka detail atau form edit
          print("Aksi: Lihat/Edit Alamat ${address['id']}");
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LOGIKA UI: Radio button hanya muncul jika user sedang 'memilih' (Checkout)
            if (isSelectionMode) ...[
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? Colors.red : Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 12),
            ],

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${address['receiver']} | ${address['phone']}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${address['full_address']}, ${address['areaName']}",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),

                  // Badge 'Utama' muncul jika field is_default di Firestore bernilai true
                  if (isDefault) _buildDefaultBadge(),
                ],
              ),
            ),

            // Tombol Ubah (Tersedia di kedua mode)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addressForm, arguments: address);
              },
              child: const Text("Ubah", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- SUB WIDGETS (UNTUK KERAPIAN KODE) ---

  Widget _buildDefaultBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(4)),
      child: const Text("Utama", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Belum ada alamat tersimpan", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addressForm),
          icon: const Icon(Icons.add, color: Colors.red),
          label: const Text("Tambah Alamat Baru", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red.shade400, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}