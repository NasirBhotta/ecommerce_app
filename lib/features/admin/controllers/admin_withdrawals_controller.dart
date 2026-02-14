import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecommerce_app/features/admin/models/admin_wallet_entry.dart';
import 'package:ecommerce_app/features/admin/services/admin_audit_logger.dart';
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
      await AdminAuditLogger.log(
        action: 'withdrawal_processed',
        resourceType: 'wallet_ledger',
        resourceId: entry.id,
        details: {
          'action': action,
          'userId': entry.userId,
          'amount': entry.amount,
        },
      );
    } on FirebaseFunctionsException catch (e) {
      throw e.message ?? 'Unable to process withdrawal';
    } finally {
      isProcessing.value = false;
    }
  }
}
