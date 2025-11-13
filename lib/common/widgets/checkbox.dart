// ============================================
// REMEMBER ME CHECKBOX
// ============================================
import 'package:flutter/material.dart';

class BRememberMeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;

  const BRememberMeCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Remember Me',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
