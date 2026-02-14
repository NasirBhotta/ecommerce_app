import 'package:ecommerce_app/features/admin/controllers/admin_notifications_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final _userId = TextEditingController();
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _userId.dispose();
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminNotificationsController());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Notification Center',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _userId,
                  decoration: const InputDecoration(
                    labelText: 'User ID (empty means broadcast)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _body,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed:
                            controller.isSending.value
                                ? null
                                : () async {
                                  if (_userId.text.trim().isEmpty) {
                                    Get.snackbar('Missing', 'Enter a user id');
                                    return;
                                  }
                                  await controller.sendToUser(
                                    userId: _userId.text.trim(),
                                    title: _title.text.trim(),
                                    body: _body.text.trim(),
                                  );
                                  Get.snackbar(
                                    'Sent',
                                    'Notification sent to user',
                                  );
                                },
                        child: const Text('Send To User'),
                      ),
                      ElevatedButton(
                        onPressed:
                            controller.isSending.value
                                ? null
                                : () async {
                                  final count = await controller.sendBroadcast(
                                    title: _title.text.trim(),
                                    body: _body.text.trim(),
                                  );
                                  Get.snackbar(
                                    'Broadcast sent',
                                    'Users targeted: $count',
                                  );
                                },
                        child: const Text('Broadcast'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
