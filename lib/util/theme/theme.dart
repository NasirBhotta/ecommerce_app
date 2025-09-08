import 'package:ecommerce_app/util/theme/custom_theme/appbar_theme.dart';
import 'package:ecommerce_app/util/theme/custom_theme/bottom_sheet_theme.dart';
import 'package:ecommerce_app/util/theme/custom_theme/checkbox_theme.dart';
import 'package:ecommerce_app/util/theme/custom_theme/chip_theme.dart';
import 'package:ecommerce_app/util/theme/custom_theme/elevated_button_theme.dart';
import 'package:ecommerce_app/util/theme/custom_theme/outlined_button_theme.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_field_theme.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BAppTheme {
  BAppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: BColors.primary,
    scaffoldBackgroundColor: BColors.white,
    textTheme: BTextTheme.lightTextTheme,
    elevatedButtonTheme: BElevatedButtonTheme.lightElevatedButtonTheme,
    chipTheme: BChipTheme.lightChipTheme,
    appBarTheme: BAppBarTheme.lightAppBarTheme,
    checkboxTheme: BCheckThemeData.lightCheckboxTheme,
    bottomSheetTheme: BBottomSheetTheme.lightBottomSheetTheme,
    outlinedButtonTheme: BOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: BTextFormFieldTheme.lightInputDecorationTheme,
  );

  static final ThemeData darkTheme = ThemeData(
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: BColors.primary,
    scaffoldBackgroundColor: BColors.white,
    textTheme: BTextTheme.darkTextTheme,
    elevatedButtonTheme: BElevatedButtonTheme.darkElevatedButtonTheme,
    chipTheme: BChipTheme.darkChipTheme,
    appBarTheme: BAppBarTheme.darkAppBarTheme,
    checkboxTheme: BCheckThemeData.darkCheckboxTheme,
    bottomSheetTheme: BBottomSheetTheme.darkBottomSheetTheme,
    outlinedButtonTheme: BOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: BTextFormFieldTheme.darkInputDecorationTheme,
    useMaterial3: true,
  );
}
