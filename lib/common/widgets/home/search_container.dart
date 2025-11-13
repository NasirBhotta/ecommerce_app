import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BSearchField extends StatelessWidget {
  const BSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search in Store',
    this.onClear,
    this.showClearButton = false,
  });

  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;
  final VoidCallback? onClear;
  final bool showClearButton;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BSizes.paddingMd),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? BColors.white70 : BColors.grey,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? BColors.white70 : BColors.grey,
          ),
          suffixIcon:
              showClearButton
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: isDark ? BColors.white70 : BColors.grey,
                    ),
                    onPressed: onClear,
                  )
                  : null,
          filled: true,
          fillColor: isDark ? BColors.black : BColors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(BSizes.borderRadius),
            borderSide: BorderSide(
              color: isDark ? BColors.white70 : BColors.grey,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(BSizes.borderRadius),
            borderSide: const BorderSide(color: BColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: BSizes.paddingMd,
            vertical: BSizes.paddingMd,
          ),
        ),
      ),
    );
  }
}
