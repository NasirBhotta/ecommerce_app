import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BLogoutButton extends StatelessWidget {
  const BLogoutButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(BSizes.paddingMd),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(color: isDark ? BColors.white : BColors.black),
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.red, // optional: you can change color
                  ),
                )
                : Text(
                  'Logout',
                  style: Theme.of(context).textTheme.titleMedium!.apply(
                    color: isDark ? BColors.white : BColors.black,
                  ),
                ),
      ),
    );
  }
}
