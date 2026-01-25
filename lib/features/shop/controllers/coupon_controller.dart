import 'package:ecommerce_app/data/repositories/coupon_repository.dart';
import 'package:ecommerce_app/features/shop/models/coupon_model.dart';
import 'package:get/get.dart';

class CouponController extends GetxController {
  static CouponController get instance => Get.find();

  final _couponRepository = Get.put(CouponRepository());
  final RxList<CouponModel> coupons = <CouponModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    fetchCoupons();
    super.onInit();
  }

  Future<void> fetchCoupons() async {
    try {
      isLoading.value = true;
      final fetchedCoupons = await _couponRepository.getAllCoupons();
      coupons.assignAll(fetchedCoupons);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
