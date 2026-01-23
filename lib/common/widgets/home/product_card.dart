import 'package:ecommerce_app/features/shop/controllers/cart_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BProductCardVertical extends StatelessWidget {
  const BProductCardVertical({
    super.key,
    required this.productId,
    required this.productName,
    required this.price,
    this.discount,
    this.imageUrl,
    this.onTap,
    this.onFavoriteTap,
  });

  final String productId;
  final String productName;
  final String price;
  final String? discount;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BSizes.cardRadius),
          color: isDark ? BColors.black : BColors.white,
          boxShadow: [
            BoxShadow(
              color: BColors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Discount Badge
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BSizes.cardRadius),
                color:
                    isDark
                        ? BColors.grey.withValues(alpha: 0.1)
                        : BColors.grey.withValues(alpha: 0.1),
              ),
              child: Stack(
                children: [
                  // Product Image
                  Center(
                    child: Icon(
                      Icons.image,
                      size: 80,
                      color: BColors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                  // Discount Badge
                  if (discount != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BSizes.paddingSm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade700,
                          borderRadius: BorderRadius.circular(BSizes.paddingSm),
                        ),
                        child: Text(
                          discount!,
                          style: Theme.of(context).textTheme.labelSmall!.apply(
                            color: BColors.black,
                            fontWeightDelta: 2,
                          ),
                        ),
                      ),
                    ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? BColors.black.withValues(alpha: 0.7)
                                : BColors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border),
                        iconSize: 20,
                        color: isDark ? BColors.white : BColors.black,
                        onPressed: onFavoriteTap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BSizes.spaceBetweenItems / 2),
            // Product Details
            Padding(
              padding: const EdgeInsets.only(left: BSizes.paddingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  // Brand with verification
                  Row(
                    children: [
                      Text(
                        'Nike',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall!.apply(color: BColors.grey),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 12,
                        color: BColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Price and Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: Theme.of(context).textTheme.titleMedium!.apply(
                          color: BColors.primary,
                          fontWeightDelta: 2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Quantity Selector
                      Obx(() {
                        final quantity = controller.getProductQuantity(
                          productId,
                        );
                        return Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                quantity > 0
                                    ? BColors.primary
                                    : (isDark
                                        ? BColors.grey.withValues(alpha: 0.3)
                                        : BColors.black),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child:
                              quantity > 0
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap:
                                            () => controller.decreaseQuantity(
                                              productId,
                                            ),
                                        child: SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: const Icon(
                                            Icons.remove,
                                            color: BColors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          '$quantity',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelMedium!.apply(
                                            color: BColors.white,
                                            fontWeightDelta: 2,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap:
                                            () => controller.increaseQuantity(
                                              productId,
                                            ),
                                        child: SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: const Icon(
                                            Icons.add,
                                            color: BColors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : InkWell(
                                    // Add to Cart
                                    onTap: () {
                                      controller.addToCart({
                                        'id': productId,
                                        'name': productName,
                                        'price': price,
                                        'image': imageUrl,
                                        'brand': 'Nike', // Hardcoded for demo
                                        'size': 'M', // Default
                                        'color': 'Default',
                                        'quantity': 1,
                                      });
                                    },
                                    child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: const Icon(
                                        Icons.add,
                                        color: BColors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
