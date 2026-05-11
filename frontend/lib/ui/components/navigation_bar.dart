import 'package:flutter/material.dart';
import '../screens/main/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/discovery/discovery_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<Widget> screens = [
      const HomeScreen(),
      const DiscoveryScreen(), 
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: screens[_selectedIndex], 
      
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
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: colorScheme.primary.withOpacity(0.12),
            
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  fontFamily: 'PlusJakartaSans', 
                  fontWeight: FontWeight.bold, 
                  fontSize: 12, 
                  color: colorScheme.primary,
                );
              }
              return TextStyle(
                fontFamily: 'PlusJakartaSans', 
                fontWeight: FontWeight.w600, 
                fontSize: 11, 
                color: colorScheme.onSurface.withOpacity(0.5),
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: colorScheme.primary, size: 24);
              }
              return IconThemeData(color: colorScheme.onSurface.withOpacity(0.5), size: 24);
            }),
          ),
          
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.transparent, 
            elevation: 0,
            height: 65,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Discovery',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: 'Notification',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}