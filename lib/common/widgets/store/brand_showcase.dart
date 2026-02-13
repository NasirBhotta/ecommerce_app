import 'package:ecommerce_app/common/widgets/store/brand_card.dart';
import 'package:ecommerce_app/common/widgets/store/product_image.dart';
import 'package:ecommerce_app/features/shop/models/product_model.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BBrandShowcase extends StatelessWidget {
  const BBrandShowcase({
    super.key,
    required this.brandName,
    required this.productCount,
    required this.products,
    this.verified = false,
    this.onBrandTap,
  });

  final String brandName;
  final int productCount;
  final List<ProductModel> products;
  final bool verified;
  final VoidCallback? onBrandTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: BSizes.spaceBetweenItems),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BSizes.cardRadius),
        border: Border.all(
          color:
              isDark
                  ? BColors.white.withValues(alpha: 0.2)
                  : BColors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Brand Header
          BBrandCard(
            brandName: brandName,
            productCount: productCount,
            verified: verified,
            onTap: onBrandTap,
            showBorder: false,
          ),
          // Product Grid (3 products)
          Padding(
            padding: const EdgeInsets.all(BSizes.paddingSm),
            child: Row(
              children: List.generate(
                products.length > 3 ? 3 : products.length,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < 2 ? BSizes.paddingSm : 0,
                    ),
                    child: BProductImageCard(
                      imageUrl: products[index].imageUrl,
                      discount: products[index].discountLabel,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
