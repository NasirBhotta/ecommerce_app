import 'package:ecommerce_app/features/shop/controllers/cart_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';

import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // // Load sample data
    // controller.loadSampleData();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? BColors.black : BColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            'Cart (${controller.cartCount})',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        actions: [
          Obx(
            () =>
                controller.cartItems.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Iconsax.trash),
                      onPressed: controller.clearCart,
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(BSizes.paddingLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.shopping_cart,
                    size: 100,
                    color:
                        isDark
                            ? BColors.white.withValues(alpha: 0.2)
                            : BColors.grey.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: BSizes.spaceBetweenSections),
                  Text(
                    'Your Cart is Empty',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: BSizes.spaceBetweenItems),
                  Text(
                    'Add items to your cart to see them here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isDark
                              ? BColors.white.withValues(alpha: 0.6)
                              : BColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: BSizes.spaceBetweenSections),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Start Shopping'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Cart Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(BSizes.paddingMd),
                itemCount: controller.cartItems.length,
                itemBuilder: (_, index) {
                  final item = controller.cartItems[index];
                  return _CartItemCard(
                    item: item,
                    onIncrease: () => controller.increaseQuantity(item['id']),
                    onDecrease: () => controller.decreaseQuantity(item['id']),
                    onRemove: () => controller.removeFromCart(item['id']),
                  );
                },
              ),
            ),

            // Bottom Summary
            Container(
              padding: const EdgeInsets.all(BSizes.paddingLg),
              decoration: BoxDecoration(
                color: isDark ? BColors.black : BColors.white,
                boxShadow: [
                  BoxShadow(
                    color: BColors.grey.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Subtotal
                    _SummaryRow(
                      label: 'Subtotal',
                      value: '\$${controller.subtotal.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: BSizes.paddingSm),
                    // Tax
                    _SummaryRow(
                      label: 'Tax (10%)',
                      value: '\$${controller.tax.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: BSizes.paddingSm),
                    // Shipping
                    _SummaryRow(
                      label: 'Shipping',
                      value: '\$${controller.shipping.toStringAsFixed(2)}',
                    ),
                    const Divider(height: 24),
                    // Total
                    _SummaryRow(
                      label: 'Total',
                      value: '\$${controller.total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                    const SizedBox(height: BSizes.spaceBetweenItems),
                    // Checkout Button
                    ElevatedButton(
                      onPressed: controller.proceedToCheckout,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final Map<String, dynamic> item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: BSizes.spaceBetweenItems),
      padding: const EdgeInsets.all(BSizes.paddingMd),
      decoration: BoxDecoration(
        color:
            isDark
                ? BColors.grey.withValues(alpha: 0.1)
                : BColors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(BSizes.cardRadius),
        border: Border.all(
          color:
              isDark
                  ? BColors.white.withValues(alpha: 0.1)
                  : BColors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: BColors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(BSizes.paddingMd),
            ),
            child: Icon(
              Icons.image,
              size: 40,
              color: BColors.grey.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: BSizes.paddingMd),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['brand']} • ${item['size']} • ${item['color']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isDark
                            ? BColors.white.withValues(alpha: 0.6)
                            : BColors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      item['price'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: BColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: BColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: onDecrease,
                            color: BColors.primary,
                          ),
                          Text(
                            '${item['quantity']}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: onIncrease,
                            color: BColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Iconsax.trash),
            color: Colors.red,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              isTotal
                  ? Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                  : Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style:
              isTotal
                  ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: BColors.primary,
                  )
                  : Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
