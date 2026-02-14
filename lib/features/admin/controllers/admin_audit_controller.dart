import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminAuditController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString query = ''.obs;
  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> logs =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLogs();
  }

  Future<void> loadLogs() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot =
          await _db
              .collection('admin_audit_logs')
              .orderBy('createdAt', descending: true)
              .limit(300)
              .get();

      var rows = snapshot.docs.toList();
      final q = query.value.trim().toLowerCase();
      if (q.isNotEmpty) {
        rows =
            rows.where((doc) {
              final d = doc.data();
              final hay =
                  [
                    '${d['action'] ?? ''}',
                    '${d['resourceType'] ?? ''}',
                    '${d['resourceId'] ?? ''}',
                    '${d['actorEmail'] ?? ''}',
                    '${d['actorUid'] ?? ''}',
                  ].join(' ').toLowerCase();
              return hay.contains(q);
            }).toList();
      }

      logs.assignAll(rows);
    } catch (e) {
      logs.clear();
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setQuery(String value) async {
    query.value = value;
    await loadLogs();
  }
}
