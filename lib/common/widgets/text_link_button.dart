// ============================================
// TEXT BUTTON LINK
// ============================================
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BTextButtonLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BTextButtonLink({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: BColors.primary),
      ),
    );
  }
}
