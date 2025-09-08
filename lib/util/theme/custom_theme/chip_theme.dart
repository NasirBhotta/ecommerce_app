import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BChipTheme {
  BChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: BColors.grey.withValues(alpha: 0.4),
    labelStyle: const TextStyle(color: BColors.black),
    selectedColor: BColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: BColors.white,
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: BColors.grey.withValues(alpha: 0.4),
    labelStyle: const TextStyle(color: BColors.white),
    selectedColor: BColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: BColors.white,
  );
}
