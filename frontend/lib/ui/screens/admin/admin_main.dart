import 'package:flutter/material.dart';
import 'products/admin_product_screen.dart';
import 'orders/admin_order_screen.dart';
import 'banners/admin_banner_screen.dart';
import 'dashboard/admin_dashboard_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  // LAYAR ADMIN UTAMA
  final List<Widget> _adminScreens = [
    const AdminDashboardScreen(),
    const AdminProductsScreen(),
    const AdminOrdersScreen(),
    const AdminBannersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: _adminScreens[_selectedIndex],
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.08), 
              width: 1,
            ),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            
            selectedItemColor: colorScheme.primary, 
            unselectedItemColor: colorScheme.onSurface.withOpacity(0.4),
            
            selectedLabelStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans', 
              fontWeight: FontWeight.bold, 
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans', 
              fontWeight: FontWeight.w600, 
              fontSize: 10,
            ),
            
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4), 
                  child: Icon(Icons.dashboard_rounded),
                ), 
                label: 'Dashboard'
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4), 
                  child: Icon(Icons.inventory_2_rounded),
                ), 
                label: 'Products'
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4), 
                  child: Icon(Icons.shopping_bag_rounded),
                ), 
                label: 'Orders'
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4), 
                  child: Icon(Icons.campaign_rounded),
                ), 
                label: 'Banners'
              ),
            ],
          ),
        ),
      ),
    );
  }
}