import 'package:flutter/material.dart';

class BPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final String label;

  const BPasswordField({
    super.key,
    required this.controller,
    this.validator,
    required this.obscureText,
    this.onToggleVisibility,
    this.label = 'Password',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline),
        labelText: label,
        suffixIcon:
            onToggleVisibility != null
                ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: onToggleVisibility,
                )
                : null,
      ),
    );
  }
}
