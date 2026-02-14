import 'package:ecommerce_app/features/admin/controllers/admin_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.loadDashboard,
        child: ListView(
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
                _MetricCard(
                  title: 'Users',
                  value: '${controller.totalUsers.value}',
                ),
                _MetricCard(
                  title: 'Orders',
                  value: '${controller.totalOrders.value}',
                ),
                _MetricCard(
                  title: 'Pending Orders',
                  value: '${controller.pendingOrders.value}',
                ),
                _MetricCard(
                  title: 'Revenue',
                  value:
                      '\$${controller.totalRevenue.value.toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Recent Orders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (controller.recentOrders.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No order data found for dashboard.'),
                ),
              )
            else
              Card(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows:
                      controller.recentOrders
                          .map(
                            (o) => DataRow(
                              cells: [
                                DataCell(Text(o.id)),
                                DataCell(Text(o.userId)),
                                DataCell(Text(o.status)),
                                DataCell(
                                  Text('\$${o.totalAmount.toStringAsFixed(2)}'),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
