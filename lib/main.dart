import 'package:ecommerce_app/util/theme/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const EcommrceApp());
}

class EcommrceApp extends StatelessWidget {
  const EcommrceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: BAppTheme.lightTheme,
      darkTheme: BAppTheme.darkTheme,
    );
  }
}
