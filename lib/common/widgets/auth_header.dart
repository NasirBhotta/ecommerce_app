// ============================================
// HEADER SECTION
// ============================================
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BAuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const BAuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color:
                isDark
                    ? BColors.white.withValues(alpha: 0.6)
                    : BColors.black.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
