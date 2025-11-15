import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class IconMapper {
  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'home':
        return Iconsax.home;
      case 'shopping_cart':
        return Iconsax.shopping_cart;
      case 'shopping_bag':
        return Iconsax.bag;
      case 'account_balance':
        return Iconsax.bank;
      case 'discount':
        return Iconsax.discount_shape;
      case 'notifications':
        return Iconsax.notification;
      case 'privacy_tip':
        return Iconsax.security_user;
      case 'cloud_upload':
        return Iconsax.cloud_add;
      case 'location_on':
        return Iconsax.location;
      case 'security':
        return Iconsax.security;
      case 'hd':
        return Iconsax.video;
      default:
        return Iconsax.setting;
    }
  }
}
