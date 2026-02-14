import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/services/admin_audit_logger.dart';
import 'package:get/get.dart';

class AdminRiskFlagsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> flags =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFlags();
  }

  Future<void> loadFlags() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final snapshot = await _db.collection('risk_flags').get();
      final docs =
          snapshot.docs.toList()..sort((a, b) {
            final aTs = a.data()['createdAt'];
            final bTs = b.data()['createdAt'];
            final aDate =
                aTs is Timestamp
                    ? aTs.toDate()
                    : DateTime.fromMillisecondsSinceEpoch(0);
            final bDate =
                bTs is Timestamp
                    ? bTs.toDate()
                    : DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });
      flags.assignAll(docs);
    } catch (e) {
      flags.clear();
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createFlag({
    required String userId,
    required String reason,
    required String severity,
  }) async {
    final ref = await _db.collection('risk_flags').add({
      'userId': userId,
      'reason': reason,
      'severity': severity,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'risk_flag_created',
      resourceType: 'risk_flag',
      resourceId: ref.id,
      details: {'userId': userId, 'severity': severity},
    );
    await loadFlags();
  }

  Future<void> resolveFlag(String id, String note) async {
    await _db.collection('risk_flags').doc(id).update({
      'status': 'resolved',
      'resolutionNote': note,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'risk_flag_resolved',
      resourceType: 'risk_flag',
      resourceId: id,
      details: {'note': note},
    );
    await loadFlags();
  }
}
