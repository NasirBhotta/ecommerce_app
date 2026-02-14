import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminNotificationsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final RxBool isSending = false.obs;

  Future<void> sendToUser({
    required String userId,
    required String title,
    required String body,
    String type = 'admin',
  }) async {
    if (userId.trim().isEmpty) {
      throw 'User ID is required';
    }

    isSending.value = true;
    try {
      await _db.collection('users').doc(userId).collection('notifications').add(
        {
          'title': title,
          'body': body,
          'type': type,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'data': {'source': 'admin_panel'},
        },
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<int> sendBroadcast({
    required String title,
    required String body,
    String type = 'promotion',
  }) async {
    isSending.value = true;
    try {
      final usersSnapshot = await _db.collection('users').get();
      final batch = _db.batch();

      for (final userDoc in usersSnapshot.docs) {
        final notifRef = userDoc.reference.collection('notifications').doc();
        batch.set(notifRef, {
          'title': title,
          'body': body,
          'type': type,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'data': {'source': 'admin_panel'},
        });
      }

      await batch.commit();
      return usersSnapshot.docs.length;
    } finally {
      isSending.value = false;
    }
  }
}
