import 'package:flutter_test/flutter_test.dart';
// Pastikan import ini mengarah ke file main.dart kamu
import 'package:nextech_mobile/main.dart'; 

void main() {
  testWidgets('NextechApp smoke test', (WidgetTester tester) async {
    // 1. Jalankan aplikasi utama (Ganti NextechApp() kalau nama class di main.dart-mu beda)
    await tester.pumpWidget(const NextechApp());

    // 2. Karena ini baru tahap awal, kita buat tes sederhana: 
    // Memastikan widget NextechApp berhasil di-render tanpa crash.
    expect(find.byType(NextechApp), findsOneWidget);
    
    // Nanti kalau fitur keranjang atau login udah jalan, 
    // kamu bisa tambah logic testing UI yang lebih kompleks di sini.
  });
}