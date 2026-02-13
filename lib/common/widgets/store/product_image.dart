import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BProductImageCard extends StatelessWidget {
  const BProductImageCard({
    super.key,
    this.imageUrl,
    this.discount,
    this.onTap,
  });

  final String? imageUrl;
  final String? discount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BSizes.paddingMd),
          color:
              isDark
                  ? BColors.grey.withValues(alpha: 0.1)
                  : BColors.grey.withValues(alpha: 0.1),
        ),
        child: Stack(
          children: [
            Center(child: _buildImage()),
            // Discount Badge
            if (discount != null)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    discount!,
                    style: Theme.of(context).textTheme.labelSmall!.apply(
                      color: BColors.black,
                      fontWeightDelta: 2,
                      fontSizeFactor: 0.8,
                    ),
                  ),
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
        size: 40,
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
              size: 40,
              color: BColors.grey.withValues(alpha: 0.5),
            ),
      );
    }

    return Image.asset(imageUrl!, fit: BoxFit.contain);
  }
}
