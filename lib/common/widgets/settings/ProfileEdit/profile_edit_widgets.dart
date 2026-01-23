import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

// ============ PROFILE PICTURE SECTION ============
class BProfilePictureSection extends StatelessWidget {
  const BProfilePictureSection({
    super.key,
    this.imageUrl,
    required this.onChangePressed,
  });

  final String? imageUrl;
  final VoidCallback onChangePressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: BSizes.spaceBetweenSections),
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BColors.grey.withValues(alpha: 0.2),
                ),
                child: ClipOval(
                  child:
                      imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: BColors.grey,
                                ),
                          )
                          : const Icon(
                            Icons.person,
                            size: 60,
                            color: BColors.grey,
                          ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BSizes.spaceBetweenItems),
          // Change Picture Button
          TextButton(
            onPressed: onChangePressed,
            child: Text(
              'Change Profile Picture',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: BColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ PROFILE INFO TILE ============
class BProfileInfoTile extends StatelessWidget {
  const BProfileInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
    this.obscureValue = false,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool obscureValue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: BSizes.paddingLg,
        vertical: BSizes.paddingSm,
      ),
      enabled: label == 'E-mail' ? false : true,

      title: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark ? BColors.white.withValues(alpha: 0.6) : BColors.grey,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          obscureValue ? '•' * 15 : value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      trailing:
          label == 'E-mail'
              ? null
              : trailing ??
                  Icon(
                    Icons.chevron_right,
                    color:
                        isDark ? BColors.white.withValues(alpha: 0.6) : BColors.grey,
                  ),
      onTap: label == 'E-mail' ? null : onTap,
    );
  }
}

// ============ SECTION DIVIDER ============
class BProfileSectionDivider extends StatelessWidget {
  const BProfileSectionDivider({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BSizes.paddingLg,
        vertical: BSizes.paddingMd,
      ),
      color:
          isDark
              ? BColors.grey.withValues(alpha: 0.1)
              : BColors.grey.withValues(alpha: 0.05),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ============ CLOSE ACCOUNT BUTTON ============
class BCloseAccountButton extends StatelessWidget {
  const BCloseAccountButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BSizes.paddingLg),
        child: TextButton(
          onPressed: onPressed,
          child: const Text(
            'Close Account',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
