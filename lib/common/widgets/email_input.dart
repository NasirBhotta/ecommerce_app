// ============================================
// EMAIL INPUT FIELD
// ============================================
import 'package:flutter/material.dart';

class BEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String label;

  const BEmailField({
    super.key,
    required this.controller,
    this.validator,
    this.label = 'E-Mail',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,

      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email_outlined),
        labelText: label,
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }
}
