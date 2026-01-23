import 'package:ecommerce_app/features/shop/controllers/bank_account_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class BankAccountScreen extends StatelessWidget {
  const BankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BankAccountController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? BColors.black : BColors.white,
        title: const Text('Bank Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Balance Card
          Container(
            margin: const EdgeInsets.all(BSizes.paddingMd),
            padding: const EdgeInsets.all(BSizes.paddingLg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [BColors.primary, BColors.primary.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(BSizes.cardRadius),
            ),
            child: Column(
              children: [
                Text(
                  'Available Balance',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BColors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    '\$${controller.availableBalance.value.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: BColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: BSizes.spaceBetweenItems),
                ElevatedButton(
                  onPressed: controller.showWithdrawalDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BColors.white,
                    foregroundColor: BColors.primary,
                  ),
                  child: const Text('Withdraw Balance'),
                ),
              ],
            ),
          ),

          // Accounts List
          Expanded(
            child: Obx(() {
              if (controller.bankAccounts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.bank,
                        size: 100,
                        color: BColors.grey.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: BSizes.spaceBetweenItems),
                      const Text('No Bank Accounts Added'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(BSizes.paddingMd),
                itemCount: controller.bankAccounts.length,
                itemBuilder: (_, index) {
                  final account = controller.bankAccounts[index];
                  final isPrimary = account['isPrimary'] ?? false;

                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: BSizes.spaceBetweenItems,
                    ),
                    padding: const EdgeInsets.all(BSizes.paddingMd),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(BSizes.cardRadius),
                      border: Border.all(
                        color:
                            isPrimary
                                ? BColors.primary
                                : BColors.grey.withValues(alpha: 0.2),
                        width: isPrimary ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.bank, color: BColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        account['bankName'],
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                      if (isPrimary) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: BColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Text(
                                            'Primary',
                                            style: TextStyle(
                                              color: BColors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    controller.maskAccountNumber(
                                      account['accountNumber'],
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder:
                                  (_) => [
                                    if (!isPrimary)
                                      const PopupMenuItem(
                                        value: 'primary',
                                        child: Text('Set as Primary'),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                              onSelected: (value) {
                                if (value == 'primary') {
                                  controller.setAsPrimary(account['id']);
                                } else {
                                  controller.deleteBankAccount(account['id']);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showAddAccountDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
    );
  }
}
