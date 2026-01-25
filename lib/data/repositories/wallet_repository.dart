import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecommerce_app/data/repositories/auth_repo.dart';
import 'package:ecommerce_app/features/shop/models/wallet_transaction_model.dart';
import 'package:get/get.dart';

class WalletRepository extends GetxController {
  static WalletRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Stream of Ledger Entries (Real-time balance updates)
  Stream<List<WalletTransactionModel>> getWalletLedger() {
    final userId = AuthenticationRepository.instance.userId;
    if (userId.isEmpty) return const Stream.empty();

    return _db
        .collection('users')
        .doc(userId)
        .collection('wallet_ledger')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => WalletTransactionModel.fromSnapshot(doc))
                  .toList(),
        );
  }

  // Call Cloud Function to Withdraw
  Future<void> requestWithdrawal(double amount, String bankAccountId) async {
    try {
      final callable = _functions.httpsCallable('requestWithdrawal');
      await callable.call({'amount': amount, 'bankAccountId': bankAccountId});
    } on FirebaseFunctionsException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}
