import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/services/admin_audit_logger.dart';
import 'package:ecommerce_app/features/shop/models/brand_model.dart';
import 'package:ecommerce_app/features/shop/models/product_model.dart';
import 'package:get/get.dart';

class AdminMerchandisingController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<BrandModel> allBrands = <BrandModel>[].obs;
  final RxSet<String> featuredBrandIds = <String>{}.obs;
  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> banners =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final productsSnapshot = await _db.collection('products').get();
      allProducts.assignAll(
        productsSnapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          ),
      );

      final brandsSnapshot = await _db.collection('brands').get();
      final featuredIds = <String>{};
      allBrands.assignAll(
        brandsSnapshot.docs.map((e) {
            if (e.data()['isFeatured'] == true) {
              featuredIds.add(e.id);
            }
            return BrandModel.fromSnapshot(e);
          }).toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          ),
      );
      featuredBrandIds.assignAll(featuredIds);

      final bannersSnapshot =
          await _db.collection('merchandising_banners').get();
      final bannerDocs =
          bannersSnapshot.docs.toList()..sort((a, b) {
            final ao = (a.data()['order'] ?? 0) as num;
            final bo = (b.data()['order'] ?? 0) as num;
            return ao.compareTo(bo);
          });
      banners.assignAll(bannerDocs);
    } catch (e) {
      errorMessage.value = e.toString();
      allProducts.clear();
      allBrands.clear();
      featuredBrandIds.clear();
      banners.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleSuggestedProduct(ProductModel product, bool value) async {
    await _db.collection('products').doc(product.id).update({
      'isSuggested': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'merch_suggested_toggled',
      resourceType: 'product',
      resourceId: product.id,
      details: {'isSuggested': value},
    );
    await loadData();
  }

  Future<void> toggleFeaturedBrand(BrandModel brand, bool value) async {
    await _db.collection('brands').doc(brand.id).update({
      'isFeatured': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'merch_featured_brand_toggled',
      resourceType: 'brand',
      resourceId: brand.id,
      details: {'isFeatured': value},
    );
    await loadData();
  }

  Future<void> addBanner({
    required String title,
    required String subtitle,
    required String imageUrl,
    required int order,
    required bool isActive,
  }) async {
    final ref = await _db.collection('merchandising_banners').add({
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'order': order,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'banner_created',
      resourceType: 'merchandising_banner',
      resourceId: ref.id,
      details: {'title': title, 'order': order},
    );
    await loadData();
  }

  Future<void> updateBanner(
    String id, {
    required String title,
    required String subtitle,
    required String imageUrl,
    required int order,
    required bool isActive,
  }) async {
    await _db.collection('merchandising_banners').doc(id).update({
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'order': order,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'banner_updated',
      resourceType: 'merchandising_banner',
      resourceId: id,
      details: {'title': title, 'order': order},
    );
    await loadData();
  }

  Future<void> deleteBanner(String id) async {
    await _db.collection('merchandising_banners').doc(id).delete();
    await AdminAuditLogger.log(
      action: 'banner_deleted',
      resourceType: 'merchandising_banner',
      resourceId: id,
    );
    await loadData();
  }
}
