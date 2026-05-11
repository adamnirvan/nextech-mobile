import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title; 
  final bool showSearchBar;
  final bool showCart;
  final Color backgroundColor;
  final Color contentColor;
  final bool showBackButton; 
  

  const GlobalAppBar({
    
    super.key,
    this.title,
    this.showSearchBar = false,
    this.showCart = true,
    this.backgroundColor = const Color(0xFF1D1D1D),
    this.contentColor = Colors.white,
    this.showBackButton = false, 
    
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Matikan bawaan otomatis
      automaticallyImplyLeading: false, 
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false,

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
            icon: Icon(Icons.shopping_cart, color: Colors.white),
          ),
        const SizedBox(width: 8), 
      ],
    );
  }

Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(context, AppRoutes.search);
        
        if (result != null && result is String && result.isNotEmpty) {
           Navigator.pushNamed(
             context, 
             AppRoutes.discovery, 
             arguments: {'searchQuery': result} 
           );
        }
      },

      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12), 
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), 
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF7E7E7E), size: 20),
            const SizedBox(width: 8), 
            const Expanded(
              child: Text(
                "Find your next tech...",
                style: TextStyle(
                  color: Color(0xFF7E7E7E), 
                  fontSize: 15, 
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