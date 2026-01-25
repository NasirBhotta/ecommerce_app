import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecommerce_app/data/repositories/auth_repo.dart';
import 'package:ecommerce_app/features/shop/models/bank_account_model.dart';
import 'package:get/get.dart';

class BankAccountRepository extends GetxController {
  static BankAccountRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<List<BankAccountModel>> fetchBankAccounts() async {
    try {
      final userId = AuthenticationRepository.instance.userId;
      if (userId.isEmpty) throw 'User information not found';

      final result =
          await _db
              .collection('users')
              .doc(userId)
              .collection('bank_accounts')
              .get();
      return result.docs
          .map(
            (documentSnapshot) =>
                BankAccountModel.fromSnapshot(documentSnapshot),
          )
          .toList();
    } catch (e) {
      throw 'Something went wrong while fetching Bank Accounts.';
    }
  }

  Future<String> addBankAccount(BankAccountModel bankAccount) async {
    try {
      final userId = AuthenticationRepository.instance.userId;
      if (userId.isEmpty) throw 'User information not found';

      // Call Cloud Function to securely add bank account to Stripe & Firestore
      final callable = _functions.httpsCallable('addBankAccount');
      final result = await callable.call(bankAccount.toJson());
      return result.data['id'] ?? '';
    } on FirebaseFunctionsException catch (e) {
      throw e.message ?? 'An error occurred while adding the bank account.';
    } catch (e) {
      throw 'Something went wrong while saving Bank Account.';
    }
  }

  Future<void> deleteBankAccount(String accountId) async {
    try {
      final userId = AuthenticationRepository.instance.userId;
      if (userId.isEmpty) throw 'User information not found';

      // Call Cloud Function to remove from Stripe & Firestore
      final callable = _functions.httpsCallable('deleteBankAccount');
      await callable.call({'accountId': accountId});
    } on FirebaseFunctionsException catch (e) {
      throw e.message ?? 'An error occurred while deleting the bank account.';
    } catch (e) {
      throw 'Something went wrong while deleting Bank Account.';
    }
  }

  Future<void> setPrimaryAccount(String accountId) async {
    try {
      final userId = AuthenticationRepository.instance.userId;
      if (userId.isEmpty) throw 'User information not found';

      // Call Cloud Function to update default payout destination in Stripe
      final callable = _functions.httpsCallable('setPrimaryBankAccount');
      await callable.call({'accountId': accountId});
    } on FirebaseFunctionsException catch (e) {
      throw e.message ?? 'An error occurred while updating primary account.';
    } catch (e) {
      throw 'Something went wrong while setting primary account.';
    }
  }

  Future<void> requestWithdrawal(double amount, String accountId) async {
    // Deprecated: Logic moved to Cloud Functions (WalletRepository)
    // Keeping empty or throwing error to ensure migration
    throw 'Use WalletRepository.requestWithdrawal instead';
  }
}
