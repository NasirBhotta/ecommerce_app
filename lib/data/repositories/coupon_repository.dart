import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/shop/models/coupon_model.dart';
import 'package:get/get.dart';

class CouponRepository extends GetxController {
  static CouponRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<CouponModel>> getAllCoupons() async {
    try {
      // Fetch active coupons
      final result =
          await _db
              .collection('coupons')
              .where('IsActive', isEqualTo: true)
              .get();
      return result.docs
          .map((documentSnapshot) => CouponModel.fromSnapshot(documentSnapshot))
          .toList();
    } catch (e) {
      throw 'Something went wrong while fetching coupons.';
    }
  }
}
