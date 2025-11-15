import 'package:ecommerce_app/features/shop/controllers/account_privact_contoller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountPrivacyScreen extends StatelessWidget {
  const AccountPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountPrivacyController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        children: [
          _buildSection(context, 'Privacy Settings', [
            Obx(
              () => SwitchListTile(
                title: const Text('Show Online Status'),
                value: controller.showOnlineStatus.value,
                onChanged: controller.toggleShowOnlineStatus,
              ),
            ),
            Obx(
              () => SwitchListTile(
                title: const Text('Show Purchase History'),
                value: controller.showPurchaseHistory.value,
                onChanged: controller.toggleShowPurchaseHistory,
              ),
            ),
          ]),
          _buildSection(context, 'Security', [
            Obx(
              () => SwitchListTile(
                title: const Text('Two-Factor Authentication'),
                value: controller.twoFactorAuth.value,
                onChanged: controller.toggleTwoFactorAuth,
              ),
            ),
            Obx(
              () => SwitchListTile(
                title: const Text('Biometric Authentication'),
                value: controller.biometricAuth.value,
                onChanged: controller.toggleBiometricAuth,
              ),
            ),
          ]),
          _buildSection(context, 'Data Management', [
            ListTile(
              title: const Text('Download Personal Data'),
              trailing: const Icon(Icons.download),
              onTap: controller.downloadPersonalData,
            ),
            ListTile(
              title: const Text('Delete Account Data'),
              trailing: const Icon(Icons.delete, color: Colors.red),
              onTap: controller.deleteAccountData,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
