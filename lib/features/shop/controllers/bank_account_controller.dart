import 'package:ecommerce_app/data/repositories/bank_account_repository.dart';
import 'package:ecommerce_app/data/repositories/wallet_repository.dart';
import 'package:ecommerce_app/features/shop/models/bank_account_model.dart';
import 'package:ecommerce_app/features/shop/controllers/wallet_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class BankAccountController extends GetxController {
  static BankAccountController get instance => Get.find();

  final _bankRepository = Get.put(BankAccountRepository());
  final _walletRepository = Get.put(WalletRepository());
  final _walletController = Get.put(WalletController());

  final RxList<BankAccountModel> bankAccounts = <BankAccountModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Form Input Controllers
  final bankName = TextEditingController();
  final accountHolderName = TextEditingController();
  final accountNumber = TextEditingController();
  final routingNumber = TextEditingController();
  final withdrawalAmount = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    fetchBankAccounts();
    super.onInit();
  }

  @override
  void onClose() {
    bankName.dispose();
    accountHolderName.dispose();
    accountNumber.dispose();
    routingNumber.dispose();
    withdrawalAmount.dispose();
    super.onClose();
  }

  // Getter for UI to access balance
  RxDouble get availableBalance => _walletController.totalBalance;

  Future<void> fetchBankAccounts() async {
    try {
      isLoading.value = true;
      final accounts = await _bankRepository.fetchBankAccounts();
      bankAccounts.assignAll(accounts);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load bank accounts: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAccount() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSaving.value = true;
      Get.back(); // Close dialog

      final newAccount = BankAccountModel(
        id: '',
        bankName: bankName.text.trim(),
        accountNumber: accountNumber.text.trim(),
        accountHolderName: accountHolderName.text.trim(),
        routingNumber: routingNumber.text.trim(),
        isPrimary: bankAccounts.isEmpty,
      );

      await _bankRepository.addBankAccount(newAccount);

      // Reset form
      bankName.clear();
      accountHolderName.clear();
      accountNumber.clear();
      routingNumber.clear();

      await fetchBankAccounts();

      Get.snackbar(
        'Success',
        'Bank account added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add bank account: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void deleteBankAccount(String accountId) {
    Get.defaultDialog(
      title: 'Delete Account',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'Are you sure you want to delete this bank account?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.black,
      onConfirm: () async {
        Get.back();
        try {
          isLoading.value = true;
          await _bankRepository.deleteBankAccount(accountId);
          await fetchBankAccounts();

          Get.snackbar(
            'Success',
            'Bank account deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            duration: const Duration(seconds: 2),
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to delete account: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Future<void> setAsPrimary(String accountId) async {
    try {
      isLoading.value = true;
      await _bankRepository.setPrimaryAccount(accountId);
      await fetchBankAccounts();

      Get.snackbar(
        'Success',
        'Primary account updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update primary account: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    return '**** **** **** ${accountNumber.substring(accountNumber.length - 4)}';
  }

  Future<void> processWithdrawal(String accountId) async {
    if (withdrawalAmount.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    final amount = double.tryParse(withdrawalAmount.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (amount > availableBalance.value) {
      Get.snackbar(
        'Error',
        'Insufficient balance. Available: \$${availableBalance.value.toStringAsFixed(2)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      Get.back(); // Close dialog

      // Call Cloud Function via Wallet Repository
      await _walletRepository.requestWithdrawal(amount, accountId);

      Get.snackbar(
        'Success',
        'Withdrawal request submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 2),
      );

      // Clear withdrawal amount
      withdrawalAmount.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process withdrawal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showAddAccountDialog() {
    // Reset form
    bankName.clear();
    accountHolderName.clear();
    accountNumber.clear();
    routingNumber.clear();

    Get.defaultDialog(
      title: 'Add Bank Account',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: accountHolderName,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                  prefixIcon: Icon(Iconsax.user),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Account holder name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: BSizes.spaceBetweenItems),
              TextFormField(
                controller: bankName,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  prefixIcon: Icon(Iconsax.bank),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bank name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: BSizes.spaceBetweenItems),
              TextFormField(
                controller: accountNumber,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  prefixIcon: Icon(Iconsax.card),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Account number is required';
                  }
                  if (value.trim().length < 8) {
                    return 'Account number must be at least 8 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: BSizes.spaceBetweenItems),
              TextFormField(
                controller: routingNumber,
                decoration: const InputDecoration(
                  labelText: 'Routing Number',
                  prefixIcon: Icon(Iconsax.code),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Routing number is required';
                  }
                  if (value.trim().length != 9) {
                    return 'Routing number must be 9 digits';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      confirm: Obx(
        () => ElevatedButton(
          onPressed: isSaving.value ? null : addAccount,
          child:
              isSaving.value
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Save'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  void showWithdrawalDialog() {
    BankAccountModel? primaryAccount;
    for (var account in bankAccounts) {
      if (account.isPrimary) {
        primaryAccount = account;
        break;
      }
    }

    if (primaryAccount == null) {
      Get.snackbar(
        'No Primary Account',
        'Please add a bank account and set it as primary first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    withdrawalAmount.clear();

    Get.defaultDialog(
      title: 'Withdraw Balance',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text('Available Balance', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    '\$${availableBalance.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: withdrawalAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Withdrawal Amount',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
              hintText: '0.00',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          Text(
            'Withdrawing to: ${primaryAccount.bankName} ****${primaryAccount.accountNumber}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      confirm: Obx(
        () => ElevatedButton(
          onPressed:
              isLoading.value
                  ? null
                  : () => processWithdrawal(primaryAccount!.id),
          child:
              isLoading.value
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Withdraw'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}
