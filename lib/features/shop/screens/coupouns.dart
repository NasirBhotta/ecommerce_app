import 'package:ecommerce_app/features/shop/controllers/coupons_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CouponsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? BColors.black : BColors.white,
        title: const Text('My Coupons'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: BSizes.paddingMd),
            child: Obx(
              () => Row(
                children:
                    controller.filterOptions.map((filter) {
                      final isSelected =
                          controller.selectedFilter.value == filter;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.changeFilter(filter),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      isSelected
                                          ? BColors.primary
                                          : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              '$filter (${controller.getCouponCountByStatus(filter)})',
                              style: TextStyle(
                                color:
                                    isSelected ? BColors.primary : BColors.grey,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),

          // Coupons List
          Expanded(
            child: Obx(() {
              final coupons = controller.filteredCoupons;

              if (coupons.isEmpty) {
                return const Center(child: Text('No coupons available'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(BSizes.paddingMd),
                itemCount: coupons.length,
                itemBuilder: (_, index) {
                  final coupon = coupons[index];
                  return _CouponCard(coupon: coupon, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon, required this.controller});

  final Map<String, dynamic> coupon;
  final CouponsController controller;

  @override
  Widget build(BuildContext context) {
    final isActive = coupon['status'] == 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: BSizes.spaceBetweenItems),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BSizes.cardRadius),
        gradient: LinearGradient(
          colors:
              isActive
                  ? [BColors.primary, BColors.primary.withOpacity(0.7)]
                  : [BColors.grey, BColors.grey.withOpacity(0.5)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(BSizes.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    coupon['title'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: BColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  coupon['discount'],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: BColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              coupon['description'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BColors.white.withOpacity(0.9),
              ),
            ),
            const Divider(color: BColors.white, height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      coupon['code'],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: BColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => controller.copyCouponCode(coupon['code']),
                  icon: const Icon(Iconsax.copy, color: BColors.white),
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => controller.applyCoupon(coupon),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BColors.white,
                  foregroundColor: BColors.primary,
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('Apply Coupon'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
