import 'package:ecommerce_app/features/shop/controllers/coupon_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupons'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.coupons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.ticket,
                  size: 100,
                  color: Colors.grey.withOpacity(0.3),
                ),
                const SizedBox(height: BSizes.spaceBetweenItems),
                const Text('No Coupons Available'),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(BSizes.paddingMd),
          itemCount: controller.coupons.length,
          separatorBuilder:
              (_, __) => const SizedBox(height: BSizes.spaceBetweenItems),
          itemBuilder: (_, index) {
            final coupon = controller.coupons[index];
            return Container(
              padding: const EdgeInsets.all(BSizes.paddingMd),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(BSizes.cardRadius),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.ticket_discount,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: BSizes.spaceBetweenItems),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.code.toUpperCase(),
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coupon.type == 'percentage'
                              ? '${coupon.value}% OFF'
                              : '\$${coupon.value} OFF',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (coupon.expiryDate != null)
                          Text(
                            'Expires: ${coupon.expiryDate.toString().split(' ')[0]}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),

                  // Copy Button
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: coupon.code));
                      Get.snackbar(
                        'Success',
                        'Coupon code copied to clipboard',
                      );
                    },
                    icon: const Icon(Iconsax.copy),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
