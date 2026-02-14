import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/services/admin_audit_logger.dart';
import 'package:ecommerce_app/features/shop/models/brand_model.dart';
import 'package:get/get.dart';

class AdminBrandsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<BrandModel> brands = <BrandModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBrands();
  }

  Future<void> loadBrands() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final snapshot = await _db.collection('brands').get();
      final rows =
          snapshot.docs.map((e) => BrandModel.fromSnapshot(e)).toList()..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
      brands.assignAll(rows);
    } catch (e) {
      brands.clear();
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBrand({
    required String name,
    required String category,
    required String logoUrl,
    required bool verified,
    required bool isFeatured,
  }) async {
    final ref = await _db.collection('brands').add({
      'name': name,
      'category': category,
      'logoUrl': logoUrl,
      'verified': verified,
      'isFeatured': isFeatured,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'brand_created',
      resourceType: 'brand',
      resourceId: ref.id,
      details: {'name': name, 'isFeatured': isFeatured},
    );
    await loadBrands();
  }

  Future<void> updateBrand(
    String id, {
    required String name,
    required String category,
    required String logoUrl,
    required bool verified,
    required bool isFeatured,
  }) async {
    await _db.collection('brands').doc(id).update({
      'name': name,
      'category': category,
      'logoUrl': logoUrl,
      'verified': verified,
      'isFeatured': isFeatured,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'brand_updated',
      resourceType: 'brand',
      resourceId: id,
      details: {'name': name, 'isFeatured': isFeatured},
    );
    await loadBrands();
  }

  Future<void> deleteBrand(String id) async {
    await _db.collection('brands').doc(id).delete();
    await AdminAuditLogger.log(
      action: 'brand_deleted',
      resourceType: 'brand',
      resourceId: id,
    );
    await loadBrands();
  }
}
