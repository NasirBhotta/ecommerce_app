import 'package:ecommerce_app/data/repositories/wallet_repository.dart';
import 'package:ecommerce_app/features/shop/models/wallet_transaction_model.dart';
import 'package:get/get.dart';

class WalletController extends GetxController {
  static WalletController get instance => Get.find();

  final _walletRepository = Get.put(WalletRepository());

  // Reactive list of transactions
  final RxList<WalletTransactionModel> transactions =
      <WalletTransactionModel>[].obs;

  // Derived Balance (Sum of all confirmed/pending transactions)
  final RxDouble totalBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind the stream to the reactive list
    transactions.bindStream(_walletRepository.getWalletLedger());

    // Recalculate balance whenever transactions change
    ever(transactions, _calculateBalance);
  }

  void _calculateBalance(List<WalletTransactionModel> txs) {
    double balance = 0.0;
    for (var tx in txs) {
      // We count pending withdrawals as deducted to prevent double spending
      if (tx.status == 'confirmed' || tx.status == 'pending') {
        balance += tx.amount;
      }
    }
    totalBalance.value = balance;
  }
}
