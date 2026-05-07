import 'package:dio/dio.dart';

class ApiService {
  // Pastikan IP ini sesuai dengan IP laptopmu ya!
  static const String _baseUrl = 'http://192.168.1.7:3000/api/';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // ==========================================
  // PENCARIAN AREA BITESHP (CUKUP 1 FUNGSI)
  // ==========================================
  Future<List<dynamic>> searchArea(String keyword) async {
    try {
      // Kita kirim keyword ketikan user ke Node.js
      final response = await _dio.get('search-area', queryParameters: {'keyword': keyword});
      
      if (response.data['success'] == true) {
        return response.data['data']; 
      }
      return [];
    } catch (e) {
      print('Error searchArea: $e');
      throw Exception('Gagal mencari area: $e');
    }
  }

  Future<double> checkRates(String destinationAreaId, List<dynamic> items) async {
    try {
      final response = await _dio.post('check-rates', data: {
        'destinationAreaId': destinationAreaId,
        'items': items,
      });

      if (response.data['success'] == true) {
        List pricings = response.data['data'];
        
        // Pastikan Biteship mengembalikan daftar harga
        if (pricings.isNotEmpty) {
          // Untuk saat ini, kita ambil harga dari kurir pertama yang dikembalikan Biteship
          // (Nanti bisa kita kembangkan jadi menu dropdown pilihan kurir)
          return (pricings[0]['price'] as num).toDouble();
        }
      }
      return 0; // Default jika gagal
    } catch (e) {
      print('Error checkRates: $e');
      return 0;
    }
  }
  
}