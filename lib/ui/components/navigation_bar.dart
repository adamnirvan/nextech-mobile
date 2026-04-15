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
  // Variable untuk menyimpan index tab yang sedang aktif
  // 0 = Home, 1 = Discovery, 2 = Cart, 3 = Profile
  int _selectedIndex = 0;

  // Daftar halaman yang akan berganti-ganti di dalam body
  final List<Widget> _screens = [
    const HomeScreen(), // Ini adalah HomeScreen yang sudah kamu buat panjang lebar tadi!
    // Di bawah ini adalah halaman sementara (placeholder)
    // karena kamu belum membuat file untuk Discovery, Cart, dan Profile
    const DiscoveryScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  // Fungsi yang dipanggil ketika tombol di navbar diklik
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Mengubah index aktif
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan halaman berdasarkan index yang aktif
      body: _screens[_selectedIndex],

      // Inilah Bottom Navigation Bar-nya
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // Penting agar icon tidak bergeser aneh
        backgroundColor: Colors.white,
        selectedItemColor:
            Colors.black, // Warna saat aktif (sesuai gambar referensi)
        unselectedItemColor: Colors.grey, // Warna saat tidak aktif
        selectedFontSize: 10,
        unselectedFontSize: 10,
        currentIndex:
            _selectedIndex, // Memberitahu navbar tombol mana yang sedang aktif
        onTap: _onItemTapped, // Jalankan fungsi ini saat diklik
        // Daftar tombol (harus berurutan sesuai dengan _screens di atas)
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'HOME'),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore), // Mirip icon compass di desain
            label: 'DISCOVERY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'NOTIFICATION',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }
}
