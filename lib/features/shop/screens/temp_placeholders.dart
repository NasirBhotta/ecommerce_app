import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ============================================
// STORE SCREEN (Placeholder)
// ============================================
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Iconsax.shop5, size: 100, color: BColors.primary),
            SizedBox(height: 20),
            Text(
              'Store Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Coming Soon...',
              style: TextStyle(fontSize: 16, color: BColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// WISHLIST SCREEN (Placeholder)
// ============================================
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Iconsax.heart5, size: 100, color: BColors.primary),
            SizedBox(height: 20),
            Text(
              'Wishlist Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Coming Soon...',
              style: TextStyle(fontSize: 16, color: BColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// PROFILE SCREEN (Placeholder)
// ============================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Iconsax.user5, size: 100, color: BColors.primary),
            SizedBox(height: 20),
            Text(
              'Profile Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Coming Soon...',
              style: TextStyle(fontSize: 16, color: BColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
