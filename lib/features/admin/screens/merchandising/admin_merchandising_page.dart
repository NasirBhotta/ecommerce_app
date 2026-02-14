import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/controllers/admin_merchandising_controller.dart';
import 'package:ecommerce_app/features/shop/models/brand_model.dart';
import 'package:ecommerce_app/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminMerchandisingPage extends StatelessWidget {
  const AdminMerchandisingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminMerchandisingController());

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
              ElevatedButton(
                onPressed: controller.loadData,
                child: const Text('Refresh'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showBannerDialog(context, controller),
                icon: const Icon(Icons.add),
                label: const Text('Add Banner'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Suggested Products',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(child: _productsTable(controller)),
          const SizedBox(height: 12),
          Text(
            'Featured Brands',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(child: _brandsTable(controller)),
          const SizedBox(height: 12),
          Text(
            'Homepage Banners',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(child: _bannersTable(context, controller)),
        ],
      );
    });
  }

  Widget _productsTable(AdminMerchandisingController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Brand')),
          DataColumn(label: Text('Suggested')),
        ],
        rows:
            controller.allProducts
                .map((p) => _productRow(controller, p))
                .toList(),
      ),
    );
  }

  DataRow _productRow(AdminMerchandisingController controller, ProductModel p) {
    return DataRow(
      cells: [
        DataCell(Text(p.name)),
        DataCell(Text(p.category)),
        DataCell(Text(p.brandName)),
        DataCell(
          Switch(
            value: p.isSuggested,
            onChanged: (v) => controller.toggleSuggestedProduct(p, v),
          ),
        ),
      ],
    );
  }

  Widget _brandsTable(AdminMerchandisingController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Featured')),
        ],
        rows:
            controller.allBrands.map((b) => _brandRow(controller, b)).toList(),
      ),
    );
  }

  DataRow _brandRow(AdminMerchandisingController controller, BrandModel b) {
    return DataRow(
      cells: [
        DataCell(Text(b.name)),
        DataCell(Text(b.category)),
        DataCell(
          Switch(
            value: controller.featuredBrandIds.contains(b.id),
            onChanged: (v) => controller.toggleFeaturedBrand(b, v),
          ),
        ),
      ],
    );
  }

  Widget _bannersTable(
    BuildContext context,
    AdminMerchandisingController controller,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('Subtitle')),
          DataColumn(label: Text('Order')),
          DataColumn(label: Text('Active')),
          DataColumn(label: Text('Actions')),
        ],
        rows:
            controller.banners
                .map(
                  (doc) => DataRow(
                    cells: [
                      DataCell(Text((doc.data()['title'] ?? '').toString())),
                      DataCell(Text((doc.data()['subtitle'] ?? '').toString())),
                      DataCell(Text((doc.data()['order'] ?? 0).toString())),
                      DataCell(
                        Text(doc.data()['isActive'] == true ? 'Yes' : 'No'),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              onPressed:
                                  () => _showBannerDialog(
                                    context,
                                    controller,
                                    doc: doc,
                                  ),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () async {
                                await controller.deleteBanner(doc.id);
                                Get.snackbar('Deleted', 'Banner removed');
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }

  Future<void> _showBannerDialog(
    BuildContext context,
    AdminMerchandisingController controller, {
    QueryDocumentSnapshot<Map<String, dynamic>>? doc,
  }) async {
    final isEdit = doc != null;
    final titleController = TextEditingController(
      text: isEdit ? (doc.data()['title'] ?? '').toString() : '',
    );
    final subtitleController = TextEditingController(
      text: isEdit ? (doc.data()['subtitle'] ?? '').toString() : '',
    );
    final imageController = TextEditingController(
      text: isEdit ? (doc.data()['imageUrl'] ?? '').toString() : '',
    );
    final orderController = TextEditingController(
      text: isEdit ? (doc.data()['order'] ?? 0).toString() : '0',
    );
    final isActive = (isEdit ? doc.data()['isActive'] == true : true).obs;

    await Get.dialog(
      AlertDialog(
        title: Text(isEdit ? 'Edit Banner' : 'Add Banner'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: subtitleController,
                  decoration: const InputDecoration(labelText: 'Subtitle'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: orderController,
                  decoration: const InputDecoration(labelText: 'Order'),
                ),
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
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final order = int.tryParse(orderController.text.trim()) ?? 0;
              if (isEdit) {
                await controller.updateBanner(
                  doc.id,
                  title: titleController.text.trim(),
                  subtitle: subtitleController.text.trim(),
                  imageUrl: imageController.text.trim(),
                  order: order,
                  isActive: isActive.value,
                );
                Get.back();
                Get.snackbar('Updated', 'Banner updated');
              } else {
                await controller.addBanner(
                  title: titleController.text.trim(),
                  subtitle: subtitleController.text.trim(),
                  imageUrl: imageController.text.trim(),
                  order: order,
                  isActive: isActive.value,
                );
                Get.back();
                Get.snackbar('Created', 'Banner created');
              }
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}
