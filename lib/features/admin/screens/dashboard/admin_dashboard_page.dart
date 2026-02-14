import 'package:ecommerce_app/features/admin/controllers/admin_dashboard_controller.dart';
import 'package:ecommerce_app/features/admin/models/admin_order_item.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1100;
            final chartWidth =
                isDesktop
                    ? (constraints.maxWidth - 56) / 3
                    : constraints.maxWidth;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _DashboardHero(
                  totalRevenue: controller.totalRevenue.value,
                  totalOrders: controller.totalOrders.value,
                  pendingOrders: controller.pendingOrders.value,
                  onRefresh: controller.loadDashboard,
                ),
                const SizedBox(height: 16),
                if (controller.errorMessage.value.isNotEmpty)
                  _ErrorBanner(message: controller.errorMessage.value),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      title: 'Total Users',
                      value: '${controller.totalUsers.value}',
                      hint: 'All registered accounts',
                      icon: Icons.group_outlined,
                      accent: const Color(0xFF2563EB),
                    ),
                    _MetricCard(
                      title: 'Total Orders',
                      value: '${controller.totalOrders.value}',
                      hint: 'Orders across all channels',
                      icon: Icons.shopping_bag_outlined,
                      accent: const Color(0xFF0891B2),
                    ),
                    _MetricCard(
                      title: 'Pending Orders',
                      value: '${controller.pendingOrders.value}',
                      hint: 'Processing + Shipped',
                      icon: Icons.local_shipping_outlined,
                      accent: const Color(0xFFD97706),
                    ),
                    _MetricCard(
                      title: 'Avg Order Value',
                      value: _formatCurrency(
                        controller.averageOrderValue.value,
                      ),
                      hint: 'Revenue divided by orders',
                      icon: Icons.payments_outlined,
                      accent: const Color(0xFF059669),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: chartWidth,
                      child: _ChartCard(
                        title: 'Revenue Trend (7 Days)',
                        child: _RevenueLineChart(
                          values: controller.revenueLast7Days,
                          labels: controller.revenueLast7DaysLabels,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: chartWidth,
                      child: _ChartCard(
                        title: 'Order Status Breakdown',
                        child: _StatusBarChart(
                          statusCounts: controller.orderStatusCounts,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: chartWidth,
                      child: _ChartCard(
                        title: 'Payment Method Split',
                        child: _PaymentPieChart(
                          paymentCounts: controller.paymentMethodCounts,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _RecentOrdersCard(orders: controller.recentOrders),
              ],
            );
          },
        ),
      );
    });
  }

  static String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.totalRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.onRefresh,
  });

  final double totalRevenue;
  final int totalOrders;
  final int pendingOrders;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operations Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Revenue ${AdminDashboardPage._formatCurrency(totalRevenue)} | Orders $totalOrders | Pending $pendingOrders',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          );

          final button = FilledButton.icon(
            onPressed: onRefresh,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1D4ED8),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Data'),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 12), button],
            );
          }

          return Row(children: [Expanded(child: content), button]);
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFB91C1C)),
            ),
          ),
        ],
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
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 220, child: child),
          ],
        ),
      ),
    );
  }
}

class _RevenueLineChart extends StatelessWidget {
  const _RevenueLineChart({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const Center(child: Text('No revenue data yet'));
    }

    final maxY = values.reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (values.length - 1).toDouble(),
        minY: 0,
        maxY: maxY == 0 ? 100 : maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY == 0 ? 25 : (maxY / 4),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget:
                  (value, _) => Text(
                    NumberFormat.compactCurrency(symbol: '\$').format(value),
                    style: const TextStyle(fontSize: 10),
                  ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labels[index],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: const Color(0xFF2563EB),
            barWidth: 3,
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2563EB).withValues(alpha: 0.12),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _StatusBarChart extends StatelessWidget {
  const _StatusBarChart({required this.statusCounts});

  final Map<String, int> statusCounts;

  @override
  Widget build(BuildContext context) {
    if (statusCounts.isEmpty) {
      return const Center(child: Text('No status data yet'));
    }

    final entries = statusCounts.entries.take(6).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= entries.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    entries[i].key,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < entries.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value.toDouble(),
                  borderRadius: BorderRadius.circular(6),
                  width: 18,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PaymentPieChart extends StatelessWidget {
  const _PaymentPieChart({required this.paymentCounts});

  final Map<String, int> paymentCounts;

  @override
  Widget build(BuildContext context) {
    if (paymentCounts.isEmpty) {
      return const Center(child: Text('No payment data yet'));
    }

    final entries = paymentCounts.entries.take(5).toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    final palette = <Color>[
      const Color(0xFF2563EB),
      const Color(0xFF7C3AED),
      const Color(0xFF059669),
      const Color(0xFFE11D48),
      const Color(0xFFF59E0B),
    ];

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    color: palette[i % palette.length],
                    value: entries[i].value.toDouble(),
                    title:
                        '${((entries[i].value / (total == 0 ? 1 : total)) * 100).toStringAsFixed(0)}%',
                    radius: 52,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 130,
          child: ListView.separated(
            itemCount: entries.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              return Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: palette[i % palette.length],
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${entries[i].key} (${entries[i].value})',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentOrdersCard extends StatelessWidget {
  const _RecentOrdersCard({required this.orders});

  final List<AdminOrderItem> orders;

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
              'Recent Orders',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (orders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No order data found for dashboard.'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  columns: const [
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows:
                      orders
                          .map<DataRow>(
                            (o) => DataRow(
                              cells: [
                                DataCell(Text(o.id.toString())),
                                DataCell(Text(o.userId.toString())),
                                DataCell(
                                  Text(
                                    o.orderDate.millisecondsSinceEpoch > 0
                                        ? DateFormat(
                                          'dd MMM yyyy',
                                        ).format(o.orderDate)
                                        : '-',
                                  ),
                                ),
                                DataCell(
                                  _StatusChip(status: o.status.toString()),
                                ),
                                DataCell(
                                  Text(
                                    NumberFormat.currency(
                                      symbol: '\$',
                                      decimalDigits: 2,
                                    ).format(o.totalAmount),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                ),
              ),
          ],
        ),
      ),
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
