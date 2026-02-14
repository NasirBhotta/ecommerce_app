import 'package:ecommerce_app/features/admin/controllers/admin_payment_issues_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminPaymentIssuesPage extends StatelessWidget {
  const AdminPaymentIssuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminPaymentIssuesController());

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
          Row(
            children: [
              ElevatedButton(
                onPressed: controller.loadIssues,
                child: const Text('Refresh'),
              ),
              const SizedBox(width: 12),
              Text('Issues: ${controller.issues.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Issue ID')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Error')),
                  DataColumn(label: Text('Action')),
                ],
                rows:
                    controller.issues.map((doc) {
                      final data = doc.data();
                      final status = (data['status'] ?? 'open').toString();
                      return DataRow(
                        cells: [
                          DataCell(Text(doc.id)),
                          DataCell(Text((data['userId'] ?? '').toString())),
                          DataCell(Text((data['type'] ?? '').toString())),
                          DataCell(Text(status)),
                          DataCell(
                            SizedBox(
                              width: 300,
                              child: Text(
                                (data['errorMessage'] ?? '').toString(),
                              ),
                            ),
                          ),
                          DataCell(
                            TextButton(
                              onPressed:
                                  status == 'resolved'
                                      ? null
                                      : () async {
                                        await controller.resolveIssue(
                                          doc.id,
                                          'Resolved from admin panel',
                                        );
                                        Get.snackbar('Done', 'Issue resolved');
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
