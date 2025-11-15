import 'package:ecommerce_app/common/widgets/settings/icon_mapper.dart';
import 'package:ecommerce_app/common/widgets/settings/logout_button.dart';
import 'package:ecommerce_app/common/widgets/settings/menu_tile.dart';
import 'package:ecommerce_app/common/widgets/settings/profile_header.dart';
import 'package:ecommerce_app/common/widgets/settings/profile_section.dart';
import 'package:ecommerce_app/features/shop/controllers/profile_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Obx(
              () => BProfileHeader(
                name: controller.userName.value,
                email: controller.userEmail.value,
                imageUrl: controller.userImage.value,
                onEditPressed: controller.editProfile,
              ),
            ),

            // Account Settings Section
            const BProfileSectionHeading(title: 'Account Settings'),

            // Account Settings Menu Items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.accountSettings.length,
              itemBuilder: (context, index) {
                final item = controller.accountSettings[index];
                return BSettingsMenuTile(
                  icon: IconMapper.getIcon(item['icon'] as String),
                  title: item['title'] as String,
                  subtitle: item['subtitle'] as String,
                  onTap:
                      () => controller.navigateToMenuItem(
                        item['route'] as String,
                        item['title'] as String,
                      ),
                );
              },
            ),

            // App Settings Section
            const BProfileSectionHeading(title: 'App Settings'),

            // App Settings Menu Items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.appSettings.length,
              itemBuilder: (context, index) {
                final item = controller.appSettings[index];
                final hasSwitch = item['hasSwitch'] as bool? ?? false;

                if (hasSwitch) {
                  final switchKey = item['value'] as String;
                  return Obx(
                    () => BSettingsMenuTile(
                      icon: IconMapper.getIcon(item['icon'] as String),
                      title: item['title'] as String,
                      subtitle: item['subtitle'] as String,
                      trailing: Switch(
                        value: controller.getSwitchValue(switchKey),
                        onChanged:
                            (value) =>
                                controller.handleSwitchToggle(switchKey, value),
                        activeColor: BColors.primary,
                      ),
                    ),
                  );
                }

                return BSettingsMenuTile(
                  icon: IconMapper.getIcon(item['icon'] as String),
                  title: item['title'] as String,
                  subtitle: item['subtitle'] as String,
                  onTap:
                      () => controller.navigateToMenuItem(
                        item['route'] as String,
                        item['title'] as String,
                      ),
                );
              },
            ),

            const SizedBox(height: BSizes.spaceBetweenSections),

            // Logout Button
            BLogoutButton(onPressed: controller.logout),

            const SizedBox(height: BSizes.spaceBetweenSections),
          ],
        ),
      ),
    );
  }
}
