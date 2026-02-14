import 'package:ecommerce_app/features/admin/controllers/admin_coupons_controller.dart';
import 'package:ecommerce_app/features/shop/models/coupon_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminCouponsPage extends StatelessWidget {
  const AdminCouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminCouponsController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
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
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showCouponDialog(context, controller),
                icon: const Icon(Icons.add),
                label: const Text('Add Coupon'),
              ),
              const SizedBox(width: 12),
              Text('Total coupons: ${controller.coupons.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Code')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Value')),
                  DataColumn(label: Text('Expiry')),
                  DataColumn(label: Text('Active')),
                  DataColumn(label: Text('Actions')),
                ],
                rows:
                    controller.coupons
                        .map((c) => _row(context, controller, c))
                        .toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  DataRow _row(
    BuildContext context,
    AdminCouponsController controller,
    CouponModel coupon,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(coupon.code)),
        DataCell(Text(coupon.type)),
        DataCell(Text(coupon.value.toStringAsFixed(2))),
        DataCell(
          Text(coupon.expiryDate?.toIso8601String().split('T').first ?? '-'),
        ),
        DataCell(Text(coupon.isActive ? 'Yes' : 'No')),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed:
                    () =>
                        _showCouponDialog(context, controller, coupon: coupon),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () async {
                  await controller.deleteCoupon(coupon.id);
                  Get.snackbar('Deleted', 'Coupon removed');
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showCouponDialog(
    BuildContext context,
    AdminCouponsController controller, {
    CouponModel? coupon,
  }) async {
    final isEdit = coupon != null;
    final codeController = TextEditingController(text: coupon?.code ?? '');
    final type = (coupon?.type ?? 'fixed').obs;
    final valueController = TextEditingController(
      text: coupon != null ? coupon.value.toStringAsFixed(2) : '',
    );
    final expiryController = TextEditingController(
      text: coupon?.expiryDate?.toIso8601String().split('T').first ?? '',
    );
    final isActive = (coupon?.isActive ?? true).obs;

    await Get.dialog(
      AlertDialog(
        title: Text(isEdit ? 'Edit Coupon' : 'Add Coupon'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Coupon Code'),
              ),
              const SizedBox(height: 8),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: type.value,
                  items: const [
                    DropdownMenuItem(value: 'fixed', child: Text('fixed')),
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('percentage'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      type.value = v;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: expiryController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => SwitchListTile(
                  value: isActive.value,
                  onChanged: (v) => isActive.value = v,
                  title: const Text('Active'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final parsedValue =
                  double.tryParse(valueController.text.trim()) ?? 0;
              final expiryText = expiryController.text.trim();
              DateTime? expiryDate;
              if (expiryText.isNotEmpty) {
                expiryDate = DateTime.tryParse(expiryText);
              }

              if (isEdit) {
                await controller.updateCoupon(
                  coupon.id,
                  code: codeController.text.trim(),
                  type: type.value,
                  value: parsedValue,
                  expiryDate: expiryDate,
                  isActive: isActive.value,
                );
                Get.back();
                Get.snackbar('Updated', 'Coupon updated');
              } else {
                await controller.addCoupon(
                  code: codeController.text.trim(),
                  type: type.value,
                  value: parsedValue,
                  expiryDate: expiryDate,
                  isActive: isActive.value,
                );
                Get.back();
                Get.snackbar('Created', 'Coupon created');
              }
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}
