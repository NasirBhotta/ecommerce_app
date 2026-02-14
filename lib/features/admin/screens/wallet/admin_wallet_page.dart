import 'package:ecommerce_app/features/admin/controllers/admin_wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminWalletPage extends StatelessWidget {
  const AdminWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminWalletController());

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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DropdownButton<String>(
                value: controller.statusFilter.value,
                items:
                    controller.statuses
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text('Status: $e'),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  if (v != null) {
                    controller.setStatusFilter(v);
                  }
                },
              ),
              DropdownButton<String>(
                value: controller.typeFilter.value,
                items:
                    controller.types
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text('Type: $e'),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  if (v != null) {
                    controller.setTypeFilter(v);
                  }
                },
              ),
              Text('Rows: ${controller.entries.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Description')),
                ],
                rows:
                    controller.entries
                        .map(
                          (e) => DataRow(
                            cells: [
                              DataCell(Text(e.userId)),
                              DataCell(Text(e.type)),
                              DataCell(Text(e.status)),
                              DataCell(
                                Text('\$${e.amount.toStringAsFixed(2)}'),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 380,
                                  child: Text(e.description),
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
