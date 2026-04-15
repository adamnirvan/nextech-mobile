import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title; 
  final bool showSearchBar;
  final bool showCart;
  final Color backgroundColor;
  final Color contentColor;
  // TAMBAHAN BARU: Parameter untuk menampilkan tombol back
  final bool showBackButton; 

  const GlobalAppBar({
    super.key,
    this.title,
    this.showSearchBar = false,
    this.showCart = true,
    this.backgroundColor = const Color.fromARGB(218, 0, 0, 0),
    this.contentColor = Colors.white,
    this.showBackButton = false, // Default false agar layar lain tidak berubah
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Matikan bawaan otomatis
      automaticallyImplyLeading: false, 
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false,

      // LOGIKA TOMBOL BACK:
      // Jika showBackButton true, tampilkan ikon back manual di sebelah kiri.
      leading: showBackButton 
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: contentColor),
              onPressed: () => Navigator.pop(context),
            )
          : null,

      title: showSearchBar
          ? _buildSearchBar(context)
          : Text(
              title ?? "", 
              style: TextStyle(
                color: contentColor,
                fontWeight: FontWeight.bold,
              ),
            ),

      actions: [
        if (showCart)
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.cart);
            },
            icon: Icon(Icons.shopping_cart, color: contentColor),
          ),
        const SizedBox(width: 8), 
      ],
    );
  }

Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman pencarian sesungguhnya
        Navigator.pushNamed(context, AppRoutes.search);
      },
      child: Container(
        height: 40,
        // Tambahkan padding horizontal agar isi tidak mepet ke tepi (menggantikan contentPadding TextField)
        padding: const EdgeInsets.symmetric(horizontal: 12), 
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), 
          borderRadius: BorderRadius.circular(8),
        ),
        // Menggunakan Row biasa alih-alih TextField
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF7E7E7E), size: 20),
            const SizedBox(width: 8), // Jarak antara ikon dan teks
            const Expanded(
              child: Text(
                "Find your next tech...",
                style: TextStyle(
                  color: Color(0xFF7E7E7E), 
                  fontSize: 15, // Disesuaikan agar mirip dengan TextField asli
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}