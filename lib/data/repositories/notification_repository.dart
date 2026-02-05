import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/data/repositories/auth_repo.dart';
import 'package:ecommerce_app/features/shop/models/notification_model.dart';
import 'package:get/get.dart';

class NotificationRepository extends GetxController {
  static NotificationRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthenticationRepository _auth = AuthenticationRepository.instance;

  String get _userId => _auth.authUser?.uid ?? '';

  Stream<List<NotificationModel>> streamNotifications({int limit = 50}) {
    final userId = _userId;
    if (userId.isEmpty) return const Stream.empty();

    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => NotificationModel.fromSnapshot(doc))
                  .toList(),
        );
  }

  Future<void> createNotification(NotificationModel notification) async {
    final userId = _userId;
    if (userId.isEmpty) throw 'User not authenticated';

    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notification.toJson());
  }

  Future<void> markAsRead(String notificationId) async {
    final userId = _userId;
    if (userId.isEmpty) throw 'User not authenticated';

    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true, 'readAt': FieldValue.serverTimestamp()});
  }

  Future<void> markAllAsRead() async {
    final userId = _userId;
    if (userId.isEmpty) throw 'User not authenticated';

    final snapshot =
        await _db
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .where('isRead', isEqualTo: false)
            .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final userId = _userId;
    if (userId.isEmpty) throw 'User not authenticated';

    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> clearAll() async {
    final userId = _userId;
    if (userId.isEmpty) throw 'User not authenticated';

    final snapshot =
        await _db
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<void> saveFcmToken(String token, {String? platform}) async {
    final userId = _userId;
    if (userId.isEmpty) return;

    final tokenRef = _db
        .collection('users')
        .doc(userId)
        .collection('fcm_tokens')
        .doc(token);

    await tokenRef.set({
      'token': token,
      'platform': platform ?? 'unknown',
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFcmToken(String token) async {
    final userId = _userId;
    if (userId.isEmpty) return;

    await _db
        .collection('users')
        .doc(userId)
        .collection('fcm_tokens')
        .doc(token)
        .delete();
  }
}
