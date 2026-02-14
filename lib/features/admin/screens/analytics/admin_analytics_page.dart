import 'package:ecommerce_app/features/admin/controllers/admin_analytics_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminAnalyticsController());

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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _metric('Total Users', '${controller.totalUsers.value}'),
              _metric('Total Orders', '${controller.totalOrders.value}'),
              _metric(
                'Revenue',
                '\$${controller.totalRevenue.value.toStringAsFixed(2)}',
              ),
              _metric('Repeat Users', '${controller.repeatUsers.value}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Daily Orders (Last 14 Days)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Orders')),
                DataColumn(label: Text('Revenue')),
              ],
              rows:
                  controller.ordersByDay.entries.map((e) {
                    final rev = controller.revenueByDay[e.key] ?? 0;
                    return DataRow(
                      cells: [
                        DataCell(Text(e.key)),
                        DataCell(Text('${e.value}')),
                        DataCell(Text('\$${rev.toStringAsFixed(2)}')),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _metric(String title, String value) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
