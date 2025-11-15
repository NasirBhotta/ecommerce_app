import 'package:ecommerce_app/features/shop/controllers/notifications_controller.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () =>
                controller.notifications.isNotEmpty
                    ? PopupMenuButton(
                      itemBuilder:
                          (_) => [
                            const PopupMenuItem(
                              value: 'mark_all',
                              child: Text('Mark all as read'),
                            ),
                            const PopupMenuItem(
                              value: 'clear',
                              child: Text('Clear all'),
                            ),
                          ],
                      onSelected: (value) {
                        if (value == 'mark_all') {
                          controller.markAllAsRead();
                        } else {
                          controller.clearAllNotifications();
                        }
                      },
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const Center(child: Text('No notifications'));
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (_, index) {
            final notification = controller.notifications[index];
            final isRead = notification['isRead'] ?? false;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: BColors.primary.withOpacity(0.1),
                child: Icon(Iconsax.notification, color: BColors.primary),
              ),
              title: Text(
                notification['title'],
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification['message']),
                  const SizedBox(height: 4),
                  Text(
                    controller.getTimeAgo(notification['timestamp']),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed:
                    () => controller.deleteNotification(notification['id']),
              ),
              onTap: () => controller.onNotificationTap(notification),
            );
          },
        );
      }),
    );
  }
}
