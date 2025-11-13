import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BSearchContainer extends StatelessWidget {
  const BSearchContainer({
    super.key,
    required this.text,
    this.icon,
    this.showBackground = true,
    this.showBorder = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: BSizes.paddingMd),
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(BSizes.paddingMd),
          decoration: BoxDecoration(
            color:
                showBackground
                    ? isDark
                        ? BColors.black
                        : BColors.white
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(BSizes.borderRadius),
            border: showBorder ? Border.all(color: BColors.grey) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon ?? Icons.search,
                color: isDark ? BColors.white70 : BColors.grey,
              ),
              const SizedBox(width: BSizes.spaceBetweenItems),
              Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? BColors.white70 : BColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
