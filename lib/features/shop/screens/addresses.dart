import 'package:ecommerce_app/common/widgets/add_new_address.dart';
import 'package:ecommerce_app/common/widgets/address_controller.dart';
import 'package:ecommerce_app/common/widgets/address_model.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());
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
          'My Addresses',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Obx(() {
        if (controller.allAddresses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(BSizes.paddingLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.location,
                    size: 100,
                    color:
                        isDark
                            ? BColors.white.withValues(alpha: 0.2)
                            : BColors.grey.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: BSizes.spaceBetweenSections),
                  Text(
                    'No Addresses Found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: BSizes.spaceBetweenItems),
                  Text(
                    'Add a delivery address to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isDark
                              ? BColors.white.withValues(alpha: 0.6)
                              : BColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(BSizes.paddingMd),
          itemCount: controller.allAddresses.length,
          itemBuilder: (_, index) {
            final address = controller.allAddresses[index];
            return _AddressCard(
              address: address,
              isSelected: controller.selectedAddress.value.id == address.id,
              onSelect: () => controller.selectAddress(address),
              onEdit:
                  () =>
                      Get.to(() => AddNewAddressScreen(addressToEdit: address)),
              onDelete: () => controller.deleteAddress(address.id),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddNewAddressScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
        backgroundColor: BColors.primary,
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final AddressModel address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: BSizes.spaceBetweenItems),
      decoration: BoxDecoration(
        color:
            isDark
                ? BColors.grey.withValues(alpha: 0.1)
                : BColors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(BSizes.cardRadius),
        border: Border.all(
          color:
              isSelected
                  ? BColors.primary
                  : (isDark
                      ? BColors.white.withValues(alpha: 0.1)
                      : BColors.grey.withValues(alpha: 0.2)),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Address Header
          ListTile(
            contentPadding: const EdgeInsets.all(BSizes.paddingMd),
            leading: Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onSelect(),
              activeColor: BColors.primary,
            ),
            title: Row(
              children: [
                Text(
                  address.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.call, size: 14),
                      const SizedBox(width: 8),
                      Text(address.phoneNumber),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.location, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Iconsax.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Iconsax.trash, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
