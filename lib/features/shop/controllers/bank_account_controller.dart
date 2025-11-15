import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BankAccountController extends GetxController {
  static BankAccountController get instance => Get.find();

  // Observable bank accounts list
  final RxList<Map<String, dynamic>> bankAccounts =
      <Map<String, dynamic>>[].obs;

  // Selected account for withdrawal
  final selectedAccountId = ''.obs;

  // Available balance
  final availableBalance = 2450.00.obs;

  // Loading state
  final isLoading = false.obs;

  // Text controllers for add account form
  final accountHolderController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ibanController = TextEditingController();
  final swiftCodeController = TextEditingController();
  final branchController = TextEditingController();

  // Withdrawal controller
  final withdrawalAmountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSampleData();
  }

  @override
  void onClose() {
    accountHolderController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ibanController.dispose();
    swiftCodeController.dispose();
    branchController.dispose();
    withdrawalAmountController.dispose();
    super.onClose();
  }

  // Get selected account
  Map<String, dynamic>? get selectedAccount {
    if (selectedAccountId.value.isEmpty) return null;
    try {
      return bankAccounts.firstWhere(
        (acc) => acc['id'] == selectedAccountId.value,
      );
    } catch (e) {
      return null;
    }
  }

  // Select account
  void selectAccount(String accountId) {
    selectedAccountId.value = accountId;
  }

  // Show add account dialog
  void showAddAccountDialog() {
    _clearControllers();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Bank Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                accountHolderController,
                'Account Holder Name',
                Icons.person,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                bankNameController,
                'Bank Name',
                Icons.account_balance,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                accountNumberController,
                'Account Number',
                Icons.credit_card,
              ),
              const SizedBox(height: 12),
              _buildTextField(ibanController, 'IBAN (Optional)', Icons.code),
              const SizedBox(height: 12),
              _buildTextField(
                swiftCodeController,
                'SWIFT Code (Optional)',
                Icons.code_off,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                branchController,
                'Branch Name',
                Icons.location_on,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_validateAccount()) {
                addBankAccount();
                Get.back();
              }
            },
            child: const Text('Add Account'),
          ),
        ],
      ),
    );
  }

  // Add bank account
  void addBankAccount() {
    final newAccount = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'accountHolder': accountHolderController.text.trim(),
      'bankName': bankNameController.text.trim(),
      'accountNumber': accountNumberController.text.trim(),
      'iban': ibanController.text.trim(),
      'swiftCode': swiftCodeController.text.trim(),
      'branch': branchController.text.trim(),
      'isPrimary': bankAccounts.isEmpty,
      'addedDate': DateTime.now().toIso8601String(),
    };

    bankAccounts.add(newAccount);

    if (bankAccounts.length == 1) {
      selectedAccountId.value = newAccount['id'] as String;
    }

    Get.snackbar(
      'Success',
      'Bank account added successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Delete account
  void deleteBankAccount(String accountId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete this bank account?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              bankAccounts.removeWhere((acc) => acc['id'] == accountId);
              if (selectedAccountId.value == accountId) {
                selectedAccountId.value =
                    bankAccounts.isNotEmpty ? bankAccounts[0]['id'] : '';
              }
              Get.back();
              Get.snackbar(
                'Deleted',
                'Bank account deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Set as primary account
  void setAsPrimary(String accountId) {
    for (var acc in bankAccounts) {
      acc['isPrimary'] = acc['id'] == accountId;
    }
    bankAccounts.refresh();
    selectedAccountId.value = accountId;

    Get.snackbar(
      'Success',
      'Primary account updated',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Show withdrawal dialog
  void showWithdrawalDialog() {
    if (bankAccounts.isEmpty) {
      Get.snackbar(
        'No Account',
        'Please add a bank account first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    withdrawalAmountController.clear();
    selectedAccountId.value =
        bankAccounts.firstWhere((acc) => acc['isPrimary'] == true)['id'];

    Get.dialog(
      AlertDialog(
        title: const Text('Withdraw Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Available: \$${availableBalance.value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: withdrawalAmountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                value: selectedAccountId.value,
                decoration: const InputDecoration(
                  labelText: 'Select Account',
                  border: OutlineInputBorder(),
                ),
                items:
                    bankAccounts.map<DropdownMenuItem<String>>((acc) {
                      return DropdownMenuItem<String>(
                        value: acc['id'] as String,
                        child: Text(
                          '${acc['bankName']} - ${maskAccountNumber(acc['accountNumber'])}',
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) selectedAccountId.value = value;
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Processing time: 3-5 business days',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              processWithdrawal();
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  // Process withdrawal
  void processWithdrawal() {
    final amount = double.tryParse(withdrawalAmountController.text);

    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return;
    }

    if (amount > availableBalance.value) {
      Get.snackbar('Error', 'Insufficient balance');
      return;
    }

    if (amount < 10) {
      Get.snackbar('Error', 'Minimum withdrawal amount is \$10');
      return;
    }

    // Process withdrawal
    availableBalance.value -= amount;
    Get.back();

    Get.snackbar(
      'Withdrawal Initiated',
      'Your withdrawal request of \$${amount.toStringAsFixed(2)} has been processed',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  // Mask account number
  String maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }

  // Validate account
  bool _validateAccount() {
    if (accountHolderController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter account holder name');
      return false;
    }
    if (bankNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter bank name');
      return false;
    }
    if (accountNumberController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter account number');
      return false;
    }
    return true;
  }

  // Clear controllers
  void _clearControllers() {
    accountHolderController.clear();
    bankNameController.clear();
    accountNumberController.clear();
    ibanController.clear();
    swiftCodeController.clear();
    branchController.clear();
  }

  // Build text field
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  // Load sample data
  void loadSampleData() {
    if (bankAccounts.isEmpty) {
      bankAccounts.addAll([
        {
          'id': '1',
          'accountHolder': 'Taimoor Sikander',
          'bankName': 'Standard Chartered Bank',
          'accountNumber': '1234567890123456',
          'iban': 'PK36SCBL0000001234567890',
          'swiftCode': 'SCBLPKKAXXX',
          'branch': 'F-10 Markaz, Islamabad',
          'isPrimary': true,
          'addedDate': DateTime.now().toIso8601String(),
        },
      ]);
      selectedAccountId.value = '1';
    }
  }

  // Firebase methods (commented for now)

  // Future<void> loadBankAccountsFromFirebase(String userId) async {
  //   try {
  //     isLoading.value = true;
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('bankAccounts')
  //         .get();
  //
  //     bankAccounts.value = snapshot.docs
  //         .map((doc) => {...doc.data(), 'id': doc.id})
  //         .toList();
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to load bank accounts');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<void> createWithdrawalRequest(String userId, double amount, String accountId) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('withdrawalRequests')
  //         .add({
  //       'userId': userId,
  //       'accountId': accountId,
  //       'amount': amount,
  //       'status': 'Pending',
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to create withdrawal request');
  //   }
  // }
}
