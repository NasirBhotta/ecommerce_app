import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BTextFormFieldTheme {
  BTextFormFieldTheme._(); // Prevent instantiation

  /// Light Theme
  static final InputDecorationTheme lightInputDecorationTheme =
      InputDecorationTheme(
        errorMaxLines: 3,
        prefixIconColor: BColors.grey,
        suffixIconColor: BColors.grey,
        constraints: const BoxConstraints.expand(
          height: 56,
        ), // Assuming 14.inputFieldHeight = 56
        labelStyle: const TextStyle(fontSize: 14, color: BColors.black),
        hintStyle: const TextStyle(fontSize: 14, color: BColors.black),
        errorStyle: const TextStyle(fontStyle: FontStyle.normal),
        floatingLabelStyle: TextStyle(color: BColors.black.withValues(alpha: 0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1, color: BColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1, color: BColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1.2, color: BColors.black),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1, color: BColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 2, color: BColors.orange),
        ),
      );

  /// Dark Theme
  static final InputDecorationTheme darkInputDecorationTheme =
      InputDecorationTheme(
        errorMaxLines: 3,
        prefixIconColor: BColors.white,
        suffixIconColor: BColors.white,
        constraints: const BoxConstraints.expand(height: 56), // Same assumption
        labelStyle: const TextStyle(fontSize: 14, color: BColors.white),
        hintStyle: const TextStyle(fontSize: 14, color: BColors.white),
        errorStyle: const TextStyle(fontStyle: FontStyle.normal),
        floatingLabelStyle: TextStyle(color: BColors.white.withValues(alpha: 0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1, color: BColors.white70),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1, color: BColors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1.2, color: BColors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1, color: BColors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 2, color: BColors.deepOrange),
        ),
      );
}
