import 'package:ecommerce_app/features/admin/controllers/admin_alerts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAlertsPage extends StatelessWidget {
  const AdminAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminAlertsController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage.value.isNotEmpty)
            Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          Row(
            children: [
              ElevatedButton(
                onPressed: controller.loadAlerts,
                child: const Text('Refresh'),
              ),
              const SizedBox(width: 12),
              Text('Open Alerts: ${controller.alerts.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Severity')),
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Message')),
                ],
                rows:
                    controller.alerts
                        .map(
                          (a) => DataRow(
                            cells: [
                              DataCell(Text(a['type'] ?? '')),
                              DataCell(Text(a['severity'] ?? '')),
                              DataCell(Text(a['id'] ?? '')),
                              DataCell(
                                SizedBox(
                                  width: 520,
                                  child: Text(a['message'] ?? ''),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ],
      );
    });
  }
}
