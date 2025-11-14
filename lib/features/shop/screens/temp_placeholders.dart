import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
