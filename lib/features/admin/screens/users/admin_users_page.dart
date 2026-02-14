import 'package:ecommerce_app/features/admin/controllers/admin_users_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminUsersController());
    final query = ''.obs;
    final roleFilter = 'All'.obs;
    final activeFilter = 'All'.obs;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filtered = controller.users.where((doc) {
        final data = doc.data();
        final q = query.value.trim().toLowerCase();
        final fullName = (data['fullName'] ?? '').toString().toLowerCase();
        final email = (data['email'] ?? '').toString().toLowerCase();
        final role = (data['role'] ?? 'user').toString();
        final isActive = (data['isActive'] ?? true) == true;

        final matchSearch =
            q.isEmpty || fullName.contains(q) || email.contains(q) || doc.id.toLowerCase().contains(q);
        final matchRole = roleFilter.value == 'All' || role == roleFilter.value;
        final matchActive =
            activeFilter.value == 'All' ||
            (activeFilter.value == 'Active' && isActive) ||
            (activeFilter.value == 'Inactive' && !isActive);

        return matchSearch && matchRole && matchActive;
      }).toList();

      final activeCount =
          filtered.where((u) => (u.data()['isActive'] ?? true) == true).length;
      final adminCount = filtered
          .where((u) =>
              ((u.data()['role'] ?? 'user').toString() == 'admin') ||
              ((u.data()['role'] ?? 'user').toString() == 'super_admin'))
          .length;

      return RefreshIndicator(
        onRefresh: controller.loadUsers,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _UsersHeader(
              totalUsers: filtered.length,
              onRefresh: controller.loadUsers,
            ),
            const SizedBox(height: 14),
            _FilterBar(
              onSearchChanged: (value) => query.value = value,
              selectedRole: roleFilter.value,
              selectedActive: activeFilter.value,
              onRoleChanged: (value) {
                if (value != null) {
                  roleFilter.value = value;
                }
              },
              onActiveChanged: (value) {
                if (value != null) {
                  activeFilter.value = value;
                }
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  title: 'Visible Users',
                  value: '${filtered.length}',
                  hint: 'Current search/filter result',
                  icon: Icons.group_outlined,
                  accent: const Color(0xFF2563EB),
                ),
                _MetricCard(
                  title: 'Active Users',
                  value: '$activeCount',
                  hint: 'Users allowed to use app',
                  icon: Icons.verified_user_outlined,
                  accent: const Color(0xFF059669),
                ),
                _MetricCard(
                  title: 'Admin Users',
                  value: '$adminCount',
                  hint: 'admin + super_admin roles',
                  icon: Icons.admin_panel_settings_outlined,
                  accent: const Color(0xFF7C3AED),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _UsersTableCard(
              users: filtered,
              onRoleChange: (uid, role) async {
                await controller.updateUserRole(uid, role);
                Get.snackbar(
                  'Updated',
                  'Role changed to $role',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              onActiveChange: (uid, isActive) async {
                await controller.updateUserStatus(uid, isActive);
                Get.snackbar(
                  'Updated',
                  'User status changed',
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

class _UsersHeader extends StatelessWidget {
  const _UsersHeader({
    required this.totalUsers,
    required this.onRefresh,
  });

  final int totalUsers;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
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
                'User Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '$totalUsers users visible',
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
              foregroundColor: const Color(0xFF4338CA),
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
                refresh,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              refresh,
            ],
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.onSearchChanged,
    required this.selectedRole,
    required this.selectedActive,
    required this.onRoleChanged,
    required this.onActiveChanged,
  });

  final ValueChanged<String> onSearchChanged;
  final String selectedRole;
  final String selectedActive;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onActiveChanged;

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
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: onSearchChanged,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by UID, name, or email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Role',
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Roles')),
                  DropdownMenuItem(value: 'user', child: Text('user')),
                  DropdownMenuItem(value: 'admin', child: Text('admin')),
                  DropdownMenuItem(value: 'super_admin', child: Text('super_admin')),
                ],
                onChanged: onRoleChanged,
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                value: selectedActive,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Status',
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: onActiveChanged,
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

class _UsersTableCard extends StatelessWidget {
  const _UsersTableCard({
    required this.users,
    required this.onRoleChange,
    required this.onActiveChange,
  });

  final List users;
  final Future<void> Function(String uid, String role) onRoleChange;
  final Future<void> Function(String uid, bool isActive) onActiveChange;

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
              'Users List',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (users.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No users found.')),
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
                    DataColumn(label: Text('UID')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Active Toggle')),
                  ],
                  rows: users.map<DataRow>((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final uid = doc.id.toString();
                    final role = (data['role'] ?? 'user').toString();
                    final isActive = (data['isActive'] ?? true) == true;
                    final name = (data['fullName'] ?? '').toString();
                    final email = (data['email'] ?? '').toString();

                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 180,
                            child: Text(
                              uid,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        DataCell(Text(name.isEmpty ? '-' : name)),
                        DataCell(Text(email.isEmpty ? '-' : email)),
                        DataCell(
                          DropdownButton<String>(
                            value: role,
                            items: const [
                              DropdownMenuItem(value: 'user', child: Text('user')),
                              DropdownMenuItem(value: 'admin', child: Text('admin')),
                              DropdownMenuItem(
                                value: 'super_admin',
                                child: Text('super_admin'),
                              ),
                            ],
                            onChanged: (v) async {
                              if (v == null) return;
                              await onRoleChange(uid, v);
                            },
                          ),
                        ),
                        DataCell(
                          _StatusTag(
                            text: isActive ? 'Active' : 'Inactive',
                            color: isActive
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                        DataCell(
                          Switch.adaptive(
                            value: isActive,
                            onChanged: (v) async {
                              await onActiveChange(uid, v);
                            },
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

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.text, required this.color});

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
