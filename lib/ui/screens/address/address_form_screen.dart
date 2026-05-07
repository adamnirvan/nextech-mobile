import 'package:nextech_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  bool _isDefault = false;
  bool _isSaving = false;

  // Controller untuk teks manual
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  String _selectedLabel = 'Rumah';

  // --- VARIABEL BITESHIP ---
  String? _selectedAreaId;
  String? _selectedAreaName;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  // --- FUNGSI FORMAT NAMA AREA BITESHIP ---
  // Biteship mengembalikan data berjenjang yang detail.
  // Kita format jadi: "Kecamatan, Kota, Provinsi, Kode Pos"
  String _formatAreaName(dynamic area) {
    final district = area['name'] ?? '';
    final city = area['administrative_division_level_2_name'] ?? '';
    final province = area['administrative_division_level_1_name'] ?? '';
    final postalCode = area['postal_code'] ?? '';
    
    return "$district, $city, $province, $postalCode";
  }

  // --- REAL SAVE KE FIRESTORE ---
  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAreaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Silakan cari dan pilih area pengiriman dari daftar!")));
        return;
      }

      setState(() => _isSaving = true);

      try {
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) throw Exception("User belum login!");

        // LOGIKA ALAMAT UTAMA (Mematikan yang lama jika ini di-set Utama)
        if (_isDefault) {
          final oldDefaults = await FirebaseFirestore.instance
              .collection('addresses')
              .where('userId', isEqualTo: currentUser.uid)
              .where('is_default', isEqualTo: true)
              .get();

          WriteBatch batch = FirebaseFirestore.instance.batch();
          for (var doc in oldDefaults.docs) {
            batch.update(doc.reference, {'is_default': false});
          }
          await batch.commit(); 
        }

        // DATA ASLI UNTUK FIRESTORE
        final Map<String, dynamic> addressData = {
          'userId': currentUser.uid,
          'receiver': _nameController.text,
          'phone': _phoneController.text,
          'areaId': _selectedAreaId,         // ID Unik Biteship (Sangat penting untuk hitung ongkir nanti)
          'areaName': _selectedAreaName,     // Nama lengkap area
          'full_address': _streetController.text,
          'label': _selectedLabel,
          'is_default': _isDefault,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Simpan ke Firestore
        await FirebaseFirestore.instance.collection('addresses').add(addressData);

        if (mounted) {
          setState(() => _isSaving = false);
          Navigator.pop(context, true); // Kembali & bawa sinyal sukses
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Alamat berhasil disimpan!")));
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gagal menyimpan: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Alamat Baru", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Kontak"),
              _buildTextField(_nameController, "Nama Lengkap", "Masukkan nama penerima"),
              _buildTextField(_phoneController, "Nomor Telepon", "Contoh: 08123456789", isPhone: true),
              
              const SizedBox(height: 24),
              _buildSectionTitle("Lokasi Pengiriman (Biteship)"),
              
              // WIDGET AUTOCOMPLETE BITESHIP
              _buildAreaAutocomplete(),

              const SizedBox(height: 16),
              _buildTextField(_streetController, "Detail Jalan / Patokan", "Contoh: Jl. Mawar No. 12, Pagar Hitam", maxLines: 3),
              
              const SizedBox(height: 24),
              _buildSectionTitle("Pengaturan Alamat"),
              _buildLabelPicker(),
              const SizedBox(height: 16),
              _buildDefaultSwitch(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  // --- WIDGET AUTOCOMPLETE PENCARIAN AREA ---
// --- WIDGET AUTOCOMPLETE PENCARIAN AREA ---
  Widget _buildAreaAutocomplete() {
    // 1. UBAH dynamic menjadi Map<String, dynamic>
    return Autocomplete<Map<String, dynamic>>(
      
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.length < 3) {
          // UBAH JUGA DI SINI
          return const Iterable<Map<String, dynamic>>.empty();
        }
        try {
          // Ambil data dari API
          final results = await _apiService.searchArea(textEditingValue.text);
          
          // Cast / Konversi dari list dynamic menjadi list Map<String, dynamic>
          return results.map((item) => item as Map<String, dynamic>).toList();
          
        } catch (e) {
          // UBAH JUGA DI SINI
          return const Iterable<Map<String, dynamic>>.empty();
        }
      },
      
      // 2. Sesuaikan tipe parameter menjadi Map<String, dynamic>
      displayStringForOption: (Map<String, dynamic> option) => _formatAreaName(option),
      
      // 3. Sesuaikan tipe parameter selection
      onSelected: (Map<String, dynamic> selection) {
        setState(() {
          _selectedAreaId = selection['id']; 
          _selectedAreaName = _formatAreaName(selection); 
        });
        FocusScope.of(context).unfocus();
      },

      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: "Ketik Kecamatan / Kode Pos",
            hintText: "Contoh: Gubeng atau 60281",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: const Icon(Icons.search, color: Colors.grey),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Area tidak boleh kosong";
            if (_selectedAreaId == null) return "Silakan pilih area dari daftar pop-up";
            return null;
          },
        );
      },
    );
  }
  
  // --- WIDGET HELPERS (Sama seperti sebelumnya) ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isPhone = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) => value == null || value.isEmpty ? "$label tidak boleh kosong" : null,
      ),
    );
  }

  Widget _buildLabelPicker() {
    return Row(
      children: ['Rumah', 'Kantor'].map((label) {
        bool isSelected = _selectedLabel == label;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (val) => setState(() => _selectedLabel = label),
            selectedColor: Colors.red.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.red : Colors.grey.shade300)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDefaultSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Atur sebagai Alamat Utama", style: TextStyle(fontSize: 14)),
        Switch(
          value: _isDefault,
          activeColor: Colors.red,
          onChanged: (val) => setState(() => _isDefault = val),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveAddress,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isSaving 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("Simpan Alamat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}