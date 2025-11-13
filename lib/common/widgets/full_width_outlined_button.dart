// ============================================
// FULL WIDTH OUTLINED BUTTON
// ============================================
import 'package:flutter/material.dart';

class BFullWidthOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const BFullWidthOutlinedButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}
