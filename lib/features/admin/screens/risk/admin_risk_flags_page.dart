import 'package:ecommerce_app/features/admin/controllers/admin_risk_flags_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminRiskFlagsPage extends StatelessWidget {
  const AdminRiskFlagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminRiskFlagsController());
    final userIdController = TextEditingController();
    final reasonController = TextEditingController();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Risk Flag',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: userIdController,
                    decoration: const InputDecoration(labelText: 'User ID'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(labelText: 'Reason'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await controller.createFlag(
                        userId: userIdController.text.trim(),
                        reason: reasonController.text.trim(),
                        severity: 'medium',
                      );
                      userIdController.clear();
                      reasonController.clear();
                      Get.snackbar('Created', 'Risk flag added');
                    },
                    child: const Text('Create Flag'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Severity')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Reason')),
                  DataColumn(label: Text('Action')),
                ],
                rows:
                    controller.flags.map((doc) {
                      final data = doc.data();
                      final status = (data['status'] ?? 'open').toString();

                      return DataRow(
                        cells: [
                          DataCell(Text((data['userId'] ?? '').toString())),
                          DataCell(Text((data['severity'] ?? '').toString())),
                          DataCell(Text(status)),
                          DataCell(
                            SizedBox(
                              width: 320,
                              child: Text((data['reason'] ?? '').toString()),
                            ),
                          ),
                          DataCell(
                            TextButton(
                              onPressed:
                                  status == 'resolved'
                                      ? null
                                      : () async {
                                        await controller.resolveFlag(
                                          doc.id,
                                          'Resolved by admin',
                                        );
                                        Get.snackbar('Done', 'Flag resolved');
                                      },
                              child: const Text('Resolve'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }
}
