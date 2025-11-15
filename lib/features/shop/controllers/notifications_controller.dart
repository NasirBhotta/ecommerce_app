import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  static NotificationsController get instance => Get.find();

  // Observable notifications list
  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;

  // Notification settings
  final orderUpdates = true.obs;
  final promotionalOffers = true.obs;
  final newArrivals = false.obs;
  final accountActivity = true.obs;
  final appUpdates = true.obs;
  final emailNotifications = true.obs;
  final smsNotifications = false.obs;
  final pushNotifications = true.obs;

  // Loading state
  final isLoading = false.obs;

  // Unread count
  int get unreadCount => notifications.where((n) => !n['isRead']).length;

  @override
  void onInit() {
    super.onInit();
    loadSampleData();
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      notifications[index]['isRead'] = true;
      notifications.refresh();
    }
  }

  // Mark all as read
  void markAllAsRead() {
    for (var notification in notifications) {
      notification['isRead'] = true;
    }
    notifications.refresh();

    Get.snackbar(
      'Success',
      'All notifications marked as read',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Delete notification
  void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n['id'] == notificationId);

    Get.snackbar(
      'Deleted',
      'Notification deleted',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Clear all notifications
  void clearAllNotifications() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All'),
        content: const Text(
          'Are you sure you want to delete all notifications?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              notifications.clear();
              Get.back();
              Get.snackbar(
                'Cleared',
                'All notifications cleared',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Handle notification tap
  void onNotificationTap(Map<String, dynamic> notification) {
    markAsRead(notification['id']);

    // Navigate based on notification type
    switch (notification['type']) {
      case 'order':
        Get.snackbar('Navigate', 'Opening order details...');
        // Get.toNamed('/order-details', arguments: notification['data']);
        break;
      case 'promotion':
        Get.snackbar('Navigate', 'Opening promotion...');
        // Get.toNamed('/promotion', arguments: notification['data']);
        break;
      case 'account':
        Get.snackbar('Navigate', 'Opening account settings...');
        // Get.toNamed('/account');
        break;
      default:
        break;
    }
  }

  // Toggle notification settings
  void toggleOrderUpdates(bool value) {
    orderUpdates.value = value;
    _showSettingUpdated('Order Updates', value);
  }

  void togglePromotionalOffers(bool value) {
    promotionalOffers.value = value;
    _showSettingUpdated('Promotional Offers', value);
  }

  void toggleNewArrivals(bool value) {
    newArrivals.value = value;
    _showSettingUpdated('New Arrivals', value);
  }

  void toggleAccountActivity(bool value) {
    accountActivity.value = value;
    _showSettingUpdated('Account Activity', value);
  }

  void toggleAppUpdates(bool value) {
    appUpdates.value = value;
    _showSettingUpdated('App Updates', value);
  }

  void toggleEmailNotifications(bool value) {
    emailNotifications.value = value;
    _showSettingUpdated('Email Notifications', value);
  }

  void toggleSmsNotifications(bool value) {
    smsNotifications.value = value;
    _showSettingUpdated('SMS Notifications', value);
  }

  void togglePushNotifications(bool value) {
    pushNotifications.value = value;
    _showSettingUpdated('Push Notifications', value);
  }

  void _showSettingUpdated(String setting, bool enabled) {
    Get.snackbar(
      'Settings Updated',
      '$setting ${enabled ? "enabled" : "disabled"}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Get notification icon
  String getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return 'shopping_bag';
      case 'promotion':
        return 'discount';
      case 'account':
        return 'person';
      case 'delivery':
        return 'truck';
      case 'payment':
        return 'credit_card';
      default:
        return 'notifications';
    }
  }

  // Get time ago string
  String getTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }

  // Load sample data
  void loadSampleData() {
    if (notifications.isEmpty) {
      notifications.addAll([
        {
          'id': '1',
          'type': 'order',
          'title': 'Order Shipped',
          'message':
              'Your order #ORD-2024-002 has been shipped and is on its way!',
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
          'isRead': false,
          'data': {'orderId': 'ORD-2024-002'},
        },
        {
          'id': '2',
          'type': 'promotion',
          'title': 'Flash Sale Alert!',
          'message': 'Get 50% off on selected items. Sale ends in 24 hours!',
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(hours: 5))
                  .toIso8601String(),
          'isRead': false,
          'data': {'promoId': 'FLASH50'},
        },
        {
          'id': '3',
          'type': 'order',
          'title': 'Order Delivered',
          'message':
              'Your order #ORD-2024-001 has been delivered. Thank you for shopping!',
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
          'isRead': true,
          'data': {'orderId': 'ORD-2024-001'},
        },
        {
          'id': '4',
          'type': 'account',
          'title': 'Security Alert',
          'message':
              'New login detected from Chrome on Windows. If this wasn\'t you, please secure your account.',
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(days: 2))
                  .toIso8601String(),
          'isRead': true,
          'data': {},
        },
        {
          'id': '5',
          'type': 'delivery',
          'title': 'Out for Delivery',
          'message':
              'Your order #ORD-2024-002 is out for delivery. Expected today by 6 PM.',
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(hours: 3))
                  .toIso8601String(),
          'isRead': false,
          'data': {'orderId': 'ORD-2024-002'},
        },
      ]);
    }
  }

  // Firebase methods (commented for now)

  // Future<void> loadNotificationsFromFirebase(String userId) async {
  //   try {
  //     isLoading.value = true;
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('notifications')
  //         .orderBy('timestamp', descending: true)
  //         .limit(50)
  //         .get();
  //
  //     notifications.value = snapshot.docs
  //         .map((doc) => {...doc.data(), 'id': doc.id})
  //         .toList();
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to load notifications');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<void> updateNotificationSettings(String userId) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .update({
  //       'notificationSettings': {
  //         'orderUpdates': orderUpdates.value,
  //         'promotionalOffers': promotionalOffers.value,
  //         'newArrivals': newArrivals.value,
  //         'accountActivity': accountActivity.value,
  //         'appUpdates': appUpdates.value,
  //         'emailNotifications': emailNotifications.value,
  //         'smsNotifications': smsNotifications.value,
  //         'pushNotifications': pushNotifications.value,
  //       },
  //     });
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to update settings');
  //   }
  // }

  // Stream notifications
  // Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('notifications')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .map((snapshot) =>
  //           snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  // }
}
