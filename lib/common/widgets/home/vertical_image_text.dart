import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BVerticalImageText extends StatelessWidget {
  const BVerticalImageText({
    super.key,
    required this.image,
    required this.title,
    this.textColor = BColors.white,
    this.backgroundColor,
    this.onTap,
    this.isNetworkImage = false,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final bool isNetworkImage;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: BSizes.spaceBetweenItems),
        child: Column(
          children: [
            // Circular Icon
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(BSizes.paddingSm),
              decoration: BoxDecoration(
                color:
                    backgroundColor ?? (isDark ? BColors.black : BColors.white),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Icon(
                  Icons.sports_baseball,
                  color: isDark ? BColors.white : BColors.primary,
                ),
              ),
            ),
            const SizedBox(height: BSizes.spaceBetweenItems / 2),
            // Text
            SizedBox(
              width: 55,
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelMedium!.apply(
                  color: isDark ? BColors.black : BColors.white70,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
