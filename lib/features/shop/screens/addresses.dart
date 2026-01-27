import 'package:ecommerce_app/features/shop/models/address_model.dart';
import 'package:ecommerce_app/features/shop/controllers/addresses_controller.dart';
import 'package:ecommerce_app/features/shop/screens/add_new_address.dart';
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
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => controller.fetchAddresses(),
          ),
        ],
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Empty State
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
                              : BColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: BSizes.spaceBetweenSections),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const AddNewAddressScreen()),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your First Address'),
                  ),
                ],
              ),
            ),
          );
        }

        // Address List
        return RefreshIndicator(
          onRefresh: () => controller.fetchAddresses(),
          child: ListView.builder(
            padding: const EdgeInsets.all(BSizes.paddingMd),
            itemCount: controller.allAddresses.length,
            itemBuilder: (_, index) {
              final address = controller.allAddresses[index];
              return _AddressCard(
                address: address,
                isSelected: controller.selectedAddress.value.id == address.id,
                onSelect: () => controller.selectAddress(address),
                onEdit:
                    () => Get.to(
                      () => AddNewAddressScreen(addressToEdit: address),
                    ),
                onDelete:
                    () => _showDeleteConfirmation(
                      context,
                      controller,
                      address,
                      isDark,
                    ),
              );
            },
          ),
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

  void _showDeleteConfirmation(
    BuildContext context,
    AddressController controller,
    AddressModel address,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? BColors.black : BColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BSizes.cardRadius),
          ),
          title: Row(
            children: [
              Icon(Iconsax.warning_2, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              const Text('Delete Address'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this address?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? BColors.grey.withValues(alpha: 0.1)
                          : BColors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? BColors.white : BColors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                controller.deleteAddress(address.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
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
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(BSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(BSizes.paddingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio Button
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onSelect(),
                activeColor: BColors.primary,
              ),

              // Address Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Default Badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: BColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Default',
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Phone Number
                    Row(
                      children: [
                        Icon(
                          Iconsax.call,
                          size: 14,
                          color:
                              isDark
                                  ? BColors.white.withValues(alpha: 0.7)
                                  : BColors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          address.phoneNumber,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Iconsax.location,
                          size: 14,
                          color:
                              isDark
                                  ? BColors.white.withValues(alpha: 0.7)
                                  : BColors.black,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // More Options Menu
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Iconsax.edit),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Iconsax.trash, color: Colors.red),
                            SizedBox(width: 12),
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
            ],
          ),
        ),
      ),
    );
  }
}
