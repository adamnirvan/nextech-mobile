import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class DynamicField { 
  TextEditingController keyCtrl = TextEditingController(); 
  TextEditingController valCtrl = TextEditingController(); 
}

class AdminProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? productData; 
  final String? productId; 

  const AdminProductFormScreen({super.key, this.productData, this.productId});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _titleCtrl = TextEditingController(), _descCtrl = TextEditingController(), _catCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(), _discountCtrl = TextEditingController(), _stockCtrl = TextEditingController();
  
  final List<DynamicField> _specs = [];
  final List<DynamicField> _variants = [];
  
  List<File> _selectedImages = [];
  List<String> _existingImages = []; 
  bool _isLoading = false;
  bool _isPromo = false;
  int _finalPricePreview = 0;
  int _discountPercentPreview = 0;

  final String cloudName = 'dfcqgw3pr'; 
  final String uploadPreset = 'nextech_preset';

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      final p = widget.productData!;
      _titleCtrl.text = p['title'] ?? '';
      _descCtrl.text = p['description'] ?? '';
      _catCtrl.text = p['category'] ?? '';
      _priceCtrl.text = (p['original_price'] ?? 0).toString();
      _stockCtrl.text = (p['stock'] ?? 0).toString();
      _isPromo = p['is_promo'] ?? false;
      
      if (_isPromo) {
        int original = (p['original_price'] ?? 0);
        int current = (p['price'] ?? 0);
        _discountCtrl.text = (original - current).toString();
      }

      _existingImages = List<String>.from(p['images'] ?? []);
      
      if (p['Specifications'] != null) {
        (p['Specifications'] as Map).forEach((k, v) {
          _specs.add(DynamicField()..keyCtrl.text = k ..valCtrl.text = v.toString());
        });
      }

      if (p['variants'] != null) {
        (p['variants'] as Map).forEach((k, v) {
          _variants.add(DynamicField()..keyCtrl.text = k ..valCtrl.text = (v as List).join(', '));
        });
      }
      
      _calculatePricePreview();
    }
  }

  void _calculatePricePreview() {
    int originalPrice = int.tryParse(_priceCtrl.text) ?? 0;
    if (!_isPromo) {
      _finalPricePreview = originalPrice;
      _discountPercentPreview = 0;
    } else {
      int discountNominal = int.tryParse(_discountCtrl.text) ?? 0;
      if (discountNominal > originalPrice) discountNominal = originalPrice;
      _finalPricePreview = originalPrice - discountNominal;
      _discountPercentPreview = originalPrice > 0 ? ((discountNominal / originalPrice) * 100).round() : 0;
    }
    setState(() {});
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() => _selectedImages = pickedFiles.map((x) => File(x.path)).toList());
    }
  }

  Future<List<String>> _uploadAllToCloudinary() async {
    List<String> uploadedUrls = [];
    for (File image in _selectedImages) {
      final req = http.MultipartRequest('POST', Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload'))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));
      final res = await req.send();
      if (res.statusCode == 200) {
        uploadedUrls.add(jsonDecode(String.fromCharCodes(await res.stream.toBytes()))['secure_url']);
      }
    }
    return uploadedUrls;
  }

  Future<void> _saveProduct() async {
    if (_titleCtrl.text.isEmpty || _priceCtrl.text.isEmpty || (_selectedImages.isEmpty && _existingImages.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Incomplete data!", style: TextStyle(fontFamily: 'PlusJakartaSans')), backgroundColor: Theme.of(context).colorScheme.error));
      return;
    }
    setState(() => _isLoading = true);

    try {
      List<String> finalImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        finalImageUrls = await _uploadAllToCloudinary();
      } else {
        finalImageUrls = _existingImages;
      }

      _calculatePricePreview(); 

      Map<String, dynamic> specsMap = {}, variantsMap = {};
      for (var s in _specs) { if (s.keyCtrl.text.isNotEmpty) specsMap[s.keyCtrl.text.trim()] = s.valCtrl.text.trim(); }
      for (var v in _variants) { if (v.keyCtrl.text.isNotEmpty) variantsMap[v.keyCtrl.text.trim()] = v.valCtrl.text.split(',').map((e) => e.trim()).toList(); }

      Map<String, dynamic> data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _catCtrl.text.trim().toLowerCase(),
        'original_price': int.tryParse(_priceCtrl.text) ?? 0,
        'discount_percentage': _discountPercentPreview,
        'price': _finalPricePreview,
        'stock': int.tryParse(_stockCtrl.text) ?? 0,
        'image_url': finalImageUrls[0],
        'images': finalImageUrls,
        'is_promo': _isPromo && _discountPercentPreview > 0,
        'Specifications': specsMap,
        'variants': variantsMap,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (widget.productId == null) {
        data['created_at'] = FieldValue.serverTimestamp();
        data['rating'] = 0.0;
        data['sold_count'] = 0;
        await FirebaseFirestore.instance.collection('products').add(data);
      } else {
        await FirebaseFirestore.instance.collection('products').doc(widget.productId).update(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved successfully!", style: TextStyle(fontFamily: 'PlusJakartaSans')), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e", style: const TextStyle(fontFamily: 'PlusJakartaSans')), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.productId != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Product" : "Add Product", style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, fontSize: 18, color: colorScheme.onSurface)), 
        backgroundColor: colorScheme.surface, 
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(color: colorScheme.primary)) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Product Photos", style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._selectedImages.map((file) => Container(width: 100, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: FileImage(file), fit: BoxFit.cover)))),
                  
                  if (_selectedImages.isEmpty)
                  ..._existingImages.map((url) => Container(width: 100, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)))),

                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100, 
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.5), 
                        borderRadius: BorderRadius.circular(16), 
                      ), 
                      child: Icon(Icons.add_photo_alternate_outlined, color: colorScheme.onSurface.withOpacity(0.5), size: 28)
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildInput("Product Title", _titleCtrl, colorScheme),
            _buildInput("Category", _catCtrl, colorScheme),
            _buildInput("Description", _descCtrl, colorScheme, lines: 4),
            _buildInput("Normal Price (Rp)", _priceCtrl, colorScheme, isNum: true, onChanged: (v) => _calculatePricePreview()),
            
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Enable Discount", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              value: _isPromo,
              activeColor: colorScheme.primary,
              onChanged: (val) => setState(() { _isPromo = val; _calculatePricePreview(); }),
            ),

            if (_isPromo) ...[
              const SizedBox(height: 12),
              _buildInput("Discount Amount (Rp)", _discountCtrl, colorScheme, isNum: true, onChanged: (v) => _calculatePricePreview()),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), 
                width: double.infinity, 
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Text(
                  "Final Price: Rp $_finalPricePreview ($_discountPercentPreview%)", 
                  style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 14)
                )
              ),
              const SizedBox(height: 24),
            ],

            _buildInput("Stock", _stockCtrl, colorScheme, isNum: true),
            
            Divider(height: 60, color: colorScheme.onSurface.withOpacity(0.08)),
            _buildDynamicSection("Specifications", _specs, "Key", "Value", colorScheme),
            
            Divider(height: 60, color: colorScheme.onSurface.withOpacity(0.08)),
            _buildDynamicSection("Variants", _variants, "Type", "Options (comma-separated)", colorScheme),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, 
              height: 55, 
              child: ElevatedButton(
                onPressed: _saveProduct, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary, 
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ), 
                child: Text(
                  isEdit ? "SAVE CHANGES" : "PUBLISH", 
                  style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onPrimary, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                )
              )
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController ctrl, ColorScheme colorScheme, {bool isNum = false, int lines = 1, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16), 
      child: TextField(
        controller: ctrl, 
        keyboardType: isNum ? TextInputType.number : TextInputType.text, 
        maxLines: lines, 
        onChanged: onChanged, 
        style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          labelText: hint, 
          labelStyle: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        )
      )
    );
  }

  Widget _buildDynamicSection(String title, List<DynamicField> list, String h1, String h2, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [ 
            Text(title, style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)), 
            TextButton.icon(
              onPressed: () => setState(() => list.add(DynamicField())), 
              icon: Icon(Icons.add, size: 18, color: colorScheme.primary),
              label: Text("Add", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.primary, fontWeight: FontWeight.bold))
            ) 
          ]
        ),
        const SizedBox(height: 12),
        ...list.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ 
              Expanded(flex: 2, child: _buildInput(h1, e.value.keyCtrl, colorScheme)), 
              const SizedBox(width: 12), 
              Expanded(flex: 3, child: _buildInput(h2, e.value.valCtrl, colorScheme)), 
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error), 
                onPressed: () => setState(() => list.removeAt(e.key))
              ) 
            ]
          ),
        )),
      ]
    );
  }
}