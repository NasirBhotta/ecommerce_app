import 'package:ecommerce_app/features/shop/controllers/cart_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/checkout_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/wallet_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final checkoutController = Get.put(CheckoutController());
    final walletController = Get.find<WalletController>(); // Assumed active
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BSizes.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Order Summary ---
            Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: BSizes.spaceBetweenItems),
            Container(
              padding: const EdgeInsets.all(BSizes.paddingMd),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _OrderRow(label: 'Subtotal', value: '\$${cartController.subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _OrderRow(label: 'Tax (10%)', value: '\$${cartController.tax.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _OrderRow(label: 'Shipping', value: '\$${cartController.shipping.toStringAsFixed(2)}'),
                  const Divider(height: 24),
                  _OrderRow(
                    label: 'Total', 
                    value: '\$${cartController.total.toStringAsFixed(2)}', 
                    isBold: true
                  ),
                ],
              ),
            ),
            const SizedBox(height: BSizes.spaceBetweenSections),

            // --- Payment Method Selection ---
            Text('Payment Method', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: BSizes.spaceBetweenItems),
            
            // 1. Wallet Option
            Obx(() {
              final balance = walletController.totalBalance.value;
              final total = cartController.total;
              final isSufficient = balance >= total;
              final isSelected = checkoutController.selectedPaymentMethod.value == PaymentMethod.wallet;

              return Opacity(
                opacity: isSufficient ? 1.0 : 0.5,
                child: GestureDetector(
                  onTap: isSufficient ? () => checkoutController.selectPaymentMethod(PaymentMethod.wallet) : null,
                  child: Container(
                    padding: const EdgeInsets.all(BSizes.paddingMd),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.blue.withOpacity(0.1) 
                          : (isDark ? Colors.grey.withOpacity(0.1) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                         const Icon(Iconsax.wallet, color: Colors.blue),
                         const SizedBox(width: 12),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Wallet Balance', style: Theme.of(context).textTheme.titleMedium),
                             Text(
                               '\$${balance.toStringAsFixed(2)}', 
                               style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                 color: isSufficient ? Colors.green : Colors.red,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           ],
                         ),
                         const Spacer(),
                         if (!isSufficient)
                           Text('Insufficient', style: TextStyle(color: Colors.red, fontSize: 12)),
                         if (isSelected)
                           const Icon(Icons.check_circle, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: BSizes.spaceBetweenItems),

            // 2. Card Option
            Obx(() {
               final isSelected = checkoutController.selectedPaymentMethod.value == PaymentMethod.card;
               return GestureDetector(
                  onTap: () => checkoutController.selectPaymentMethod(PaymentMethod.card),
                  child: Container(
                    padding: const EdgeInsets.all(BSizes.paddingMd),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.blue.withOpacity(0.1) 
                          : (isDark ? Colors.grey.withOpacity(0.1) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.card, color: Colors.orange),
                            const SizedBox(width: 12),
                            Text('Credit / Debit Card', style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.blue),
                          ],
                        ),
                        
                        // Select Card Dropdown (Visible only if Card is selected)
                        if (isSelected && checkoutController.savedCards.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          DropdownButtonFormField<String>(
                            value: checkoutController.selectedPaymentMethodId.value.isEmpty 
                                ? null 
                                : checkoutController.selectedPaymentMethodId.value,
                            decoration: const InputDecoration(
                              labelText: 'Select Card',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: checkoutController.savedCards.map((card) {
                              return DropdownMenuItem<String>(
                                value: card['id'],
                                child: Row(
                                  children: [
                                    Icon(_getCardIcon(card['brand']), size: 24),
                                    const SizedBox(width: 8),
                                    Text('**** ${card['last4']}'),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) checkoutController.selectedPaymentMethodId.value = val;
                            },
                          ),
                        ]
                      ],
                    ),
                  ),
               );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(BSizes.paddingLg),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(
            () => ElevatedButton(
              onPressed: checkoutController.isLoading.value 
                  ? null 
                  : () => checkoutController.processPayment(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
              ),
              child: checkoutController.isLoading.value
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : Text('Pay \$${cartController.total.toStringAsFixed(2)}'),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCardIcon(String? brand) {
    if (brand?.toLowerCase() == 'visa') return Icons.credit_card; // Use specific icons if available
    if (brand?.toLowerCase() == 'mastercard') return Icons.credit_card;
    return Icons.credit_card;
  }
}

class _OrderRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _OrderRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: isBold 
            ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) 
            : Theme.of(context).textTheme.bodyMedium
        ),
        Text(
          value, 
          style: isBold 
            ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue) 
            : Theme.of(context).textTheme.bodyMedium
        ),
      ],
    );
  }
}
