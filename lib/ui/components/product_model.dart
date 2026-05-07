import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  smartphone,
  laptop,
  audio,
  gaming,
  smartwatch,
  accessories,
  all,
}

class ProductModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> images;
  final bool isPromo;
  final ProductCategory category;
  final int originalPrice;
  final int price;
  final double rating;
  final int soldCount;
  final int discountPercentage;
  final Map<String, dynamic> variants;
  final Map<String, dynamic> specifications;

  ProductModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.images,
    required this.isPromo,
    required this.originalPrice,
    required this.price,
    required this.rating,
    required this.soldCount,
    required this.discountPercentage,
    required this.variants,
    required this.specifications,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    ProductCategory cat = ProductCategory.values.firstWhere(
      (e) => e.name == (data['category']?.toString().toLowerCase() ?? ''),
      orElse: () => ProductCategory.accessories,
    );

    return ProductModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      isPromo: data['is_promo'] ?? false,
      category:cat,
      originalPrice: data['original_price'] ?? 0,
      price: data['price'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      soldCount: data['sold_count'] ?? 0,
      discountPercentage: data['discount_percentage'] ?? 0,
      variants: data['variants'] ?? {},
      specifications: data['Specifications'] ?? {},
    );
  }
}
