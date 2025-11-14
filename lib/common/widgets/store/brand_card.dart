import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BBrandCard extends StatelessWidget {
  const BBrandCard({
    super.key,
    required this.brandName,
    required this.productCount,
    this.verified = false,
    this.onTap,
    this.showBorder = true,
  });

  final String brandName;
  final int productCount;
  final bool verified;
  final VoidCallback? onTap;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(BSizes.paddingMd),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BSizes.borderRadius),
          border:
              showBorder
                  ? Border.all(
                    color:
                        isDark
                            ? BColors.white.withOpacity(0.2)
                            : BColors.grey.withOpacity(0.3),
                  )
                  : null,
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            // Brand Logo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    isDark
                        ? BColors.white.withOpacity(0.1)
                        : BColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Icon(
                  Icons.business,
                  color: isDark ? BColors.white : BColors.black,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: BSizes.paddingSm),
            // Brand Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          brandName,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (verified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: BColors.primary,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '$productCount products',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          isDark
                              ? BColors.white.withOpacity(0.6)
                              : BColors.grey,
                    ),
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
