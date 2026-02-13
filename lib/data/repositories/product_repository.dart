import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/shop/models/brand_model.dart';
import 'package:ecommerce_app/features/shop/models/product_model.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Box<ProductModel> get _productsBox => Hive.box<ProductModel>('products_box');
  Box get _metaBox => Hive.box('products_meta');

  Future<List<ProductModel>> fetchAllProducts({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = _loadCachedProducts();
        if (cached.isNotEmpty) return cached;
      }

      final snapshot = await _db.collection('products').get();
      final products =
          snapshot.docs
              .map((documentSnapshot) => ProductModel.fromSnapshot(documentSnapshot))
              .toList();
      await _cacheProducts(products);
      return products;
    } catch (e) {
      throw 'Something went wrong while fetching Products. Try again later';
    }
  }

  Future<List<ProductModel>> fetchProductsByBrand(
    String brandId, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cached = _loadCachedProducts();
        if (cached.isNotEmpty) {
          return cached.where((p) => p.brandId == brandId).toList();
        }
      }

      final snapshot =
          await _db
              .collection('products')
              .where('brandId', isEqualTo: brandId)
              .get();
      final products =
          snapshot.docs
              .map((documentSnapshot) => ProductModel.fromSnapshot(documentSnapshot))
              .toList();
      await _cacheProducts(products, merge: true);
      return products;
    } catch (e) {
      throw 'Something went wrong while fetching Brand Products. Try again later';
    }
  }

  Future<List<ProductModel>> fetchSuggestedProducts({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cached = _loadCachedProducts();
        if (cached.isNotEmpty) {
          return cached.where((p) => p.isSuggested).toList();
        }
      }

      final snapshot =
          await _db
              .collection('products')
              .where('isSuggested', isEqualTo: true)
              .get();
      final products =
          snapshot.docs
              .map((documentSnapshot) => ProductModel.fromSnapshot(documentSnapshot))
              .toList();
      await _cacheProducts(products, merge: true);
      return products;
    } catch (e) {
      throw 'Something went wrong while fetching Suggested Products. Try again later';
    }
  }

  Future<List<BrandModel>> fetchBrands() async {
    try {
      final snapshot = await _db.collection('brands').get();
      return snapshot.docs
          .map((documentSnapshot) => BrandModel.fromSnapshot(documentSnapshot))
          .toList();
    } catch (e) {
      throw 'Something went wrong while fetching Brands. Try again later';
    }
  }

  List<ProductModel> _loadCachedProducts() {
    final ids = _metaBox.get('all_product_ids');
    if (ids is! List) return [];

    final products = <ProductModel>[];
    for (final id in ids) {
      final product = _productsBox.get(id.toString());
      if (product != null) {
        products.add(product);
      }
    }
    return products;
  }

  Future<void> _cacheProducts(
    List<ProductModel> products, {
    bool merge = false,
  }) async {
    final ids = <String>[];

    if (merge) {
      final existing = _metaBox.get('all_product_ids');
      if (existing is List) {
        ids.addAll(existing.map((e) => e.toString()));
      }
    }

    for (final product in products) {
      await _productsBox.put(product.id, product);
      if (!ids.contains(product.id)) {
        ids.add(product.id);
      }
    }

    await _metaBox.put('all_product_ids', ids);
    await _metaBox.put('last_sync', DateTime.now().toIso8601String());
  }
}
