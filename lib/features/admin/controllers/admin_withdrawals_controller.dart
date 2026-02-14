import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecommerce_app/features/admin/models/admin_wallet_entry.dart';
import 'package:get/get.dart';

class AdminWithdrawalsController extends GetxController {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  final RxBool isProcessing = false.obs;

  Future<void> processWithdrawal(AdminWalletEntry entry, String action) async {
    if (action != 'approve' && action != 'reject') {
      throw 'Invalid action';
    }

    isProcessing.value = true;
    try {
      final callable = _functions.httpsCallable('adminProcessWithdrawal');
      await callable.call({
        'ledgerPath': entry.reference.path,
        'action': action,
      });
    } on FirebaseFunctionsException catch (e) {
      throw e.message ?? 'Unable to process withdrawal';
    } finally {
      isProcessing.value = false;
    }
  }
}
