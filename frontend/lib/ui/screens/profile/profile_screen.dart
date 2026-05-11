import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import 'package:nextech_mobile/ui/components/global_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      QuerySnapshot ordersSnap = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      int unpaid = 0, processing = 0, shipped = 0, completed = 0;

      for (var doc in ordersSnap.docs) {
        final status = (doc.data() as Map<String, dynamic>)['status'] ?? '';
        if (status == 'unpaid') unpaid++;
        if (status == 'processing') processing++;
        if (status == 'shipped') shipped++;
        if (status == 'completed') completed++;
      }

      setState(() {
        _userData = {
          'name': userDoc.exists
              ? (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Guest'
              : 'Guest',
          'email': currentUser.email ?? '',
          'orders': {
            'unpaid': unpaid,
            'processing': processing,
            'shipped': shipped,
            'completed': completed,
          },
        };
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.onSurface),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: GlobalAppBar(
        title: "Profile",
        backgroundColor: colorScheme.surface,
        contentColor: colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────────
            _buildHeader(colorScheme, isDark),

            // ── BODY (overlap card) ─────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Card: My Orders
                    _buildOrdersCard(colorScheme),
                    const SizedBox(height: 12),

                    // Card: Menu items
                    _buildMenuCard(colorScheme),
                    const SizedBox(height: 20),

                    // Logout button
                    _buildLogoutButton(colorScheme),

                    const SizedBox(height: 24),
                    Text(
                      "NEXTECH MARKETPLACE",
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.25),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────
  Widget _buildHeader(ColorScheme colorScheme, bool isDark) {
    final String name = _userData['name'] ?? 'Guest';
    final String email = _userData['email'] ?? '';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 52),
      color: colorScheme.surface,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.onSurface.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name & email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: colorScheme.primary.withOpacity(0.55),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ORDERS CARD ───────────────────────────────────────────────────────
  Widget _buildOrdersCard(ColorScheme colorScheme) {
    final orders = _userData['orders'] ?? {};
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "MY ORDERS",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.order,
                    arguments: 0,
                  ),
                  child: Text(
                    "See all →",
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
            child: Row(
              children: [
                _buildOrderTile(
                  context,
                  colorScheme,
                  icon: Icons.account_balance_wallet_outlined,
                  label: "Unpaid",
                  count: orders['unpaid'] ?? 0,
                  tabIndex: 0,
                ),
                _buildOrderTile(
                  context,
                  colorScheme,
                  icon: Icons.autorenew_rounded,
                  label: "Processing",
                  count: orders['processing'] ?? 0,
                  tabIndex: 1,
                ),
                _buildOrderTile(
                  context,
                  colorScheme,
                  icon: Icons.local_shipping_outlined,
                  label: "Shipped",
                  count: orders['shipped'] ?? 0,
                  tabIndex: 2,
                ),
                _buildOrderTile(
                  context,
                  colorScheme,
                  icon: Icons.inventory_2_outlined,
                  label: "Completed",
                  count: orders['completed'] ?? 0,
                  tabIndex: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile(
    BuildContext context,
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    required int count,
    required int tabIndex,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.order, arguments: tabIndex),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: colorScheme.onError,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ── MENU CARD ─────────────────────────────────────────────────────────
  Widget _buildMenuCard(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuRow(
            colorScheme,
            icon: Icons.location_on_outlined,
            label: "Address",
            onTap: () => Navigator.pushNamed(context, AppRoutes.addressList),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 66,
            endIndent: 16,
            color: colorScheme.onSurface.withOpacity(0.07),
          ),
      ],
    );
  }

  // ── LOGOUT ────────────────────────────────────────────────────────────
  Widget _buildLogoutButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.auth,
              (route) => false,
            );
          }
        },
        icon: Icon(Icons.logout_rounded, size: 18, color: colorScheme.error),
        label: Text(
          "Logout",
          style: TextStyle(
            color: colorScheme.error,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: colorScheme.error.withOpacity(0.4),
            width: 1.5,
          ),
          backgroundColor: colorScheme.error.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
