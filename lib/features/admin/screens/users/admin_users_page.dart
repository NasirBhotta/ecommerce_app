import 'package:ecommerce_app/features/admin/controllers/admin_users_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminUsersController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Total users: ${controller.users.length}'),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('UID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Active')),
                ],
                rows:
                    controller.users.map((doc) {
                      final data = doc.data();
                      final uid = doc.id;
                      final role = (data['role'] ?? 'user').toString();
                      final isActive = (data['isActive'] ?? true) == true;

                      return DataRow(
                        cells: [
                          DataCell(Text(uid)),
                          DataCell(Text((data['fullName'] ?? '').toString())),
                          DataCell(Text((data['email'] ?? '').toString())),
                          DataCell(
                            DropdownButton<String>(
                              value: role,
                              items: const [
                                DropdownMenuItem(
                                  value: 'user',
                                  child: Text('user'),
                                ),
                                DropdownMenuItem(
                                  value: 'admin',
                                  child: Text('admin'),
                                ),
                                DropdownMenuItem(
                                  value: 'super_admin',
                                  child: Text('super_admin'),
                                ),
                              ],
                              onChanged: (v) async {
                                if (v == null) return;
                                await controller.updateUserRole(uid, v);
                                Get.snackbar('Updated', 'Role changed to $v');
                              },
                            ),
                          ),
                          DataCell(
                            Switch(
                              value: isActive,
                              onChanged: (v) async {
                                await controller.updateUserStatus(uid, v);
                                Get.snackbar('Updated', 'User status changed');
                              },
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
