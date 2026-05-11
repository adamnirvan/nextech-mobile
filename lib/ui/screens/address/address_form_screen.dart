import 'package:nextech_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressFormScreen extends StatefulWidget {
  final Map<String, dynamic>? addressData;

  const AddressFormScreen({super.key, this.addressData});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  bool _isDefault = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isEdit = false;
  bool _isInitialized = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  String _selectedLabel = 'Home';

  String? _selectedAreaId;
  String? _selectedAreaName;

  // Menyimpan addressData yang diterima 
  Map<String, dynamic>? _addressData;

  @override
  void initState() {
    super.initState();
    // Jika data dikirim lewat constructor (MaterialPageRoute), pakai langsung
    if (widget.addressData != null) {
      _fillForm(widget.addressData!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Jika data dikirim lewat pushNamed arguments, tangkap di sini
    // Guard _isInitialized agar tidak re-fill form setiap rebuild
    if (!_isInitialized) {
      _isInitialized = true;
      if (widget.addressData == null) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args != null && args is Map<String, dynamic>) {
          _fillForm(args);
        }
      }
    }
  }

  void _fillForm(Map<String, dynamic> data) {
    _addressData = data;
    _isEdit = true;
    _nameController.text = data['receiver'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    _streetController.text = data['full_address'] ?? '';
    _selectedAreaId = data['areaId'];
    _selectedAreaName = data['areaName'];
    _selectedLabel = data['label'] ?? 'Home';
    _isDefault = data['is_default'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  String _formatAreaName(dynamic area) {
    final district = area['name'] ?? '';
    final city = area['administrative_division_level_2_name'] ?? '';
    final province = area['administrative_division_level_1_name'] ?? '';
    final postalCode = area['postal_code'] ?? '';
    return "$district, $city, $province, $postalCode";
  }


  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAreaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan cari dan pilih area pengiriman dari daftar!"),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User belum login!");

      // Jika toggle Utama ON, nonaktifkan semua default lain
      if (_isDefault) {
        final query = FirebaseFirestore.instance
            .collection('addresses')
            .where('userId', isEqualTo: currentUser.uid)
            .where('is_default', isEqualTo: true);

        final oldDefaults = await query.get();
        final WriteBatch batch = FirebaseFirestore.instance.batch();

        for (var doc in oldDefaults.docs) {
          // Skip dokumen yang sedang diedit 
          if (_isEdit && doc.id == _addressData!['id']) continue;
          batch.update(doc.reference, {'is_default': false});
        }
        await batch.commit();
      }

      final Map<String, dynamic> dataToSave = {
        'userId': currentUser.uid,
        'receiver': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'areaId': _selectedAreaId,
        'areaName': _selectedAreaName,
        'full_address': _streetController.text.trim(),
        'label': _selectedLabel,
        'is_default': _isDefault,
      };

      if (_isEdit) {
        dataToSave['updatedAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('addresses')
            .doc(_addressData!['id'])
            .update(dataToSave);
      } else {
        dataToSave['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('addresses').add(dataToSave);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, true);
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Address saved successfully!", style: TextStyle(color: colorScheme.primary)),
            backgroundColor: Colors.green,

            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 90),
            elevation: 4,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan: $e", style: TextStyle(color: colorScheme.primary)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 90),
            elevation: 4,
          ),
        );
      }
    }
  }

  Future<void> _deleteAddress() async {
    final colorScheme = Theme.of(context).colorScheme;

    final bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text(
              "Delete Address?",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "This address will be permanently deleted and cannot be restored.",
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.65)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.55)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Delete",
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

    if (!confirm || _addressData == null) return;

    setState(() => _isDeleting = true);

    try {
      await FirebaseFirestore.instance
          .collection('addresses')
          .doc(_addressData!['id'])
          .delete();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alamat berhasil dihapus")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menghapus: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? "Edit Address" : "New Address",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.onSurface.withOpacity(0.08),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Recipient Information", colorScheme),
              _buildTextField(
                _nameController,
                "Full Name",
                "Recipient's Name",
                colorScheme: colorScheme,
              ),
              _buildTextField(
                _phoneController,
                "Phone Number",
                "e.g., 08123456789",
                isPhone: true,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Delivery Location", colorScheme),
              _buildAreaAutocomplete(colorScheme),
              const SizedBox(height: 16),
              _buildTextField(
                _streetController,
                "Address Detail",
                "e.g., Jl. Mawar No. 12, Pagar Hitam",
                maxLines: 3,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Settings", colorScheme),
              _buildLabelPicker(colorScheme),
              const SizedBox(height: 16),
              _buildDefaultSwitch(colorScheme),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(colorScheme),
    );
  }

  Widget _buildAreaAutocomplete(ColorScheme colorScheme) {
    return Autocomplete<Map<String, dynamic>>(
      initialValue: TextEditingValue(text: _selectedAreaName ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.length < 3) {
          return const Iterable<Map<String, dynamic>>.empty();
        }
        try {
          final results = await _apiService.searchArea(textEditingValue.text);
          return results.map((item) => item as Map<String, dynamic>).toList();
        } catch (e) {
          return const Iterable<Map<String, dynamic>>.empty();
        }
      },
      displayStringForOption: (Map<String, dynamic> option) =>
          _formatAreaName(option),
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
          style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
          decoration: InputDecoration(
            labelText: "Sub-District / Postal Code",
            hintText: "e.g., Gubeng atau 60281",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.55),
              fontSize: 13,
            ),
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.35),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.onSurface,
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: Icon(
              Icons.search,
              color: colorScheme.onSurface.withOpacity(0.4),
              size: 20,
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Area cannot be empty";
            if (_selectedAreaId == null) {
              return "Silakan pilih area dari daftar pop-up";
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface.withOpacity(0.4),
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isPhone = false,
    int maxLines = 1,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        maxLines: maxLines,
        style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.55),
            fontSize: 13,
          ),
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.35),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: colorScheme.onSurface,
              width: 1.5,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? "$label cannot be empty" : null,
      ),
    );
  }

  Widget _buildLabelPicker(ColorScheme colorScheme) {
    return Row(
      children: ['Home', 'Office'].map((label) {
        final bool isSelected = _selectedLabel == label;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => setState(() => _selectedLabel = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.onSurface
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withOpacity(0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    label == 'Office'
                        ? Icons.business_outlined
                        : Icons.home_outlined,
                    size: 16,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withOpacity(0.6),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDefaultSwitch(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _isDefault
            ? colorScheme.onSurface.withOpacity(0.04)
            : colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _isDefault
              ? colorScheme.onSurface.withOpacity(0.2)
              : colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_rounded,
            size: 18,
            color: _isDefault
                ? colorScheme.onSurface
                : colorScheme.onSurface.withOpacity(0.35),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Main Address",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  "Used automatically at checkout",
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDefault,
            onChanged: (val) => setState(() => _isDefault = val),
            activeColor: colorScheme.onSurface,
            activeTrackColor: colorScheme.onSurface.withOpacity(0.3),
            inactiveThumbColor: colorScheme.onSurface.withOpacity(0.35),
            inactiveTrackColor: colorScheme.onSurface.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tombol Hapus 
          if (_isEdit) ...[
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: (_isSaving || _isDeleting) ? null : _deleteAddress,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isDeleting
                          ? colorScheme.error.withOpacity(0.3)
                          : colorScheme.error,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isDeleting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: colorScheme.error,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: colorScheme.error,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],

          // Tombol Simpan 
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: (_isSaving || _isDeleting) ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onSurface,
                  disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Save Address",
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}