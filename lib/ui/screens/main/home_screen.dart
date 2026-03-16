import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_colors.dart';
import 'package:nextech_mobile/core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 1,
        toolbarHeight: 70,

        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),

          clipBehavior: Clip.antiAlias,

          child: TextField(
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              filled: false,
              isDense: true,
              hintText: "Hai, cari apa?",
              prefixIcon: const Icon(Icons.search, color: AppColors.grey500),
              contentPadding: const EdgeInsets.only(right: 10),

              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications),
            color: AppColors.textPrimaryDark,
          ),
          const SizedBox(width: 10), //spacing
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.shopping_cart),
            color: AppColors.textPrimaryDark,
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16.0),

        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  spreadRadius: 1,
                  blurRadius: 7,
                  offset: const Offset(0, 2),
                ),
              ],
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          const SizedBox(height: 20), //spacing

          Container(
            height: 90,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  spreadRadius: 1,
                  blurRadius: 7,
                  offset: const Offset(0, 2),
                ),
              ],
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),

            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Column(
                      children: [
                        Icon(Icons.laptop_mac, size: 35),
                        const SizedBox(height: 4),
                        Text(
                          "Laptop",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 50), //spacing
                  InkWell(
                    onTap: () {},
                    child: Column(
                      children: [
                        Icon(Icons.smartphone, size: 35),
                        const SizedBox(height: 4),
                        Text(
                          "Phone",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 50), //spacing
                  InkWell(
                    onTap: () {},
                    child: Column(
                      children: [
                        Icon(Icons.sports_esports_rounded, size: 35),
                        const SizedBox(height: 4),
                        Text(
                          "Gaming",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 50), //spacing
                  InkWell(
                    onTap: () {},
                    child: Column(
                      children: [
                        Icon(Icons.watch, size: 35),
                        const SizedBox(height: 4),
                        Text(
                          "Smartwatch",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 50), //spacing
                  InkWell(
                    onTap: () {},
                    child: Column(
                      children: [
                        Icon(Icons.headphones_rounded, size: 35),
                        const SizedBox(height: 4),
                        Text(
                          "Audio/TWS",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
