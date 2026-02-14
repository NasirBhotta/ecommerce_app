import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/services/admin_audit_logger.dart';
import 'package:ecommerce_app/features/shop/models/product_model.dart';
import 'package:get/get.dart';

class AdminProductsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final snapshot = await _db.collection('products').get();
      final rows =
          snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
      rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      products.assignAll(rows);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct({
    required String name,
    required double price,
    required int discountPercent,
    required String category,
    required String brandId,
    required String brandName,
    required String imageUrl,
    required bool isSuggested,
    required bool inStock,
  }) async {
    final ref = await _db.collection('products').add({
      'name': name,
      'price': price,
      'discountPercent': discountPercent,
      'category': category,
      'brandId': brandId,
      'brandName': brandName,
      'imageUrl': imageUrl,
      'images': imageUrl.isEmpty ? <String>[] : [imageUrl],
      'isSuggested': isSuggested,
      'inStock': inStock,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'product_created',
      resourceType: 'product',
      resourceId: ref.id,
      details: {'name': name, 'price': price},
    );
    await loadProducts();
  }

  Future<void> updateProduct(
    String id, {
    required String name,
    required double price,
    required int discountPercent,
    required String category,
    required String brandId,
    required String brandName,
    required String imageUrl,
    required bool isSuggested,
    required bool inStock,
  }) async {
    await _db.collection('products').doc(id).update({
      'name': name,
      'price': price,
      'discountPercent': discountPercent,
      'category': category,
      'brandId': brandId,
      'brandName': brandName,
      'imageUrl': imageUrl,
      'images': imageUrl.isEmpty ? <String>[] : [imageUrl],
      'isSuggested': isSuggested,
      'inStock': inStock,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'product_updated',
      resourceType: 'product',
      resourceId: id,
      details: {'name': name, 'price': price},
    );
    await loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
    await AdminAuditLogger.log(
      action: 'product_deleted',
      resourceType: 'product',
      resourceId: id,
    );
    await loadProducts();
  }
}
