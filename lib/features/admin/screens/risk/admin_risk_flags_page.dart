import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/controllers/admin_risk_flags_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminRiskFlagsPage extends StatefulWidget {
  const AdminRiskFlagsPage({super.key});

  @override
  State<AdminRiskFlagsPage> createState() => _AdminRiskFlagsPageState();
}

class _AdminRiskFlagsPageState extends State<AdminRiskFlagsPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _severity = 'medium';
  String _statusFilter = 'All';

  @override
  void dispose() {
    _userIdController.dispose();
    _reasonController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminRiskFlagsController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final search = _searchController.text.trim().toLowerCase();
      final filtered = controller.flags.where((doc) {
        final data = doc.data();
        final status = (data['status'] ?? 'open').toString();
        final severity = (data['severity'] ?? '').toString();
        final userId = (data['userId'] ?? '').toString();
        final reason = (data['reason'] ?? '').toString();

        final matchStatus = _statusFilter == 'All' || status == _statusFilter;
        final matchSearch = search.isEmpty ||
            userId.toLowerCase().contains(search) ||
            reason.toLowerCase().contains(search) ||
            severity.toLowerCase().contains(search);

        return matchStatus && matchSearch;
      }).toList();

      final openCount = filtered
          .where((d) => ((d.data()['status'] ?? 'open').toString() != 'resolved'))
          .length;
      final highCount = filtered
          .where((d) => ((d.data()['severity'] ?? '').toString().toLowerCase() == 'high'))
          .length;

      return RefreshIndicator(
        onRefresh: controller.loadFlags,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Header(flagCount: filtered.length, onRefresh: controller.loadFlags),
            const SizedBox(height: 14),
            if (controller.errorMessage.value.isNotEmpty)
              _ErrorBanner(message: controller.errorMessage.value),
            _CreateFlagCard(
              userIdController: _userIdController,
              reasonController: _reasonController,
              severity: _severity,
              onSeverityChanged: (value) {
                if (value != null) {
                  setState(() => _severity = value);
                }
              },
              onCreate: () async {
                final userId = _userIdController.text.trim();
                final reason = _reasonController.text.trim();
                if (userId.isEmpty || reason.isEmpty) {
                  Get.snackbar(
                    'Validation',
                    'User ID and reason are required',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                await controller.createFlag(
                  userId: userId,
                  reason: reason,
                  severity: _severity,
                );
                _userIdController.clear();
                _reasonController.clear();
                Get.snackbar(
                  'Created',
                  'Risk flag added',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const SizedBox(height: 12),
            _FilterBar(
              searchController: _searchController,
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
                  title: 'Visible Flags',
                  value: '${filtered.length}',
                  hint: 'After filters/search',
                  icon: Icons.flag_outlined,
                  accent: const Color(0xFF2563EB),
                ),
                _MetricCard(
                  title: 'Open Flags',
                  value: '$openCount',
                  hint: 'Still under investigation',
                  icon: Icons.gpp_maybe_outlined,
                  accent: const Color(0xFFD97706),
                ),
                _MetricCard(
                  title: 'High Severity',
                  value: '$highCount',
                  hint: 'Critical signals in current view',
                  icon: Icons.priority_high_outlined,
                  accent: const Color(0xFFDC2626),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FlagsTable(
              flags: filtered,
              onResolve: (id) async {
                await controller.resolveFlag(id, 'Resolved by admin');
                Get.snackbar(
                  'Done',
                  'Flag resolved',
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
  const _Header({required this.flagCount, required this.onRefresh});

  final int flagCount;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFB91C1C), Color(0xFF7C3AED)],
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
                'Risk Flags',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '$flagCount flags visible',
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
              foregroundColor: const Color(0xFF7F1D1D),
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

class _CreateFlagCard extends StatelessWidget {
  const _CreateFlagCard({
    required this.userIdController,
    required this.reasonController,
    required this.severity,
    required this.onSeverityChanged,
    required this.onCreate,
  });

  final TextEditingController userIdController;
  final TextEditingController reasonController;
  final String severity;
  final ValueChanged<String?> onSeverityChanged;
  final Future<void> Function() onCreate;

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
              'Create Risk Flag',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: userIdController,
                    decoration: const InputDecoration(
                      labelText: 'User ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: severity,
                    decoration: const InputDecoration(
                      labelText: 'Severity',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('low')),
                      DropdownMenuItem(value: 'medium', child: Text('medium')),
                      DropdownMenuItem(value: 'high', child: Text('high')),
                    ],
                    onChanged: onSeverityChanged,
                  ),
                ),
                SizedBox(
                  width: 420,
                  child: TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Flag'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.searchController,
    required this.statusFilter,
    required this.onStatusChanged,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
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
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search user, reason, severity',
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

class _FlagsTable extends StatelessWidget {
  const _FlagsTable({required this.flags, required this.onResolve});

  final List flags;
  final Future<void> Function(String id) onResolve;

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
              'Flags List',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (flags.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No risk flags found.')),
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
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Severity')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Reason')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: flags.map<DataRow>((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = (data['status'] ?? 'open').toString();
                    final severity = (data['severity'] ?? '').toString();
                    final ts = data['createdAt'];
                    final date = ts is Timestamp
                        ? ts.toDate()
                        : DateTime.fromMillisecondsSinceEpoch(0);

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            date.millisecondsSinceEpoch > 0
                                ? DateFormat('dd MMM yyyy, hh:mm a').format(date)
                                : '-',
                          ),
                        ),
                        DataCell(Text((data['userId'] ?? '').toString())),
                        DataCell(_Tag(text: severity, color: _severityColor(severity))),
                        DataCell(_Tag(text: status, color: _statusColor(status))),
                        DataCell(
                          SizedBox(
                            width: 340,
                            child: Text(
                              (data['reason'] ?? '').toString(),
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

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return const Color(0xFFDC2626);
      case 'medium':
        return const Color(0xFFD97706);
      case 'low':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF059669);
      case 'open':
        return const Color(0xFF2563EB);
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

