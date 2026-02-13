import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BProductCardHorizontal extends StatelessWidget {
  const BProductCardHorizontal({
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
        margin: const EdgeInsets.only(right: BSizes.spaceBetweenItems),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BSizes.cardRadius),
          color: isDark ? BColors.black : BColors.white,
          border: Border.all(
            color:
                isDark
                    ? BColors.white.withValues(alpha: 0.1)
                    : BColors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(BSizes.cardRadius),
                  topRight: Radius.circular(BSizes.cardRadius),
                ),
                color:
                    isDark
                        ? BColors.grey.withValues(alpha: 0.1)
                        : BColors.grey.withValues(alpha: 0.1),
              ),
              child: Stack(
                children: [
                  // Product Image
                  Center(child: _buildImage()),
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
                        onPressed: onFavoriteTap ?? () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(BSizes.paddingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: Theme.of(context).textTheme.titleSmall!.apply(
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

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Icon(
        Icons.image,
        size: 60,
        color: BColors.grey.withValues(alpha: 0.5),
      );
    }

    if (imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder:
            (_, __, ___) => Icon(
              Icons.broken_image,
              size: 60,
              color: BColors.grey.withValues(alpha: 0.5),
            ),
      );
    }

    return Image.asset(imageUrl!, fit: BoxFit.contain);
  }
}
