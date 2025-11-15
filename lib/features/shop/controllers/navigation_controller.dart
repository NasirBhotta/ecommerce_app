import 'package:ecommerce_app/features/shop/screens/home.dart';
import 'package:ecommerce_app/features/shop/screens/profile_screen.dart';
import 'package:ecommerce_app/features/shop/screens/store.dart';
import 'package:ecommerce_app/features/shop/screens/whishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Observable for selected index
  final Rx<int> selectedIndex = 0.obs;

  // Update selected index
  void updateIndex(int index) {
    selectedIndex.value = index;
  }

  // Navigation items count
  static const int itemCount = 4;

  Widget getCurrentScreen() {
    switch (selectedIndex.value) {
      case 0:
        return const HomeScreen();
      case 1:
        return const StoreScreen();
      case 2:
        return const WishlistScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
