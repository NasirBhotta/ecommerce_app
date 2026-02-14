import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/services/admin_audit_logger.dart';
import 'package:get/get.dart';

class AdminUsersController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> users =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final snapshot = await _db.collection('users').get();
      final docs =
          snapshot.docs.toList()..sort((a, b) {
            final aName =
                (a.data()['fullName'] ?? a.data()['email'] ?? '').toString();
            final bName =
                (b.data()['fullName'] ?? b.data()['email'] ?? '').toString();
            return aName.toLowerCase().compareTo(bName.toLowerCase());
          });
      users.assignAll(docs);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _db.collection('users').doc(uid).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'user_role_updated',
      resourceType: 'user',
      resourceId: uid,
      details: {'role': role},
    );
    await loadUsers();
  }

  Future<void> updateUserStatus(String uid, bool isActive) async {
    await _db.collection('users').doc(uid).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'user_status_updated',
      resourceType: 'user',
      resourceId: uid,
      details: {'isActive': isActive},
    );
    await loadUsers();
  }
}
