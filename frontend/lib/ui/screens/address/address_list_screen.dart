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
  String? _selectedAddressId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null &&
        args['currentSelectedId'] != null &&
        _selectedAddressId == null) {
      _selectedAddressId = args['currentSelectedId'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool isSelectionMode = args?['isSelectionMode'] ?? false;
    final User? currentUser = FirebaseAuth.instance.currentUser;

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
          isSelectionMode ? "Select Address" : "My Address",
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
      body: currentUser == null
          ? Center(
              child: Text(
                "Please login to your account",
                style: TextStyle(color: colorScheme.onSurface),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('addresses')
                  .where('userId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.onSurface,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(colorScheme);
                }

                final List<DocumentSnapshot> addressDocs =
                    snapshot.data!.docs;

                // Sort berdasarkan field 'is_default' dari Firestore (bukan state lokal)
                addressDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final bool isADefault = aData['is_default'] == true;
                  final bool isBDefault = bData['is_default'] == true;
                  if (isADefault && !isBDefault) return -1;
                  if (!isADefault && isBDefault) return 1;
                  return 0;
                });

                return ListView.builder(
                  padding:
                      const EdgeInsets.only(top: 12, bottom: 110, left: 12, right: 12),
                  itemCount: addressDocs.length,
                  itemBuilder: (context, index) {
                    final doc = addressDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id;
                    return _buildAddressCard(data, isSelectionMode, colorScheme);
                  },
                );
              },
            ),
      bottomSheet: _buildBottomButton(colorScheme),
    );
  }

  Widget _buildAddressCard(
    Map<String, dynamic> address,
    bool isSelectionMode,
    ColorScheme colorScheme,
  ) {
    final bool isSelected = _selectedAddressId == address['id'];

    final bool isDefault = address['is_default'] == true;
    final String label = address['label'] ?? 'Home';

    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          setState(() => _selectedAddressId = address['id']);
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) Navigator.pop(context, address);
          });
        } else {
          Navigator.pushNamed(
            context,
            AppRoutes.addressForm,
            arguments: address,
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.onSurface
                : colorScheme.onSurface.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
          
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio button hanya muncul di selection mode
              if (isSelectionMode) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.35),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Ikon label (Rumah / Kantor)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  label == 'Office' ? Icons.business_outlined : Icons.home_outlined,
                  size: 18,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris nama + badge label
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${address['receiver']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        // Badge label (Rumah/Kantor)
                        _buildLabelBadge(label, colorScheme),
                      ],
                    ),

                    const SizedBox(height: 2),
                    Text(
                      address['phone'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "${address['full_address']}, ${address['areaName']}",
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    // ============================================================
                    // Badge "Utama" berdasarkan is_default dari Firestore
                    // ============================================================
                    if (isDefault) ...[
                      const SizedBox(height: 10),
                      _buildDefaultBadge(colorScheme),
                    ],
                  ],
                ),
              ),

              // Tombol "Ubah" hanya di selection mode
              if (isSelectionMode)
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addressForm,
                      arguments: address,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      "Edit",
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        //decoration: TextDecoration.underline,
                        //decorationColor: colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ),
                ),

              // Panah ">" hanya di mode manajemen (bukan selection)
              if (!isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 2),
                  child: Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface.withOpacity(0.3),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelBadge(String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.6),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDefaultBadge(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: 12,
          color: colorScheme.onSurface,
        ),
        const SizedBox(width: 4),
        Text(
          "Main",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_outlined,
              size: 36,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No address saved yet",
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.45),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Add your shipping address now",
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addressForm),
          icon: Icon(Icons.add, color: colorScheme.onSurface, size: 20),
          label: Text(
            "Add New Address",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.3),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}