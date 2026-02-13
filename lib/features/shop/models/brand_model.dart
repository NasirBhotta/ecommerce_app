import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  final String id;
  final String name;
  final String logoUrl;
  final int productCount;
  final bool verified;
  final String category;

  BrandModel({
    required this.id,
    required this.name,
    this.logoUrl = '',
    this.productCount = 0,
    this.verified = false,
    this.category = '',
  });

  factory BrandModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    return BrandModel.fromMap(data, id: snapshot.id);
  }

  factory BrandModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return BrandModel(
      id: id ?? (data['id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      logoUrl: (data['logoUrl'] ?? data['logo'] ?? '').toString(),
      productCount: (data['productCount'] ?? 0) is num
          ? (data['productCount'] as num).toInt()
          : int.tryParse((data['productCount'] ?? '0').toString()) ?? 0,
      verified: data['verified'] == true,
      category: (data['category'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'productCount': productCount,
      'verified': verified,
      'category': category,
    };
  }
}
