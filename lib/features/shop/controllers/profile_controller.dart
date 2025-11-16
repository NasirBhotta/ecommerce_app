import 'package:ecommerce_app/data/repositories/auth_repo.dart';
import 'package:ecommerce_app/features/shop/screens/account_privacy.dart';
import 'package:ecommerce_app/features/shop/screens/addresses.dart';
import 'package:ecommerce_app/features/shop/screens/bank_account.dart';
import 'package:ecommerce_app/features/shop/screens/cart.dart';
import 'package:ecommerce_app/features/shop/screens/coupouns.dart';
import 'package:ecommerce_app/features/shop/screens/notifications.dart';
import 'package:ecommerce_app/features/shop/screens/orders.dart';
import 'package:ecommerce_app/features/shop/screens/profile_edit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();
  final AuthenticationRepository authrepo = AuthenticationRepository.instance;
  // User info
  final userName = 'Nasir Bhutta'.obs;
  final userEmail = 'support@nasirbhutta.com'.obs;
  final userImage = ''.obs;
  final isLoggingOut = false.obs;

  // App settings observables
  final geolocationEnabled = true.obs;
  final safeModeEnabled = false.obs;
  final hdImageQualityEnabled = false.obs;

  // Account settings menu items
  final accountSettings = [
    {
      'icon': 'home',
      'title': 'My Addresses',
      'subtitle': 'Set shopping delivery address',
      'route': '/addresses',
    },
    {
      'icon': 'shopping_cart',
      'title': 'My Cart',
      'subtitle': 'Add, remove products and move to checkout',
      'route': '/cart',
    },
    {
      'icon': 'shopping_bag',
      'title': 'My Orders',
      'subtitle': 'In-progress and Completed Orders',
      'route': '/orders',
    },
    {
      'icon': 'account_balance',
      'title': 'Bank Account',
      'subtitle': 'Withdraw balance to registered bank account',
      'route': '/bank-account',
    },
    {
      'icon': 'discount',
      'title': 'My Coupons',
      'subtitle': 'List of all the discounted coupons',
      'route': '/coupons',
    },
    {
      'icon': 'notifications',
      'title': 'Notifications',
      'subtitle': 'Set any kind of notification message',
      'route': '/notifications',
    },
    {
      'icon': 'privacy_tip',
      'title': 'Account Privacy',
      'subtitle': 'Manage data usage and connected accounts',
      'route': '/privacy',
    },
  ];

  // App settings menu items
  final appSettings = [
    {
      'icon': 'cloud_upload',
      'title': 'Load Data',
      'subtitle': 'Upload Data to your Cloud Firebase',
      'route': '/load-data',
    },
    {
      'icon': 'location_on',
      'title': 'Geolocation',
      'subtitle': 'Set recommendation based on location',
      'hasSwitch': true,
      'value': 'geolocation',
    },
    {
      'icon': 'security',
      'title': 'Safe Mode',
      'subtitle': 'Search result is safe for all ages',
      'hasSwitch': true,
      'value': 'safeMode',
    },
    {
      'icon': 'hd',
      'title': 'HD Image Quality',
      'subtitle': 'Set image quality to be seen',
      'hasSwitch': true,
      'value': 'hdImageQuality',
    },
  ];

  // Toggle geolocation
  void toggleGeolocation(bool value) {
    geolocationEnabled.value = value;
    Get.snackbar(
      'Geolocation',
      value ? 'Geolocation enabled' : 'Geolocation disabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Toggle safe mode
  void toggleSafeMode(bool value) {
    safeModeEnabled.value = value;
    Get.snackbar(
      'Safe Mode',
      value ? 'Safe mode enabled' : 'Safe mode disabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Toggle HD image quality
  void toggleHDImageQuality(bool value) {
    hdImageQualityEnabled.value = value;
    Get.snackbar(
      'HD Image Quality',
      value ? 'HD quality enabled' : 'HD quality disabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Navigate to menu item
  void navigateToMenuItem(String route, String title) {
    switch (route) {
      case '/addresses':
        Get.to(() => const AddressesScreen());
        break;
      case '/cart':
        Get.to(() => const CartScreen());
        break;
      case '/orders':
        Get.to(() => const OrdersScreen());
        break;
      case '/bank-account':
        Get.to(() => const BankAccountScreen());
        break;
      case '/coupons':
        Get.to(() => const CouponsScreen());
        break;
      case '/notifications':
        Get.to(() => const NotificationsScreen());
        break;
      case '/privacy':
        Get.to(() => const AccountPrivacyScreen());
        break;
    }
  }

  // Logout
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back(); // close dialog

              isLoggingOut.value = true; // start loader

              try {
                await authrepo.logout();
              } finally {
                isLoggingOut.value = false; // stop loader
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Edit profile
  void editProfile() {
    // Navigate to profile edit screen
    Get.to(() => const ProfileEditScreen(), transition: Transition.rightToLeft);
    // Or if you're not using named routes:
    // Get.to(() => const ProfileEditScreen());
  }

  // Get switch value
  bool getSwitchValue(String key) {
    switch (key) {
      case 'geolocation':
        return geolocationEnabled.value;
      case 'safeMode':
        return safeModeEnabled.value;
      case 'hdImageQuality':
        return hdImageQualityEnabled.value;
      default:
        return false;
    }
  }

  // Handle switch toggle
  void handleSwitchToggle(String key, bool value) {
    switch (key) {
      case 'geolocation':
        toggleGeolocation(value);
        break;
      case 'safeMode':
        toggleSafeMode(value);
        break;
      case 'hdImageQuality':
        toggleHDImageQuality(value);
        break;
    }
  }
}
