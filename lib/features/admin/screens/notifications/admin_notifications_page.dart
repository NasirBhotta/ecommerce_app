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
  final _selectedMode = 'targeted'.obs;
  final _selectedType = 'admin'.obs;
  final _lastAudienceCount = 0.obs;

  static const _types = ['admin', 'promotion', 'system'];

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
      padding: const EdgeInsets.all(20),
      children: [
        _Header(
          onRefresh: () {
            _userId.clear();
            _title.clear();
            _body.clear();
            _selectedMode.value = 'targeted';
            _selectedType.value = 'admin';
            _lastAudienceCount.value = 0;
          },
        ),
        const SizedBox(height: 14),
        Obx(
          () => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                title: 'Mode',
                value: _selectedMode.value == 'broadcast'
                    ? 'Broadcast'
                    : 'Single User',
                hint: 'Current delivery target',
                icon: Icons.send_outlined,
                accent: const Color(0xFF2563EB),
              ),
              _MetricCard(
                title: 'Type',
                value: _selectedType.value,
                hint: 'Notification category',
                icon: Icons.category_outlined,
                accent: const Color(0xFF7C3AED),
              ),
              _MetricCard(
                title: 'Last Broadcast Reach',
                value: '${_lastAudienceCount.value}',
                hint: 'Users targeted in last broadcast',
                icon: Icons.people_outline,
                accent: const Color(0xFF059669),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ComposerCard(
          userIdController: _userId,
          titleController: _title,
          bodyController: _body,
          selectedMode: _selectedMode,
          selectedType: _selectedType,
          types: _types,
          onTemplateTap: (title, body, type) {
            _title.text = title;
            _body.text = body;
            _selectedType.value = type;
          },
          onSendToUser: () async {
            final userId = _userId.text.trim();
            final title = _title.text.trim();
            final body = _body.text.trim();

            if (userId.isEmpty) {
              Get.snackbar(
                'Validation',
                'User ID is required for targeted mode',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            if (title.isEmpty || body.isEmpty) {
              Get.snackbar(
                'Validation',
                'Title and message are required',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            await controller.sendToUser(
              userId: userId,
              title: title,
              body: body,
              type: _selectedType.value,
            );

            Get.snackbar(
              'Sent',
              'Notification sent to user',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          onBroadcast: () async {
            final title = _title.text.trim();
            final body = _body.text.trim();

            if (title.isEmpty || body.isEmpty) {
              Get.snackbar(
                'Validation',
                'Title and message are required',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            final confirmed = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Confirm Broadcast'),
                content: const Text(
                  'Send this notification to all users?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('Send'),
                  ),
                ],
              ),
            );

            if (confirmed != true) return;

            final count = await controller.sendBroadcast(
              title: title,
              body: body,
              type: _selectedType.value,
            );
            _lastAudienceCount.value = count;

            Get.snackbar(
              'Broadcast Sent',
              'Users targeted: $count',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          isSending: controller.isSending,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFDB2777), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;

          final summary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification Center',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Compose and send targeted or broadcast messages',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          );

          final clearButton = FilledButton.icon(
            onPressed: onRefresh,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7C3AED),
            ),
            icon: const Icon(Icons.cleaning_services_outlined),
            label: const Text('Clear Form'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 10),
                clearButton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              clearButton,
            ],
          );
        },
      ),
    );
  }
}

class _ComposerCard extends StatelessWidget {
  const _ComposerCard({
    required this.userIdController,
    required this.titleController,
    required this.bodyController,
    required this.selectedMode,
    required this.selectedType,
    required this.types,
    required this.onTemplateTap,
    required this.onSendToUser,
    required this.onBroadcast,
    required this.isSending,
  });

  final TextEditingController userIdController;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final RxString selectedMode;
  final RxString selectedType;
  final List<String> types;
  final void Function(String title, String body, String type) onTemplateTap;
  final Future<void> Function() onSendToUser;
  final Future<void> Function() onBroadcast;
  final RxBool isSending;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compose Message',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'targeted',
                    icon: Icon(Icons.person_outline),
                    label: Text('Single User'),
                  ),
                  ButtonSegment(
                    value: 'broadcast',
                    icon: Icon(Icons.campaign_outlined),
                    label: Text('Broadcast'),
                  ),
                ],
                selected: {selectedMode.value},
                onSelectionChanged: (selection) {
                  selectedMode.value = selection.first;
                },
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => DropdownButtonFormField<String>(
                value: selectedType.value,
                decoration: const InputDecoration(
                  labelText: 'Notification Type',
                  border: OutlineInputBorder(),
                ),
                items: types
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedType.value = value;
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: selectedMode.value == 'targeted'
                    ? TextField(
                        key: const ValueKey('user-id'),
                        controller: userIdController,
                        decoration: const InputDecoration(
                          labelText: 'User ID',
                          hintText: 'Enter target user document ID',
                          border: OutlineInputBorder(),
                        ),
                      )
                    : Container(
                        key: const ValueKey('broadcast-note'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Broadcast mode selected. Message will be sent to all users.',
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Quick Templates',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('Order Update'),
                  onPressed: () => onTemplateTap(
                    'Order Update',
                    'Your order status has been updated. Check your orders screen for details.',
                    'admin',
                  ),
                ),
                ActionChip(
                  label: const Text('Promo Offer'),
                  onPressed: () => onTemplateTap(
                    'Special Offer',
                    'New discount is now available. Open the app to claim it before it ends.',
                    'promotion',
                  ),
                ),
                ActionChip(
                  label: const Text('System Notice'),
                  onPressed: () => onTemplateTap(
                    'Maintenance Notice',
                    'Scheduled maintenance will happen shortly. Some features may be unavailable.',
                    'system',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: isSending.value || selectedMode.value != 'targeted'
                        ? null
                        : onSendToUser,
                    icon: isSending.value
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_outline),
                    label: const Text('Send To User'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: isSending.value || selectedMode.value != 'broadcast'
                        ? null
                        : onBroadcast,
                    icon: isSending.value
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.campaign_outlined),
                    label: const Text('Send Broadcast'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.hint,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final String hint;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                hint,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
