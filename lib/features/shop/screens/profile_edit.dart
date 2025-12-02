import 'package:ecommerce_app/common/widgets/settings/ProfileEdit/profile_edit_widgets.dart';
import 'package:ecommerce_app/features/shop/controllers/profile_edit_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileEditController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? BColors.black : BColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Obx(
              () => BProfilePictureSection(
                imageUrl: controller.profileImage.value,
                onChangePressed: controller.changeProfilePicture,
              ),
            ),

            const SizedBox(height: BSizes.spaceBetweenSections),

            // Profile Information Section
            const BProfileSectionDivider(title: 'Profile Information'),

            // Name
            Obx(
              () => BProfileInfoTile(
                label: 'Name',
                value: controller.name.value,
                onTap: controller.showEditNameDialog,
              ),
            ),

            const Divider(height: 1),

            // Username
            Obx(
              () => BProfileInfoTile(
                label: 'Username',
                value: controller.username.value,
                onTap: controller.showEditUsernameDialog,
              ),
            ),

            const SizedBox(height: BSizes.spaceBetweenSections),

            // Personal Information Section
            const BProfileSectionDivider(title: 'Personal Information'),

            // User ID
            Obx(
              () => BProfileInfoTile(
                label: 'User ID',
                value: controller.userId.value,
                trailing: IconButton(
                  icon: const Icon(Iconsax.copy, size: 20),
                  onPressed: controller.copyUserId,
                ),
                onTap: controller.copyUserId,
              ),
            ),

            const Divider(height: 1),

            // E-mail
            Obx(
              () => BProfileInfoTile(
                label: 'E-mail',
                value: controller.email.value,

                onTap: controller.showEditEmailDialog,
              ),
            ),

            const Divider(height: 1),

            // Phone Number
            Obx(
              () => BProfileInfoTile(
                label: 'Phone Number',
                value: controller.phoneNumber.value,

                onTap: controller.showEditPhoneDialog,
              ),
            ),

            const Divider(height: 1),

            // Gender
            Obx(
              () => BProfileInfoTile(
                label: 'Gender',
                value: controller.gender.value,
                onTap: controller.showGenderSelectionDialog,
              ),
            ),

            const Divider(height: 1),

            // Date of Birth
            Obx(
              () => BProfileInfoTile(
                label: 'Date of Birth',
                value: controller.dateOfBirth.value,
                onTap: controller.showDateOfBirthPicker,
              ),
            ),

            const SizedBox(height: BSizes.spaceBetweenSections * 2),

            // Close Account Button
            BCloseAccountButton(onPressed: controller.closeAccount),

            const SizedBox(height: BSizes.spaceBetweenSections),
          ],
        ),
      ),
    );
  }
}
