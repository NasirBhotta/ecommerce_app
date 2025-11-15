import 'package:ecommerce_app/features/shop/controllers/orders_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? BColors.black : BColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Orders',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: BSizes.paddingMd),
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.filterOptions.length,
                itemBuilder: (_, index) {
                  final filter = controller.filterOptions[index];
                  final isSelected = controller.selectedFilter.value == filter;
                  final count = controller.getOrderCountByStatus(filter);

                  return Padding(
                    padding: const EdgeInsets.only(right: BSizes.paddingSm),
                    child: FilterChip(
                      label: Text('$filter ($count)'),
                      selected: isSelected,
                      onSelected: (_) => controller.changeFilter(filter),
                      backgroundColor:
                          isDark
                              ? BColors.grey.withOpacity(0.1)
                              : BColors.grey.withOpacity(0.05),
                      selectedColor: BColors.primary.withOpacity(0.2),
                      checkmarkColor: BColors.primary,
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? BColors.primary
                                : (isDark ? BColors.white : BColors.black),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: Obx(() {
              final orders = controller.filteredOrders;

              if (orders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(BSizes.paddingLg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.box,
                          size: 100,
                          color:
                              isDark
                                  ? BColors.white.withOpacity(0.2)
                                  : BColors.grey.withOpacity(0.4),
                        ),
                        const SizedBox(height: BSizes.spaceBetweenSections),
                        Text(
                          'No Orders Found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: BSizes.spaceBetweenItems),
                        Text(
                          'You haven\'t placed any orders yet',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                isDark
                                    ? BColors.white.withOpacity(0.6)
                                    : BColors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(BSizes.paddingMd),
                itemCount: orders.length,
                itemBuilder: (_, index) {
                  final order = orders[index];
                  return _OrderCard(order: order, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.controller});

  final Map<String, dynamic> order;
  final OrdersController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = order['status'] as String;
    final statusColor = Color(int.parse(controller.getStatusColor(status)));

    return Container(
      margin: const EdgeInsets.only(bottom: BSizes.spaceBetweenItems),
      decoration: BoxDecoration(
        color:
            isDark
                ? BColors.grey.withOpacity(0.1)
                : BColors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(BSizes.cardRadius),
        border: Border.all(
          color:
              isDark
                  ? BColors.white.withOpacity(0.1)
                  : BColors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Order Header
          Container(
            padding: const EdgeInsets.all(BSizes.paddingMd),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(BSizes.cardRadius),
                topRight: Radius.circular(BSizes.cardRadius),
              ),
            ),
            child: Row(
              children: [
                Icon(Iconsax.box, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  order['orderId'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: BColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order Details
          Padding(
            padding: const EdgeInsets.all(BSizes.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.calendar, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Date: ${order['date']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      order['total'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: BColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Iconsax.location, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${order['shippingAddress']['city']}, ${order['shippingAddress']['country']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Iconsax.wallet, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      order['paymentMethod'],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => controller.viewOrderDetails(order),
                        child: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (status == 'Processing' || status == 'Shipped')
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              () => controller.trackOrder(order['orderId']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BColors.primary,
                          ),
                          child: const Text('Track'),
                        ),
                      ),
                    if (status == 'Processing')
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              () => controller.cancelOrder(order['orderId']),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
