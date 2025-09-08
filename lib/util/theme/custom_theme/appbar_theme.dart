import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BAppBarTheme {
  BAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: BColors.transparent,
    surfaceTintColor: BColors.transparent,
    iconTheme: IconThemeData(color: BColors.black, size: 24),
    actionsIconTheme: IconThemeData(color: BColors.black, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: BColors.black,
    ),
  );
  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: BColors.transparent,
    surfaceTintColor: BColors.transparent,
    iconTheme: IconThemeData(color: BColors.black, size: 24),
    actionsIconTheme: IconThemeData(color: BColors.white, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: BColors.white,
    ),
  );
}
