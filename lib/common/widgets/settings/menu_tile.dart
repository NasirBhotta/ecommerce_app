import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BSettingsMenuTile extends StatelessWidget {
  const BSettingsMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: BSizes.paddingMd,
        vertical: BSizes.paddingSm,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: BColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(BSizes.paddingMd),
        ),
        child: Icon(icon, color: BColors.primary, size: 24),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark ? BColors.white.withValues(alpha: 0.6) : BColors.grey,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: isDark ? BColors.white : BColors.grey,
          ),
      onTap: onTap,
    );
  }
}
