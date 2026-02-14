import 'package:ecommerce_app/features/admin/controllers/admin_orders_controller.dart';
import 'package:ecommerce_app/features/admin/models/admin_order_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminOrdersController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: controller.selectedFilter.value,
                items:
                    controller.statusFilters
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.changeFilter(value);
                  }
                },
              ),
              const SizedBox(width: 12),
              Text('Total: ${controller.orders.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('User ID')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Payment')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Action')),
                ],
                rows:
                    controller.orders
                        .map((o) => _row(context, controller, o))
                        .toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  DataRow _row(
    BuildContext context,
    AdminOrdersController controller,
    AdminOrderItem order,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(order.id)),
        DataCell(Text(order.userId)),
        DataCell(Text(order.status)),
        DataCell(Text(order.paymentMethod)),
        DataCell(Text('\$${order.totalAmount.toStringAsFixed(2)}')),
        DataCell(
          PopupMenuButton<String>(
            onSelected: (status) async {
              await controller.updateStatus(order, status);
              Get.snackbar('Updated', 'Order ${order.id} marked as $status');
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'Processing', child: Text('Processing')),
                  PopupMenuItem(value: 'Shipped', child: Text('Shipped')),
                  PopupMenuItem(value: 'Delivered', child: Text('Delivered')),
                  PopupMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                ],
            child: const Icon(Icons.edit),
          ),
        ),
      ],
    );
  }
}
