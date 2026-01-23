import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BProfileHeader extends StatelessWidget {
  const BProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.imageUrl,
    this.onEditPressed,
  });

  final String name;
  final String email;
  final String? imageUrl;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BSizes.paddingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BColors.primary, BColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(BSizes.cardRadius * 2),
          bottomRight: Radius.circular(BSizes.cardRadius * 2),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: BSizes.appBarHeight),
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BColors.white,
                  border: Border.all(color: BColors.white, width: 3),
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
                                  size: 50,
                                  color: BColors.primary,
                                ),
                          )
                          : const Icon(
                            Icons.person,
                            size: 50,
                            color: BColors.primary,
                          ),
                ),
              ),
              if (onEditPressed != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onEditPressed,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: BColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: BColors.primary, width: 2),
                      ),
                      child: const Icon(
                        Iconsax.edit,
                        size: 16,
                        color: BColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: BSizes.spaceBetweenItems),
          // Name
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall!.apply(
              color: BColors.white,
              fontWeightDelta: 2,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            email,
            style: Theme.of(context).textTheme.bodyMedium!.apply(
              color: BColors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: BSizes.spaceBetweenItems),
        ],
      ),
    );
  }
}
