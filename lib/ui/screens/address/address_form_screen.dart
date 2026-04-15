import 'package:flutter/material.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isDefault = false;
  bool _isSaving = false;

  // Controller untuk menangkap input teks (API Ready)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  
  String _selectedLabel = 'Rumah'; // Default label

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // DETEKSI MODE: Jika ada data alamat, berarti mode EDIT
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (args != null && _nameController.text.isEmpty) {
      _nameController.text = args['receiver'] ?? '';
      _phoneController.text = args['phone'] ?? '';
      _streetController.text = args['full_address'] ?? '';
      _isDefault = args['is_default'] ?? false;
      // Kamu bisa menambahkan parsing untuk kota/kode pos jika datanya tersedia di API nanti
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  // --- SIMULASI API SAVE/UPDATE ---
  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      // Simulasi delay network API
      await Future.delayed(const Duration(seconds: 1));

      // Data yang akan dikirim ke Backend nantinya
      final Map<String, dynamic> addressData = {
        "receiver": _nameController.text,
        "phone": _phoneController.text,
        "full_address": _streetController.text,
        "label": _selectedLabel,
        "is_default": _isDefault,
      };

      if (mounted) {
        setState(() => _isSaving = false);
        // Kembali ke layar sebelumnya dengan membawa data baru
        Navigator.pop(context, addressData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alamat berhasil disimpan")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final bool isEdit = args != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? "Ubah Alamat" : "Alamat Baru",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
              _buildSectionTitle("Detail Alamat"),
              _buildTextField(_cityController, "Kota atau Kecamatan", "Contoh: Jakarta Selatan"),
              _buildTextField(_postalController, "Kode Pos", "Contoh: 12345", isPhone: true),
              _buildTextField(_streetController, "Nama Jalan, Gedung, No. Rumah", "Contoh: Jl. Mawar No. 12", maxLines: 3),
              
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

  // --- WIDGET HELPERS ---

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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
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
            labelStyle: TextStyle(color: isSelected ? Colors.red : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
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