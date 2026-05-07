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
    // SANGAT BERSIH! Tidak ada lagi oper-operan fungsi.
    final List<Widget> screens = [
      const HomeScreen(),
      const DiscoveryScreen(), // Ini Discovery versi Tab Bar
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex], // Tampilkan layar yang aktif
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, 
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'DISCOVERY'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'NOTIFICATION'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }
}
