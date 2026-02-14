import 'package:ecommerce_app/features/admin/controllers/admin_wallet_controller.dart';
import 'package:ecommerce_app/features/admin/controllers/admin_withdrawals_controller.dart';
import 'package:ecommerce_app/features/admin/models/admin_wallet_entry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminWithdrawalsPage extends StatelessWidget {
  const AdminWithdrawalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = Get.put(AdminWalletController());
    final withdrawals = Get.put(AdminWithdrawalsController());

    return Obx(() {
      final pending = wallet.entries
          .where((e) => e.isWithdrawal && e.status.toLowerCase() == 'pending')
          .toList();

      final pendingAmount = pending.fold<double>(0, (sum, e) => sum + e.amount);
      final uniqueUsers = pending.map((e) => e.userId).toSet().length;

      return RefreshIndicator(
        onRefresh: wallet.loadEntries,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Header(
              pendingCount: pending.length,
              onRefresh: wallet.loadEntries,
            ),
            const SizedBox(height: 14),
            if (wallet.errorMessage.value.isNotEmpty)
              _ErrorBanner(message: wallet.errorMessage.value),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  title: 'Pending Requests',
                  value: '${pending.length}',
                  hint: 'Awaiting admin decision',
                  icon: Icons.hourglass_bottom_outlined,
                  accent: const Color(0xFF2563EB),
                ),
                _MetricCard(
                  title: 'Pending Amount',
                  value: _currency(pendingAmount),
                  hint: 'Total requested value',
                  icon: Icons.account_balance_wallet_outlined,
                  accent: const Color(0xFFD97706),
                ),
                _MetricCard(
                  title: 'Affected Users',
                  value: '$uniqueUsers',
                  hint: 'Unique users with pending requests',
                  icon: Icons.group_outlined,
                  accent: const Color(0xFF7C3AED),
                ),
                _MetricCard(
                  title: 'Processor State',
                  value: withdrawals.isProcessing.value ? 'Running' : 'Idle',
                  hint: 'Cloud function withdrawal handler',
                  icon: Icons.sync_outlined,
                  accent: withdrawals.isProcessing.value
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFF059669),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _WithdrawalsTable(
              entries: pending,
              isProcessing: withdrawals.isProcessing.value,
              onAction: (entry, action) async {
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    title: Text(action == 'approve'
                        ? 'Approve Withdrawal'
                        : 'Reject Withdrawal'),
                    content: Text(
                      '${action == 'approve' ? 'Approve' : 'Reject'} ${_currency(entry.amount)} for user ${entry.userId}?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Get.back(result: true),
                        child: Text(action == 'approve' ? 'Approve' : 'Reject'),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return;

                await withdrawals.processWithdrawal(entry, action);
                await wallet.loadEntries();
                Get.snackbar(
                  'Done',
                  action == 'approve'
                      ? 'Withdrawal approved'
                      : 'Withdrawal rejected',
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

class _Header extends StatelessWidget {
  const _Header({required this.pendingCount, required this.onRefresh});

  final int pendingCount;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C2D12), Color(0xFFEA580C)],
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
                'Withdrawals Queue',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '$pendingCount pending withdrawals',
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
              foregroundColor: const Color(0xFF9A3412),
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

          return Row(children: [Expanded(child: summary), refresh]);
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

class _WithdrawalsTable extends StatelessWidget {
  const _WithdrawalsTable({
    required this.entries,
    required this.isProcessing,
    required this.onAction,
  });

  final List<AdminWalletEntry> entries;
  final bool isProcessing;
  final Future<void> Function(AdminWalletEntry entry, String action) onAction;

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
              'Pending Withdrawals',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No pending withdrawals.')),
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
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: entries.map((e) {
                    return DataRow(
                      cells: [
                        DataCell(Text(e.userId)),
                        DataCell(
                          Text(
                            e.timestamp.millisecondsSinceEpoch > 0
                                ? DateFormat('dd MMM yyyy, hh:mm a')
                                    .format(e.timestamp)
                                : '-',
                          ),
                        ),
                        DataCell(
                          Text(
                            NumberFormat.currency(symbol: '\$')
                                .format(e.amount),
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        DataCell(_Tag(text: e.status, color: const Color(0xFFD97706))),
                        DataCell(
                          SizedBox(
                            width: 360,
                            child: Text(
                              e.description,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        DataCell(
                          Wrap(
                            spacing: 6,
                            children: [
                              FilledButton.tonal(
                                onPressed: isProcessing
                                    ? null
                                    : () => onAction(e, 'approve'),
                                child: const Text('Approve'),
                              ),
                              OutlinedButton(
                                onPressed: isProcessing
                                    ? null
                                    : () => onAction(e, 'reject'),
                                child: const Text('Reject'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
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
