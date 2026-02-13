import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final int discountPercent;
  final String category;
  final String brandId;
  final String brandName;
  final String imageUrl;
  final List<String> images;
  final bool isSuggested;
  final bool inStock;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.discountPercent = 0,
    this.category = '',
    this.brandId = '',
    this.brandName = '',
    this.imageUrl = '',
    this.images = const [],
    this.isSuggested = false,
    this.inStock = true,
  });

  String get priceLabel => '\$${price.toStringAsFixed(2)}';

  String? get discountLabel =>
      discountPercent > 0 ? '${discountPercent.toString()}%' : null;

  factory ProductModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    return ProductModel.fromMap(data, id: snapshot.id);
  }

  factory ProductModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return ProductModel(
      id: id ?? (data['id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      price: _parsePrice(data['price']),
      discountPercent: _parseDiscount(data['discount'] ?? data['discountPercent']),
      category: (data['category'] ?? '').toString(),
      brandId: (data['brandId'] ?? '').toString(),
      brandName: (data['brandName'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? data['image'] ?? '').toString(),
      images:
          (data['images'] is List)
              ? List<String>.from(
                (data['images'] as List).map((e) => e.toString()),
              )
              : const [],
      isSuggested: data['isSuggested'] == true,
      inStock: data['inStock'] == null ? true : data['inStock'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'discountPercent': discountPercent,
      'category': category,
      'brandId': brandId,
      'brandName': brandName,
      'imageUrl': imageUrl,
      'images': images,
      'isSuggested': isSuggested,
      'inStock': inStock,
    };
  }

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll('\$', '').trim();
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  static int _parseDiscount(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      final cleaned = value.replaceAll('%', '').trim();
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }
}

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 10;

  @override
  ProductModel read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final price = reader.readDouble();
    final discountPercent = reader.readInt();
    final category = reader.readString();
    final brandId = reader.readString();
    final brandName = reader.readString();
    final imageUrl = reader.readString();
    final images = reader.readList().cast<String>();
    final isSuggested = reader.readBool();
    final inStock = reader.readBool();

    return ProductModel(
      id: id,
      name: name,
      price: price,
      discountPercent: discountPercent,
      category: category,
      brandId: brandId,
      brandName: brandName,
      imageUrl: imageUrl,
      images: images,
      isSuggested: isSuggested,
      inStock: inStock,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeDouble(obj.price);
    writer.writeInt(obj.discountPercent);
    writer.writeString(obj.category);
    writer.writeString(obj.brandId);
    writer.writeString(obj.brandName);
    writer.writeString(obj.imageUrl);
    writer.writeList(obj.images);
    writer.writeBool(obj.isSuggested);
    writer.writeBool(obj.inStock);
  }
}
