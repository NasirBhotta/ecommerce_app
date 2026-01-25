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
  final _walletController = Get.put(
    WalletController(),
  ); // Inject Wallet Controller

  final RxList<BankAccountModel> bankAccounts = <BankAccountModel>[].obs;
  // Removed mock availableBalance, will use _walletController.totalBalance
  final isLoading = false.obs;

  // Form Input Controllers
  final bankName = TextEditingController();
  final accountHolderName = TextEditingController();
  final accountNumber = TextEditingController();
  final withdrawalAmount = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    fetchBankAccounts();
    super.onInit();
  }

  // Getter for UI to access balance
  RxDouble get availableBalance => _walletController.totalBalance;

  Future<void> fetchBankAccounts() async {
    try {
      isLoading.value = true;
      final accounts = await _bankRepository.fetchBankAccounts();
      bankAccounts.assignAll(accounts);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAccount() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      Get.back(); // Close dialog

      final newAccount = BankAccountModel(
        bankName: bankName.text.trim(),
        accountNumber: accountNumber.text.trim(),
        accountHolderName: accountHolderName.text.trim(),
      );

      await _bankRepository.addBankAccount(newAccount);

      // Reset form
      bankName.clear();
      accountHolderName.clear();
      accountNumber.clear();

      await fetchBankAccounts();
      Get.snackbar('Success', 'Bank account added successfully.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void deleteBankAccount(String accountId) {
    Get.defaultDialog(
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete this account?',
      onConfirm: () async {
        Get.back();
        try {
          isLoading.value = true;
          await _bankRepository.deleteBankAccount(accountId);
          await fetchBankAccounts();
          Get.snackbar('Success', 'Account deleted.');
        } catch (e) {
          Get.snackbar('Error', e.toString());
        } finally {
          isLoading.value = false;
        }
      },
      onCancel: () => Get.back(),
    );
  }

  void setAsPrimary(String accountId) async {
    try {
      isLoading.value = true;
      await _bankRepository.setPrimaryAccount(accountId);
      await fetchBankAccounts();
      Get.snackbar('Success', 'Primary account updated.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
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
      Get.snackbar('Error', 'Please enter an amount');
      return;
    }

    final amount = double.tryParse(withdrawalAmount.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Invalid amount');
      return;
    }

    if (amount > availableBalance.value) {
      // Checks against real ledger balance
      Get.snackbar('Error', 'Insufficient balance');
      return;
    }

    try {
      isLoading.value = true;
      Get.back(); // Close dialog
      // Call Cloud Function via Wallet Repository
      await _walletRepository.requestWithdrawal(amount, accountId);
      Get.snackbar('Success', 'Withdrawal request submitted successfully.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void showAddAccountDialog() {
    Get.defaultDialog(
      title: 'Add Bank Account',
      content: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: accountHolderName,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
                prefixIcon: Icon(Iconsax.user),
              ),
              validator:
                  (value) => value != null && value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: BSizes.spaceBetweenItems),
            TextFormField(
              controller: bankName,
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                prefixIcon: Icon(Iconsax.bank),
              ),
              validator:
                  (value) => value != null && value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: BSizes.spaceBetweenItems),
            TextFormField(
              controller: accountNumber,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                prefixIcon: Icon(Iconsax.card),
              ),
              validator:
                  (value) => value != null && value.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(onPressed: addAccount, child: const Text('Save')),
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
        'Error',
        'Please add a bank account and set it as primary first.',
      );
      return;
    }

    withdrawalAmount.clear();
    Get.defaultDialog(
      title: 'Withdraw Balance',
      content: Column(
        children: [
          Text('Available: \$${availableBalance.value.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          TextFormField(
            controller: withdrawalAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () => processWithdrawal(primaryAccount!.id),
        child: const Text('Withdraw'),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}
