import 'package:ecommerce_app/features/admin/controllers/admin_wallet_controller.dart';
import 'package:ecommerce_app/features/admin/models/admin_wallet_entry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminWalletPage extends StatelessWidget {
  const AdminWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminWalletController());
    final query = ''.obs;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filtered = controller.entries.where((e) {
        final q = query.value.trim().toLowerCase();
        if (q.isEmpty) return true;
        return e.userId.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q) ||
            e.type.toLowerCase().contains(q) ||
            e.status.toLowerCase().contains(q);
      }).toList();

      final totalCredit = filtered
          .where((e) => e.type.toLowerCase() == 'credit')
          .fold<double>(0, (sum, e) => sum + e.amount);
      final totalDebit = filtered
          .where((e) => e.type.toLowerCase() == 'debit')
          .fold<double>(0, (sum, e) => sum + e.amount);
      final netFlow = totalCredit - totalDebit;

      return RefreshIndicator(
        onRefresh: controller.loadEntries,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _WalletHeader(
              rowCount: filtered.length,
              onRefresh: controller.loadEntries,
            ),
            const SizedBox(height: 14),
            if (controller.errorMessage.value.isNotEmpty)
              _ErrorBanner(message: controller.errorMessage.value),
            _FilterBar(
              statusValue: controller.statusFilter.value,
              typeValue: controller.typeFilter.value,
              statuses: controller.statuses,
              types: controller.types,
              onStatusChanged: (v) async {
                if (v != null) {
                  await controller.setStatusFilter(v);
                }
              },
              onTypeChanged: (v) async {
                if (v != null) {
                  await controller.setTypeFilter(v);
                }
              },
              onSearchChanged: (value) => query.value = value,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  title: 'Visible Rows',
                  value: '${filtered.length}',
                  hint: 'After status/type/search filters',
                  icon: Icons.list_alt_outlined,
                  accent: const Color(0xFF2563EB),
                ),
                _MetricCard(
                  title: 'Total Credit',
                  value: _currency(totalCredit),
                  hint: 'Credit entries in view',
                  icon: Icons.arrow_downward_rounded,
                  accent: const Color(0xFF059669),
                ),
                _MetricCard(
                  title: 'Total Debit',
                  value: _currency(totalDebit),
                  hint: 'Debit entries in view',
                  icon: Icons.arrow_upward_rounded,
                  accent: const Color(0xFFDC2626),
                ),
                _MetricCard(
                  title: 'Net Flow',
                  value: _currency(netFlow),
                  hint: 'Credit minus debit',
                  icon: Icons.show_chart_outlined,
                  accent: netFlow >= 0
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFFF59E0B),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _LedgerTableCard(entries: filtered),
          ],
        ),
      );
    });
  }

  static String _currency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.rowCount, required this.onRefresh});

  final int rowCount;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF2563EB)],
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
                'Wallet Ledger',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '$rowCount ledger entries visible',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          );

          final refresh = FilledButton.icon(
            onPressed: onRefresh,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F766E),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [summary, const SizedBox(height: 10), refresh],
            );
          }

          return Row(
            children: [Expanded(child: summary), refresh],
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
    required this.statusValue,
    required this.typeValue,
    required this.statuses,
    required this.types,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onSearchChanged,
  });

  final String statusValue;
  final String typeValue;
  final List<String> statuses;
  final List<String> types;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String> onSearchChanged;

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
          spacing: 12,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                value: statusValue,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: statuses
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onStatusChanged,
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                value: typeValue,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: types
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onTypeChanged,
              ),
            ),
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: onSearchChanged,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search user, description, type, status',
                  border: OutlineInputBorder(),
                ),
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
      width: 250,
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

class _LedgerTableCard extends StatelessWidget {
  const _LedgerTableCard({required this.entries});

  final List<AdminWalletEntry> entries;

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
              'Ledger Entries',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No ledger entries found.')),
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
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Description')),
                  ],
                  rows: entries.map((e) => _row(context, e)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DataRow _row(BuildContext context, AdminWalletEntry e) {
    final amountText = NumberFormat.currency(symbol: '\$').format(e.amount);
    final isCredit = e.type.toLowerCase() == 'credit';

    return DataRow(
      cells: [
        DataCell(Text(e.userId)),
        DataCell(
          Text(
            e.timestamp.millisecondsSinceEpoch > 0
                ? DateFormat('dd MMM yyyy, hh:mm a').format(e.timestamp)
                : '-',
          ),
        ),
        DataCell(_Tag(text: e.type, color: _typeColor(e.type))),
        DataCell(_Tag(text: e.status, color: _statusColor(e.status))),
        DataCell(
          Text(
            amountText,
            style: TextStyle(
              color: isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 420,
            child: Text(
              e.description,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return const Color(0xFF059669);
      case 'debit':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF059669);
      case 'pending':
        return const Color(0xFFD97706);
      case 'failed':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
