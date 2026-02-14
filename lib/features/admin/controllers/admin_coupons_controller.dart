import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/services/admin_audit_logger.dart';
import 'package:ecommerce_app/features/shop/models/coupon_model.dart';
import 'package:get/get.dart';

class AdminCouponsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<CouponModel> coupons = <CouponModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final snapshot = await _db.collection('coupons').get();
      final rows =
          snapshot.docs.map((e) => CouponModel.fromSnapshot(e)).toList()..sort(
            (a, b) => a.code.toLowerCase().compareTo(b.code.toLowerCase()),
          );
      coupons.assignAll(rows);
    } catch (e) {
      coupons.clear();
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCoupon({
    required String code,
    required String type,
    required double value,
    DateTime? expiryDate,
    required bool isActive,
  }) async {
    final ref = await _db.collection('coupons').add({
      'Code': code,
      'Type': type,
      'Value': value,
      'ExpiryDate': expiryDate == null ? null : Timestamp.fromDate(expiryDate),
      'IsActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'coupon_created',
      resourceType: 'coupon',
      resourceId: ref.id,
      details: {'code': code, 'type': type},
    );
    await loadCoupons();
  }

  Future<void> updateCoupon(
    String id, {
    required String code,
    required String type,
    required double value,
    DateTime? expiryDate,
    required bool isActive,
  }) async {
    await _db.collection('coupons').doc(id).update({
      'Code': code,
      'Type': type,
      'Value': value,
      'ExpiryDate': expiryDate == null ? null : Timestamp.fromDate(expiryDate),
      'IsActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'coupon_updated',
      resourceType: 'coupon',
      resourceId: id,
      details: {'code': code, 'type': type},
    );
    await loadCoupons();
  }

  Future<void> deleteCoupon(String id) async {
    await _db.collection('coupons').doc(id).delete();
    await AdminAuditLogger.log(
      action: 'coupon_deleted',
      resourceType: 'coupon',
      resourceId: id,
    );
    await loadCoupons();
  }
}
