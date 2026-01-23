// ignore: file_names
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BDividerWithText extends StatelessWidget {
  final String text;

  const BDividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color:
                isDark
                    ? BColors.white.withValues(alpha: 0.2)
                    : BColors.black.withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:
                  isDark
                      ? BColors.white.withValues(alpha: 0.6)
                      : BColors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color:
                isDark
                    ? BColors.white.withValues(alpha: 0.2)
                    : BColors.black.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}
