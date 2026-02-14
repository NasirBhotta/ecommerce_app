import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuditLogger {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> log({
    required String action,
    required String resourceType,
    required String resourceId,
    Map<String, dynamic>? details,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    await _db.collection('admin_audit_logs').add({
      'action': action,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'actorUid': user?.uid ?? '',
      'actorEmail': user?.email ?? '',
      'details': details ?? <String, dynamic>{},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
