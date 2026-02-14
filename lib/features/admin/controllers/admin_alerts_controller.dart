import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminAlertsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, String>> alerts = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final out = <Map<String, String>>[];

      final paymentIssues =
          await _db
              .collection('payment_issues')
              .where('status', isEqualTo: 'open')
              .get();
      for (final doc in paymentIssues.docs) {
        final d = doc.data();
        out.add({
          'type': 'payment_issue',
          'severity': 'high',
          'id': doc.id,
          'message': (d['errorMessage'] ?? 'Payment issue').toString(),
        });
      }

      final failedPayouts =
          await _db
              .collectionGroup('wallet_ledger')
              .where('status', isEqualTo: 'failed')
              .where('type', isEqualTo: 'debit')
              .get();
      for (final doc in failedPayouts.docs) {
        final d = doc.data();
        final userId = doc.reference.parent.parent?.id ?? '';
        out.add({
          'type': 'payout_failure',
          'severity': 'high',
          'id': doc.id,
          'message':
              'User $userId: ${(d['failureReason'] ?? 'Payout failed').toString()}',
        });
      }

      final riskFlags =
          await _db
              .collection('risk_flags')
              .where('status', isEqualTo: 'open')
              .get();
      for (final doc in riskFlags.docs) {
        final d = doc.data();
        out.add({
          'type': 'risk_flag',
          'severity': '${d['severity'] ?? 'medium'}',
          'id': doc.id,
          'message':
              'User ${d['userId'] ?? ''}: ${(d['reason'] ?? '').toString()}',
        });
      }

      alerts.assignAll(out);
    } catch (e) {
      alerts.clear();
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
