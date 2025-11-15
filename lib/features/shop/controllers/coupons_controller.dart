import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CouponsController extends GetxController {
  static CouponsController get instance => Get.find();

  // Observable coupons list
  final RxList<Map<String, dynamic>> coupons = <Map<String, dynamic>>[].obs;

  // Loading state
  final isLoading = false.obs;

  // Filter
  final selectedFilter = 'Active'.obs;
  final filterOptions = ['Active', 'Used', 'Expired'];

  @override
  void onInit() {
    super.onInit();
    loadSampleData();
  }

  // Get filtered coupons
  List<Map<String, dynamic>> get filteredCoupons {
    return coupons
        .where((coupon) => coupon['status'] == selectedFilter.value)
        .toList();
  }

  // Get coupon count by status
  int getCouponCountByStatus(String status) {
    return coupons.where((coupon) => coupon['status'] == status).length;
  }

  // Change filter
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Apply coupon
  void applyCoupon(Map<String, dynamic> coupon) {
    if (coupon['status'] != 'Active') {
      Get.snackbar(
        'Cannot Apply',
        'This coupon is not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Coupon Applied',
      'Code "${coupon['code']}" applied successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    // Navigate to cart or checkout with coupon applied
    // Get.toNamed('/cart', arguments: {'coupon': coupon});
  }

  // Copy coupon code
  void copyCouponCode(String code) {
    // In production: Use Clipboard.setData()
    Get.snackbar(
      'Copied',
      'Coupon code "$code" copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // View coupon details
  void viewCouponDetails(Map<String, dynamic> coupon) {
    Get.dialog(
      AlertDialog(
        title: Text(coupon['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Code', coupon['code']),
            const SizedBox(height: 8),
            _buildDetailRow('Discount', coupon['discount']),
            const SizedBox(height: 8),
            _buildDetailRow('Type', coupon['type']),
            const SizedBox(height: 8),
            _buildDetailRow('Valid Until', coupon['expiryDate']),
            const SizedBox(height: 8),
            _buildDetailRow('Status', coupon['status']),
            const SizedBox(height: 12),
            Text(
              'Terms & Conditions:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(coupon['terms']),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          if (coupon['status'] == 'Active')
            ElevatedButton(
              onPressed: () {
                Get.back();
                applyCoupon(coupon);
              },
              child: const Text('Apply Coupon'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  // Check if coupon is expiring soon (within 7 days)
  bool isExpiringSoon(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      final now = DateTime.now();
      final difference = expiry.difference(now).inDays;
      return difference <= 7 && difference > 0;
    } catch (e) {
      return false;
    }
  }

  // Get coupon discount value
  String getCouponValue(Map<String, dynamic> coupon) {
    if (coupon['type'] == 'Percentage') {
      return '${coupon['value']}% OFF';
    } else {
      return '\$${coupon['value']} OFF';
    }
  }

  // Load sample data
  void loadSampleData() {
    if (coupons.isEmpty) {
      coupons.addAll([
        {
          'id': '1',
          'code': 'WELCOME50',
          'title': 'Welcome Discount',
          'description': 'Get 50% off on your first purchase',
          'discount': '50% Off',
          'type': 'Percentage',
          'value': 50,
          'minPurchase': 100.0,
          'maxDiscount': 50.0,
          'status': 'Active',
          'expiryDate': '2024-12-31',
          'terms':
              'Valid on minimum purchase of \$100. Maximum discount \$50. Cannot be combined with other offers.',
        },
        {
          'id': '2',
          'code': 'SAVE20',
          'title': 'Save \$20',
          'description': 'Flat \$20 discount on orders above \$150',
          'discount': '\$20 Off',
          'type': 'Fixed',
          'value': 20,
          'minPurchase': 150.0,
          'maxDiscount': 20.0,
          'status': 'Active',
          'expiryDate': '2024-12-15',
          'terms': 'Valid on minimum purchase of \$150. One time use only.',
        },
        {
          'id': '3',
          'code': 'FREESHIP',
          'title': 'Free Shipping',
          'description': 'Get free shipping on all orders',
          'discount': 'Free Shipping',
          'type': 'Shipping',
          'value': 0,
          'minPurchase': 50.0,
          'maxDiscount': 50.0,
          'status': 'Active',
          'expiryDate': '2024-11-30',
          'terms':
              'Valid on minimum purchase of \$50. Applicable on standard shipping only.',
        },
        {
          'id': '4',
          'code': 'SUMMER30',
          'title': 'Summer Sale',
          'description': '30% off on summer collection',
          'discount': '30% Off',
          'type': 'Percentage',
          'value': 30,
          'minPurchase': 80.0,
          'maxDiscount': 100.0,
          'status': 'Used',
          'expiryDate': '2024-11-01',
          'usedDate': '2024-10-25',
          'terms': 'Valid on summer collection only. Minimum purchase \$80.',
        },
        {
          'id': '5',
          'code': 'FLASH50',
          'title': 'Flash Sale',
          'description': '50% instant discount',
          'discount': '50% Off',
          'type': 'Percentage',
          'value': 50,
          'minPurchase': 200.0,
          'maxDiscount': 150.0,
          'status': 'Expired',
          'expiryDate': '2024-10-31',
          'terms': 'Valid for 24 hours only. Minimum purchase \$200.',
        },
      ]);
    }
  }

  // Firebase methods (commented for now)

  // Future<void> loadCouponsFromFirebase(String userId) async {
  //   try {
  //     isLoading.value = true;
  //
  //     // Load user's coupons
  //     final userCoupons = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('coupons')
  //         .get();
  //
  //     // Load available coupons
  //     final availableCoupons = await FirebaseFirestore.instance
  //         .collection('coupons')
  //         .where('isActive', isEqualTo: true)
  //         .where('expiryDate', isGreaterThan: DateTime.now())
  //         .get();
  //
  //     coupons.value = [
  //       ...userCoupons.docs.map((doc) => {...doc.data(), 'id': doc.id}),
  //       ...availableCoupons.docs.map((doc) => {...doc.data(), 'id': doc.id}),
  //     ];
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to load coupons');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<bool> validateCoupon(String code, double cartTotal) async {
  //   try {
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('coupons')
  //         .where('code', isEqualTo: code)
  //         .where('isActive', isEqualTo: true)
  //         .limit(1)
  //         .get();
  //
  //     if (snapshot.docs.isEmpty) {
  //       Get.snackbar('Invalid', 'Coupon code not found');
  //       return false;
  //     }
  //
  //     final coupon = snapshot.docs.first.data();
  //     final minPurchase = coupon['minPurchase'] ?? 0.0;
  //
  //     if (cartTotal < minPurchase) {
  //       Get.snackbar('Invalid', 'Minimum purchase of \$$minPurchase required');
  //       return false;
  //     }
  //
  //     return true;
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to validate coupon');
  //     return false;
  //   }
  // }
}
