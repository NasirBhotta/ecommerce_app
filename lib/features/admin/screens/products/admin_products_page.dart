import 'package:ecommerce_app/features/admin/controllers/admin_products_controller.dart';
import 'package:ecommerce_app/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminProductsController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showProductDialog(context, controller),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
              const SizedBox(width: 12),
              Text('Total: ${controller.products.length}'),
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
                  DataColumn(label: Text('Brand')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Stock')),
                  DataColumn(label: Text('Actions')),
                ],
                rows:
                    controller.products
                        .map((p) => _row(context, controller, p))
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
    AdminProductsController controller,
    ProductModel product,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(product.name)),
        DataCell(Text(product.category)),
        DataCell(Text(product.brandName)),
        DataCell(Text(product.priceLabel)),
        DataCell(Text(product.inStock ? 'In stock' : 'Out of stock')),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed:
                    () => _showProductDialog(
                      context,
                      controller,
                      product: product,
                    ),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () async {
                  await controller.deleteProduct(product.id);
                  Get.snackbar('Deleted', 'Product removed');
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showProductDialog(
    BuildContext context,
    AdminProductsController controller, {
    ProductModel? product,
  }) async {
    final isEdit = product != null;
    final name = TextEditingController(text: product?.name ?? '');
    final price = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(2) : '',
    );
    final discount = TextEditingController(
      text: product?.discountPercent.toString() ?? '0',
    );
    final category = TextEditingController(text: product?.category ?? '');
    final brandId = TextEditingController(text: product?.brandId ?? '');
    final brandName = TextEditingController(text: product?.brandName ?? '');
    final imageUrl = TextEditingController(text: product?.imageUrl ?? '');

    final isSuggested = (product?.isSuggested ?? false).obs;
    final inStock = (product?.inStock ?? true).obs;

    await Get.dialog(
      AlertDialog(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: price,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: discount,
                  decoration: const InputDecoration(labelText: 'Discount %'),
                ),
                TextField(
                  controller: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: brandId,
                  decoration: const InputDecoration(labelText: 'Brand ID'),
                ),
                TextField(
                  controller: brandName,
                  decoration: const InputDecoration(labelText: 'Brand Name'),
                ),
                TextField(
                  controller: imageUrl,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => SwitchListTile(
                    value: isSuggested.value,
                    onChanged: (v) => isSuggested.value = v,
                    title: const Text('Suggested product'),
                  ),
                ),
                Obx(
                  () => SwitchListTile(
                    value: inStock.value,
                    onChanged: (v) => inStock.value = v,
                    title: const Text('In stock'),
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
              final parsedPrice = double.tryParse(price.text.trim()) ?? 0;
              final parsedDiscount = int.tryParse(discount.text.trim()) ?? 0;

              if (isEdit) {
                await controller.updateProduct(
                  product.id,
                  name: name.text.trim(),
                  price: parsedPrice,
                  discountPercent: parsedDiscount,
                  category: category.text.trim(),
                  brandId: brandId.text.trim(),
                  brandName: brandName.text.trim(),
                  imageUrl: imageUrl.text.trim(),
                  isSuggested: isSuggested.value,
                  inStock: inStock.value,
                );
                Get.back();
                Get.snackbar('Updated', 'Product updated');
              } else {
                await controller.addProduct(
                  name: name.text.trim(),
                  price: parsedPrice,
                  discountPercent: parsedDiscount,
                  category: category.text.trim(),
                  brandId: brandId.text.trim(),
                  brandName: brandName.text.trim(),
                  imageUrl: imageUrl.text.trim(),
                  isSuggested: isSuggested.value,
                  inStock: inStock.value,
                );
                Get.back();
                Get.snackbar('Created', 'Product created');
              }
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}
