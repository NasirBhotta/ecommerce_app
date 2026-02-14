import 'package:ecommerce_app/features/admin/controllers/admin_orders_controller.dart';
import 'package:ecommerce_app/features/admin/models/admin_order_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminOrdersController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final totalAmount = controller.orders.fold<double>(
        0,
        (sum, o) => sum + o.totalAmount,
      );
      final avgAmount = controller.orders.isEmpty
          ? 0.0
          : totalAmount / controller.orders.length;

      return RefreshIndicator(
        onRefresh: controller.loadOrders,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _OrdersHeader(
              totalOrders: controller.orders.length,
              selectedFilter: controller.selectedFilter.value,
              onRefresh: controller.loadOrders,
            ),
            const SizedBox(height: 14),
            if (controller.errorMessage.value.isNotEmpty)
              _ErrorBanner(message: controller.errorMessage.value),
            _FilterBar(
              selectedValue: controller.selectedFilter.value,
              values: controller.statusFilters,
              onChanged: (value) async {
                if (value != null) {
                  await controller.changeFilter(value);
                }
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  title: 'Visible Orders',
                  value: '${controller.orders.length}',
                  hint: 'Based on current filter',
                  icon: Icons.receipt_long_outlined,
                  accent: const Color(0xFF2563EB),
                ),
                _MetricCard(
                  title: 'Total Amount',
                  value: _currency(totalAmount),
                  hint: 'Sum of visible orders',
                  icon: Icons.payments_outlined,
                  accent: const Color(0xFF059669),
                ),
                _MetricCard(
                  title: 'Average Ticket',
                  value: _currency(avgAmount),
                  hint: 'Average order amount',
                  icon: Icons.analytics_outlined,
                  accent: const Color(0xFFD97706),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _OrdersTableCard(
              orders: controller.orders,
              onStatusUpdate: (order, status) async {
                await controller.updateStatus(order, status);
                Get.snackbar(
                  'Updated',
                  'Order ${order.id} marked as $status',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      );
    });
  }

  static String _currency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({
    required this.totalOrders,
    required this.selectedFilter,
    required this.onRefresh,
  });

  final int totalOrders;
  final String selectedFilter;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final summary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Operations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$totalOrders orders shown | Filter: $selectedFilter',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          );

          final refreshButton = FilledButton.icon(
            onPressed: onRefresh,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2563EB),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 10),
                refreshButton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              refreshButton,
            ],
          );
        },
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFB91C1C),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedValue,
    required this.values,
    required this.onChanged,
  });

  final String selectedValue;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            Text(
              'Status Filter',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(),
                ),
                items: values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.hint,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final String hint;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                hint,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersTableCard extends StatelessWidget {
  const _OrdersTableCard({
    required this.orders,
    required this.onStatusUpdate,
  });

  final List<AdminOrderItem> orders;
  final Future<void> Function(AdminOrderItem order, String status) onStatusUpdate;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders List',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (orders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No orders found.')),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  columns: const [
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('User ID')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Payment')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: orders
                      .map((o) => _row(context, o, onStatusUpdate))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DataRow _row(
    BuildContext context,
    AdminOrderItem order,
    Future<void> Function(AdminOrderItem order, String status) onStatusUpdate,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(order.id)),
        DataCell(Text(order.userId)),
        DataCell(
          Text(
            order.orderDate.millisecondsSinceEpoch > 0
                ? DateFormat('dd MMM yyyy').format(order.orderDate)
                : '-',
          ),
        ),
        DataCell(_StatusChip(status: order.status)),
        DataCell(Text(order.paymentMethod.isEmpty ? '-' : order.paymentMethod)),
        DataCell(
          Text(NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(order.totalAmount)),
        ),
        DataCell(
          PopupMenuButton<String>(
            tooltip: 'Update Status',
            onSelected: (status) async {
              await onStatusUpdate(order, status);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Processing', child: Text('Processing')),
              PopupMenuItem(value: 'Shipped', child: Text('Shipped')),
              PopupMenuItem(value: 'Delivered', child: Text('Delivered')),
              PopupMenuItem(value: 'Cancelled', child: Text('Cancelled')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 16),
                  SizedBox(width: 6),
                  Text('Change'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    late final Color color;
    switch (status.toLowerCase()) {
      case 'processing':
        color = const Color(0xFF2563EB);
        break;
      case 'shipped':
        color = const Color(0xFF0891B2);
        break;
      case 'delivered':
        color = const Color(0xFF059669);
        break;
      case 'cancelled':
      case 'canceled':
        color = const Color(0xFFDC2626);
        break;
      default:
        color = const Color(0xFF6B7280);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
