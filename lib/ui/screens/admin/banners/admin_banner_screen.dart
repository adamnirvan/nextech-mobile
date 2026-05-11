import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  bool _isLoading = false;

  // --- CONFIG CLOUDINARY ---
  final String cloudName = 'dfcqgw3pr'; 
  final String uploadPreset = 'nextech_preset';

  // 1. FUNGSI UPLOAD BANNER
  Future<void> _uploadNewBanner() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    final colorScheme = Theme.of(context).colorScheme;

    try {
      File imageFile = File(pickedFile.path);

      // Upload ke Cloudinary
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final resData = jsonDecode(String.fromCharCodes(await response.stream.toBytes()));
        String imageUrl = resData['secure_url'];

        // Simpan link-nya ke Firestore collection 'banners'
        await FirebaseFirestore.instance.collection('banners').add({
          'image_url': imageUrl,
          'created_at': FieldValue.serverTimestamp(),
          'is_active': true,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Banner uploaded successfully!", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onPrimary, fontWeight: FontWeight.bold)), 
              backgroundColor: colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            )
          );
        }
      } else {
        throw Exception("Failed to upload to Cloudinary");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onError)), 
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          )
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. FUNGSI HAPUS BANNER
  Future<void> _deleteBanner(String docId) async {
    final colorScheme = Theme.of(context).colorScheme;

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          "Delete Banner?", 
          style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface, fontWeight: FontWeight.bold)
        ),
        content: Text(
          "This banner will be removed from the Customer app.", 
          style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.7))
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text("Cancel", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.5)))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text("Delete", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.error, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseFirestore.instance.collection('banners').doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Banner deleted!", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onError, fontWeight: FontWeight.bold)),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          )
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
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title: Text(
          "Banner Management", 
          style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: colorScheme.onSurface.withOpacity(0.08)),
        ),
      ),
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                CircularProgressIndicator(color: colorScheme.primary), 
                const SizedBox(height: 16), 
                Text("Uploading Banner...", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500))
              ]
            )
          )
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('banners').orderBy('created_at', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.view_carousel_outlined, size: 64, color: colorScheme.onSurface.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        "No promotional banners yet", 
                        style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w600, fontSize: 14)
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  String imageUrl = doc['image_url'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9, 
                          child: Image.network(
                            imageUrl, 
                            fit: BoxFit.cover, 
                            errorBuilder: (c, e, s) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(Icons.broken_image, size: 40, color: colorScheme.onSurface.withOpacity(0.3))
                            )
                          ),
                        ),
                        
                        Positioned(
                          top: 12, right: 12,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _deleteBanner(doc.id),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withOpacity(0.85), 
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.delete_outline, size: 20, color: colorScheme.error),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
      
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        icon: Icon(Icons.add_photo_alternate_outlined, color: colorScheme.onPrimary),
        label: Text("Upload Banner", style: TextStyle(fontFamily: 'PlusJakartaSans', color: colorScheme.onPrimary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: _uploadNewBanner,
      ),
    );
  }
}