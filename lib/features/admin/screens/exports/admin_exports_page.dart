import 'package:ecommerce_app/features/admin/controllers/admin_exports_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminExportsPage extends StatelessWidget {
  const AdminExportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminExportsController());

    return Obx(() {
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
              DropdownButton<String>(
                value: controller.exportType.value,
                items:
                    controller.types
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (v) {
                  if (v != null) {
                    controller.exportType.value = v;
                  }
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed:
                    controller.isLoading.value ? null : controller.generateCsv,
                child: const Text('Generate CSV'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed:
                    controller.csvData.value.isEmpty
                        ? null
                        : () async {
                          await controller.copyCsv();
                          Get.snackbar('Copied', 'CSV copied to clipboard');
                        },
                child: const Text('Copy CSV'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: TextEditingController(text: controller.csvData.value),
            minLines: 20,
            maxLines: 20,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'CSV Output',
            ),
          ),
        ],
      );
    });
  }
}
