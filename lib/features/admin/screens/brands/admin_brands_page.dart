import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/controllers/admin_brands_controller.dart';
import 'package:ecommerce_app/features/shop/models/brand_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminBrandsPage extends StatelessWidget {
  const AdminBrandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminBrandsController());

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
                onPressed: () => _showBrandDialog(context, controller),
                icon: const Icon(Icons.add),
                label: const Text('Add Brand'),
              ),
              const SizedBox(width: 12),
              Text('Total brands: ${controller.brands.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Verified')),
                  DataColumn(label: Text('Featured')),
                  DataColumn(label: Text('Products')),
                  DataColumn(label: Text('Actions')),
                ],
                rows:
                    controller.brands
                        .map((b) => _row(context, controller, b))
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
    AdminBrandsController controller,
    BrandModel brand,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(brand.name)),
        DataCell(Text(brand.category)),
        DataCell(Text(brand.verified ? 'Yes' : 'No')),
        DataCell(
          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future:
                FirebaseFirestore.instance
                    .collection('brands')
                    .doc(brand.id)
                    .get(),
            builder: (context, snapshot) {
              final isFeatured = snapshot.data?.data()?['isFeatured'] == true;
              return Text(isFeatured ? 'Yes' : 'No');
            },
          ),
        ),
        DataCell(Text('${brand.productCount}')),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed:
                    () => _showBrandDialog(context, controller, brand: brand),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () async {
                  await controller.deleteBrand(brand.id);
                  Get.snackbar('Deleted', 'Brand removed');
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showBrandDialog(
    BuildContext context,
    AdminBrandsController controller, {
    BrandModel? brand,
  }) async {
    final isEdit = brand != null;
    final nameController = TextEditingController(text: brand?.name ?? '');
    final categoryController = TextEditingController(
      text: brand?.category ?? '',
    );
    final logoController = TextEditingController(text: brand?.logoUrl ?? '');
    final verified = (brand?.verified ?? false).obs;
    final featured = false.obs;

    if (isEdit) {
      final doc =
          await FirebaseFirestore.instance
              .collection('brands')
              .doc(brand.id)
              .get();
      featured.value = doc.data()?['isFeatured'] == true;
    }

    await Get.dialog(
      AlertDialog(
        title: Text(isEdit ? 'Edit Brand' : 'Add Brand'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Brand Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: logoController,
                  decoration: const InputDecoration(labelText: 'Logo URL'),
                ),
                Obx(
                  () => SwitchListTile(
                    value: verified.value,
                    onChanged: (v) => verified.value = v,
                    title: const Text('Verified'),
                  ),
                ),
                Obx(
                  () => SwitchListTile(
                    value: featured.value,
                    onChanged: (v) => featured.value = v,
                    title: const Text('Featured'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (isEdit) {
                await controller.updateBrand(
                  brand.id,
                  name: nameController.text.trim(),
                  category: categoryController.text.trim(),
                  logoUrl: logoController.text.trim(),
                  verified: verified.value,
                  isFeatured: featured.value,
                );
                Get.back();
                Get.snackbar('Updated', 'Brand updated');
              } else {
                await controller.addBrand(
                  name: nameController.text.trim(),
                  category: categoryController.text.trim(),
                  logoUrl: logoController.text.trim(),
                  verified: verified.value,
                  isFeatured: featured.value,
                );
                Get.back();
                Get.snackbar('Created', 'Brand created');
              }
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}
