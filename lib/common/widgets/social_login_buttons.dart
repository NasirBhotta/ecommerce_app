import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class BSocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final String assetPath;
  final IconData fallbackIcon;

  const BSocialLoginButton({
    super.key,
    required this.onTap,
    required this.assetPath,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color:
                isDark
                    ? BColors.white.withValues(alpha: 0.2)
                    : BColors.black.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(fallbackIcon, size: 32);
            },
          ),
        ),
      ),
    );
  }
}

class BSocialLoginRow extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onFacebookTap;

  const BSocialLoginRow({
    super.key,
    required this.onGoogleTap,
    required this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BSocialLoginButton(
          onTap: onGoogleTap,
          assetPath: 'assets/logos/google.png',
          fallbackIcon: Icons.g_mobiledata,
        ),
        const SizedBox(width: 24),
        BSocialLoginButton(
          onTap: onFacebookTap,
          assetPath: 'assets/logos/facebook.png',
          fallbackIcon: Icons.facebook,
        ),
      ],
    );
  }
}
