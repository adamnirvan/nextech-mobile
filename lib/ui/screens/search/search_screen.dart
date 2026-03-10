import 'package:flutter/material.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';


class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: Center(
        child: Text("Halaman pencarian segera hadir!", style: AppText.heading2),
      ),
    );
  }
}
