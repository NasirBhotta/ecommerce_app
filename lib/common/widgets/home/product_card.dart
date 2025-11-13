// ============ PRODUCT CARD VERTICAL ============
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BProductCardVertical extends StatelessWidget {
  const BProductCardVertical({
    super.key,
    required this.productName,
    required this.price,
    this.discount,
    this.imageUrl,
    this.onTap,
    this.onFavoriteTap,
  });

  final String productName;
  final String price;
  final String? discount;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
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
              color: BColors.grey.withOpacity(0.1),
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
                        ? BColors.grey.withOpacity(0.1)
                        : BColors.grey.withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  // Product Image
                  Center(
                    child: Icon(
                      Icons.image,
                      size: 80,
                      color: BColors.grey.withOpacity(0.5),
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
                                ? BColors.black.withOpacity(0.7)
                                : BColors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border),
                        iconSize: 20,
                        color: isDark ? BColors.white : BColors.black,
                        onPressed: onFavoriteTap ?? () {},
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
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: Theme.of(context).textTheme.titleMedium!.apply(
                      color: BColors.primary,
                      fontWeightDelta: 2,
                    ),
                    overflow: TextOverflow.ellipsis,
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
