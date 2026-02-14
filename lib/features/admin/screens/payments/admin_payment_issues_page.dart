import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/controllers/admin_payment_issues_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminPaymentIssuesPage extends StatefulWidget {
  const AdminPaymentIssuesPage({super.key});

  @override
  State<AdminPaymentIssuesPage> createState() => _AdminPaymentIssuesPageState();
}

class _AdminPaymentIssuesPageState extends State<AdminPaymentIssuesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminPaymentIssuesController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final search = _searchController.text.trim().toLowerCase();
      final filtered = controller.issues.where((doc) {
        final data = doc.data();
        final status = (data['status'] ?? 'open').toString();
        final type = (data['type'] ?? '').toString();
        final userId = (data['userId'] ?? '').toString();
        final error = (data['errorMessage'] ?? '').toString();

        final matchStatus = _statusFilter == 'All' || status == _statusFilter;
        final matchSearch = search.isEmpty ||
            doc.id.toLowerCase().contains(search) ||
            userId.toLowerCase().contains(search) ||
            type.toLowerCase().contains(search) ||
            error.toLowerCase().contains(search);

        return matchStatus && matchSearch;
      }).toList();

      final openCount = filtered
          .where((d) => ((d.data()['status'] ?? 'open').toString() != 'resolved'))
          .length;
      final resolvedCount = filtered.length - openCount;

      return RefreshIndicator(
        onRefresh: controller.loadIssues,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Header(issueCount: filtered.length, onRefresh: controller.loadIssues),
            const SizedBox(height: 14),
            if (controller.errorMessage.value.isNotEmpty)
              _ErrorBanner(message: controller.errorMessage.value),
            _FilterBar(
              controller: _searchController,
              statusFilter: _statusFilter,
              onStatusChanged: (value) {
                if (value != null) {
                  setState(() => _statusFilter = value);
                }
              },
              onSearchChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  title: 'Visible Issues',
                  value: '${filtered.length}',
                  hint: 'After filters/search',
                  icon: Icons.receipt_long_outlined,
                  accent: const Color(0xFF2563EB),
                ),
                _MetricCard(
                  title: 'Open Issues',
                  value: '$openCount',
                  hint: 'Need manual action',
                  icon: Icons.warning_amber_outlined,
                  accent: const Color(0xFFD97706),
                ),
                _MetricCard(
                  title: 'Resolved',
                  value: '$resolvedCount',
                  hint: 'Closed by support/admin',
                  icon: Icons.verified_outlined,
                  accent: const Color(0xFF059669),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _IssuesTable(
              issues: filtered,
              onResolve: (id) async {
                await controller.resolveIssue(id, 'Resolved from admin panel');
                Get.snackbar(
                  'Done',
                  'Issue resolved',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.issueCount, required this.onRefresh});

  final int issueCount;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0C4A6E), Color(0xFF0369A1)],
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
                'Payment Issues',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '$issueCount issues visible',
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
              foregroundColor: const Color(0xFF0369A1),
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

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.controller,
    required this.statusFilter,
    required this.onStatusChanged,
    required this.onSearchChanged,
  });

  final TextEditingController controller;
  final String statusFilter;
  final ValueChanged<String?> onStatusChanged;
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
                value: statusFilter,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'open', child: Text('open')),
                  DropdownMenuItem(value: 'resolved', child: Text('resolved')),
                ],
                onChanged: onStatusChanged,
              ),
            ),
            SizedBox(
              width: 360,
              child: TextField(
                controller: controller,
                onChanged: onSearchChanged,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search issue id, user id, type, error',
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

class _IssuesTable extends StatelessWidget {
  const _IssuesTable({
    required this.issues,
    required this.onResolve,
  });

  final List issues;
  final Future<void> Function(String issueId) onResolve;

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
              'Issues List',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (issues.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No payment issues found.')),
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
                    DataColumn(label: Text('Issue ID')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Error')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: issues.map<DataRow>((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = (data['status'] ?? 'open').toString();
                    final ts = data['createdAt'];
                    final date = ts is Timestamp
                        ? ts.toDate()
                        : DateTime.fromMillisecondsSinceEpoch(0);

                    return DataRow(
                      cells: [
                        DataCell(Text(doc.id.toString())),
                        DataCell(
                          Text(
                            date.millisecondsSinceEpoch > 0
                                ? DateFormat('dd MMM yyyy, hh:mm a').format(date)
                                : '-',
                          ),
                        ),
                        DataCell(Text((data['userId'] ?? '').toString())),
                        DataCell(Text((data['type'] ?? '').toString())),
                        DataCell(
                          _Tag(
                            text: status,
                            color: status == 'resolved'
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 320,
                            child: Text(
                              (data['errorMessage'] ?? '').toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        DataCell(
                          FilledButton.tonal(
                            onPressed: status == 'resolved'
                                ? null
                                : () => onResolve(doc.id.toString()),
                            child: const Text('Resolve'),
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

