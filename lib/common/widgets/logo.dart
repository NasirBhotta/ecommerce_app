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
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: BColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                color: BColors.white,
                fontSize: size * 0.64,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: size * 0.24,
          height: size * 0.24,
          decoration: const BoxDecoration(
            color: BColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
