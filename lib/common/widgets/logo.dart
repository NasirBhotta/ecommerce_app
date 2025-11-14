import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

// ============================================
// LOGO WIDGET
// ============================================
class BLogo extends StatelessWidget {
  final double size;
  final String letter;

  const BLogo({super.key, this.size = 50, this.letter = 'T'});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logos/b-logo.png',
      height: BSizes.imageThumb,
      color:
          Theme.of(context).brightness == Brightness.dark
              ? BColors.primary
              : BColors.primary,
    );
  }
}
