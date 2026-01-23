import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BEmptyState extends StatelessWidget {
  const BEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.search_off,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color:
                isDark
                    ? BColors.white.withValues(alpha: 0.3)
                    : BColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: BSizes.spaceBetweenItems),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark ? BColors.white.withValues(alpha: 0.6) : BColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
