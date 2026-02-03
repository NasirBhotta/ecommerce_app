import 'dart:async';

import 'package:ecommerce_app/data/repositories/notification_repository.dart';
import 'package:ecommerce_app/data/repositories/user_repo.dart';
import 'package:ecommerce_app/features/shop/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  static NotificationsController get instance => Get.find();

  final NotificationRepository _repo = Get.put(NotificationRepository());
  final UserRepository _userRepo = Get.put(UserRepository());

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  final orderUpdates = true.obs;
  final promotionalOffers = true.obs;
  final newArrivals = false.obs;
  final accountActivity = true.obs;
  final appUpdates = true.obs;
  final emailNotifications = true.obs;
  final smsNotifications = false.obs;
  final pushNotifications = true.obs;

  final isLoading = false.obs;
  StreamSubscription<List<NotificationModel>>? _subscription;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _listenNotifications();
    _loadSettings();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _listenNotifications() {
    isLoading.value = true;
    _subscription = _repo.streamNotifications().listen(
      (list) {
        notifications.assignAll(list);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to load notifications');
      },
    );
  }

  Future<void> _loadSettings() async {
    try {
      final data = await _userRepo.fetchUserDetails();
      final settings =
          data['notificationSettings'] as Map<String, dynamic>? ?? {};

      orderUpdates.value = settings['orderUpdates'] ?? orderUpdates.value;
      promotionalOffers.value =
          settings['promotionalOffers'] ?? promotionalOffers.value;
      newArrivals.value = settings['newArrivals'] ?? newArrivals.value;
      accountActivity.value =
          settings['accountActivity'] ?? accountActivity.value;
      appUpdates.value = settings['appUpdates'] ?? appUpdates.value;
      emailNotifications.value =
          settings['emailNotifications'] ?? emailNotifications.value;
      smsNotifications.value =
          settings['smsNotifications'] ?? smsNotifications.value;
      pushNotifications.value =
          settings['pushNotifications'] ?? pushNotifications.value;
    } catch (_) {}
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repo.markAsRead(notificationId);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _repo.markAllAsRead();
      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to mark all as read',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repo.deleteNotification(notificationId);
      Get.snackbar(
        'Deleted',
        'Notification deleted',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to delete notification',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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
            onPressed: () async {
              Get.back();
              try {
                await _repo.clearAll();
                Get.snackbar(
                  'Cleared',
                  'All notifications cleared',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (_) {
                Get.snackbar(
                  'Error',
                  'Failed to clear notifications',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void onNotificationTap(NotificationModel notification) {
    markAsRead(notification.id);

    switch (notification.type) {
      case 'order':
        Get.snackbar('Navigate', 'Opening order details...');
        break;
      case 'promotion':
        Get.snackbar('Navigate', 'Opening promotion...');
        break;
      case 'account':
        Get.snackbar('Navigate', 'Opening account settings...');
        break;
      default:
        break;
    }
  }

  void toggleOrderUpdates(bool value) {
    orderUpdates.value = value;
    _showSettingUpdated('Order Updates', value);
    _persistSettings();
  }

  void togglePromotionalOffers(bool value) {
    promotionalOffers.value = value;
    _showSettingUpdated('Promotional Offers', value);
    _persistSettings();
  }

  void toggleNewArrivals(bool value) {
    newArrivals.value = value;
    _showSettingUpdated('New Arrivals', value);
    _persistSettings();
  }

  void toggleAccountActivity(bool value) {
    accountActivity.value = value;
    _showSettingUpdated('Account Activity', value);
    _persistSettings();
  }

  void toggleAppUpdates(bool value) {
    appUpdates.value = value;
    _showSettingUpdated('App Updates', value);
    _persistSettings();
  }

  void toggleEmailNotifications(bool value) {
    emailNotifications.value = value;
    _showSettingUpdated('Email Notifications', value);
    _persistSettings();
  }

  void toggleSmsNotifications(bool value) {
    smsNotifications.value = value;
    _showSettingUpdated('SMS Notifications', value);
    _persistSettings();
  }

  void togglePushNotifications(bool value) {
    pushNotifications.value = value;
    _showSettingUpdated('Push Notifications', value);
    _persistSettings();
  }

  Future<void> _persistSettings() async {
    try {
      await _userRepo.updateNotificationSettings({
        'orderUpdates': orderUpdates.value,
        'promotionalOffers': promotionalOffers.value,
        'newArrivals': newArrivals.value,
        'accountActivity': accountActivity.value,
        'appUpdates': appUpdates.value,
        'emailNotifications': emailNotifications.value,
        'smsNotifications': smsNotifications.value,
        'pushNotifications': pushNotifications.value,
      });
    } catch (_) {}
  }

  void _showSettingUpdated(String setting, bool enabled) {
    Get.snackbar(
      'Settings Updated',
      '$setting ${enabled ? "enabled" : "disabled"}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

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

  String getTimeAgo(DateTime? date) {
    if (date == null) return '';

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
  }
}
