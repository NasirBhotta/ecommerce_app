import 'package:ecommerce_app/features/shop/controllers/navigation_controller.dart';
import 'package:ecommerce_app/features/shop/screens/home.dart';
import 'package:ecommerce_app/features/shop/screens/profile_screen.dart';
import 'package:ecommerce_app/features/shop/screens/store.dart';
import 'package:ecommerce_app/features/shop/screens/whishlist_screen.dart';

import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NavigationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // List of screens (to be replaced with actual screens later)
    final List<Widget> screens = const [
      HomeScreen(),
      StoreScreen(),
      WishlistScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(() => screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.updateIndex,
          backgroundColor: isDark ? BColors.black : BColors.white,
          indicatorColor:
              isDark
                  ? BColors.white.withValues(alpha: 0.1)
                  : BColors.primary.withValues(alpha: 0.1),
          destinations: const [
            NavigationDestination(
              icon: Icon(Iconsax.home),
              selectedIcon: Icon(Iconsax.home_15),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.shop),
              selectedIcon: Icon(Iconsax.shop5),
              label: 'Store',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.heart),
              selectedIcon: Icon(Iconsax.heart5),
              label: 'Wishlist',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.user),
              selectedIcon: Icon(Iconsax.user5),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
