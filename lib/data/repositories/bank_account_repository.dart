import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecommerce_app/data/repositories/auth_repo.dart';
import 'package:ecommerce_app/features/shop/models/bank_account_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class BankAccountRepository extends GetxController {
  static BankAccountRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      // Get current user from FirebaseAuth directly
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw 'You must be signed in to add a bank account. Please log in again.';
      }

      print("Current user UID: ${currentUser.uid}");
      print("Current user email: ${currentUser.email}");

      // Force token refresh to ensure it's valid
      await currentUser.getIdToken(true);
      print("Token refreshed successfully");

      // Call Cloud Function
      final callable = _functions.httpsCallable('addBankAccount');

      final data = {
        'bankName': bankAccount.bankName,
        'accountNumber': bankAccount.accountNumber,
        'accountHolderName': bankAccount.accountHolderName,
        'routingNumber': bankAccount.routingNumber,
      };

      print("Calling Cloud Function with data: $data");

      final result = await callable.call(data);

      print("Cloud Function result: ${result.data}");

      return result.data['id'] ?? '';
    } on FirebaseFunctionsException catch (e) {
      print("FirebaseFunctionsException:");
      print("Code: ${e.code}");
      print("Message: ${e.message}");
      print("Details: ${e.details}");

      if (e.code == 'unauthenticated') {
        throw 'Authentication failed. Please log in again and try.';
      }

      throw e.message ?? 'An error occurred while adding the bank account.';
    } catch (e) {
      print("General error: $e");
      rethrow;
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
}
