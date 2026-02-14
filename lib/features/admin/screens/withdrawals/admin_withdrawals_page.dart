import 'package:ecommerce_app/features/admin/controllers/admin_wallet_controller.dart';
import 'package:ecommerce_app/features/admin/controllers/admin_withdrawals_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminWithdrawalsPage extends StatelessWidget {
  const AdminWithdrawalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = Get.put(AdminWalletController());
    final withdrawals = Get.put(AdminWithdrawalsController());

    return Obx(() {
      final pending =
          wallet.entries
              .where((e) => e.isWithdrawal && e.status == 'pending')
              .toList();

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (wallet.errorMessage.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                wallet.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Row(
            children: [
              ElevatedButton(
                onPressed: wallet.loadEntries,
                child: const Text('Refresh'),
              ),
              const SizedBox(width: 12),
              Text('Pending withdrawals: ${pending.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Action')),
                ],
                rows:
                    pending
                        .map(
                          (e) => DataRow(
                            cells: [
                              DataCell(Text(e.userId)),
                              DataCell(
                                Text('\$${e.amount.toStringAsFixed(2)}'),
                              ),
                              DataCell(Text(e.status)),
                              DataCell(
                                SizedBox(
                                  width: 340,
                                  child: Text(e.description),
                                ),
                              ),
                              DataCell(
                                Obx(
                                  () => Row(
                                    children: [
                                      TextButton(
                                        onPressed:
                                            withdrawals.isProcessing.value
                                                ? null
                                                : () async {
                                                  await withdrawals
                                                      .processWithdrawal(
                                                        e,
                                                        'approve',
                                                      );
                                                  await wallet.loadEntries();
                                                  Get.snackbar(
                                                    'Done',
                                                    'Withdrawal approved',
                                                  );
                                                },
                                        child: const Text('Approve'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            withdrawals.isProcessing.value
                                                ? null
                                                : () async {
                                                  await withdrawals
                                                      .processWithdrawal(
                                                        e,
                                                        'reject',
                                                      );
                                                  await wallet.loadEntries();
                                                  Get.snackbar(
                                                    'Done',
                                                    'Withdrawal rejected',
                                                  );
                                                },
                                        child: const Text('Reject'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ],
      );
    });
  }
}
