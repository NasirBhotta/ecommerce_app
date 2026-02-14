import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminPaymentIssuesController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> issues =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadIssues();
  }

  Future<void> loadIssues() async {
    try {
      isLoading.value = true;
      final snapshot = await _db.collection('payment_issues').get();
      final docs = snapshot.docs.toList()
        ..sort((a, b) {
          final aTs = a.data()['createdAt'];
          final bTs = b.data()['createdAt'];
          final aDate = aTs is Timestamp ? aTs.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = bTs is Timestamp ? bTs.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
      issues.assignAll(docs);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resolveIssue(String issueId, String note) async {
    await _db.collection('payment_issues').doc(issueId).update({
      'status': 'resolved',
      'resolutionNote': note,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
    await loadIssues();
  }
}
