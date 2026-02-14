import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/controllers/admin_audit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAuditPage extends StatelessWidget {
  const AdminAuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminAuditController());

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
          TextField(
            onChanged: controller.setQuery,
            decoration: const InputDecoration(
              labelText: 'Search action/resource/actor',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text('Logs: ${controller.logs.length}'),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Time')),
                  DataColumn(label: Text('Actor')),
                  DataColumn(label: Text('Action')),
                  DataColumn(label: Text('Resource')),
                  DataColumn(label: Text('Resource ID')),
                ],
                rows:
                    controller.logs.map((doc) {
                      final d = doc.data();
                      final ts = d['createdAt'];
                      final time =
                          ts is Timestamp ? ts.toDate().toIso8601String() : '';
                      return DataRow(
                        cells: [
                          DataCell(Text(time)),
                          DataCell(
                            Text('${d['actorEmail'] ?? d['actorUid'] ?? ''}'),
                          ),
                          DataCell(Text('${d['action'] ?? ''}')),
                          DataCell(Text('${d['resourceType'] ?? ''}')),
                          DataCell(Text('${d['resourceId'] ?? ''}')),
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
