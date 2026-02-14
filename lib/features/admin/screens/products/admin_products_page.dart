import 'package:ecommerce_app/features/admin/controllers/admin_products_controller.dart';
import 'package:ecommerce_app/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminProductsController());
    final query = ''.obs;
    final stockFilter = 'All'.obs;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filtered = controller.products.where((p) {
        final q = query.value.trim().toLowerCase();
        final matchSearch =
            q.isEmpty ||
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.brandName.toLowerCase().contains(q);

        final matchStock =
            stockFilter.value == 'All' ||
            (stockFilter.value == 'In Stock' && p.inStock) ||
            (stockFilter.value == 'Out of Stock' && !p.inStock);

        return matchSearch && matchStock;
      }).toList();

      final totalValue = filtered.fold<double>(0, (sum, p) => sum + p.price);
      final suggestedCount = filtered.where((p) => p.isSuggested).length;
      final outOfStockCount = filtered.where((p) => !p.inStock).length;

      return RefreshIndicator(
        onRefresh: controller.loadProducts,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ProductsHeader(
              totalProducts: filtered.length,
              onRefresh: controller.loadProducts,
              onAdd: () => _showProductDialog(context, controller),
            ),
            const SizedBox(height: 14),
            _FilterBar(
              onSearchChanged: (value) => query.value = value,
              selectedStock: stockFilter.value,
              onStockChanged: (value) {
                if (value != null) {
                  stockFilter.value = value;
                }
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  title: 'Visible Products',
                  value: '${filtered.length}',
                  hint: 'After filters',
                  icon: Icons.inventory_2_outlined,
                  accent: const Color(0xFF2563EB),
                ),
                _MetricCard(
                  title: 'Catalog Value',
                  value: NumberFormat.currency(symbol: '\$').format(totalValue),
                  hint: 'Sum of listed prices',
                  icon: Icons.attach_money_outlined,
                  accent: const Color(0xFF059669),
                ),
                _MetricCard(
                  title: 'Suggested',
                  value: '$suggestedCount',
                  hint: 'Products marked as suggested',
                  icon: Icons.auto_awesome_outlined,
                  accent: const Color(0xFF7C3AED),
                ),
                _MetricCard(
                  title: 'Out of Stock',
                  value: '$outOfStockCount',
                  hint: 'Need inventory action',
                  icon: Icons.warning_amber_outlined,
                  accent: const Color(0xFFD97706),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ProductsTableCard(
              products: filtered,
              onEdit: (product) => _showProductDialog(
                context,
                controller,
                product: product,
              ),
              onDelete: (product) async {
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Delete Product'),
                    content: Text('Delete "${product.name}" permanently?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await controller.deleteProduct(product.id);
                  Get.snackbar(
                    'Deleted',
                    'Product removed',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            ),
          ],
        ),
      );
    });
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
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _FormField(controller: name, label: 'Name'),
                const SizedBox(height: 10),
                _FormField(
                  controller: price,
                  label: 'Price',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                _FormField(
                  controller: discount,
                  label: 'Discount %',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                _FormField(controller: category, label: 'Category'),
                const SizedBox(height: 10),
                _FormField(controller: brandId, label: 'Brand ID'),
                const SizedBox(height: 10),
                _FormField(controller: brandName, label: 'Brand Name'),
                const SizedBox(height: 10),
                _FormField(controller: imageUrl, label: 'Image URL'),
                const SizedBox(height: 8),
                Obx(
                  () => SwitchListTile.adaptive(
                    value: isSuggested.value,
                    onChanged: (v) => isSuggested.value = v,
                    title: const Text('Suggested product'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Obx(
                  () => SwitchListTile.adaptive(
                    value: inStock.value,
                    onChanged: (v) => inStock.value = v,
                    title: const Text('In stock'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final parsedPrice = double.tryParse(price.text.trim()) ?? 0;
              final parsedDiscount = int.tryParse(discount.text.trim()) ?? 0;

              if (name.text.trim().isEmpty) {
                Get.snackbar(
                  'Validation',
                  'Name is required',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

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
                Get.snackbar(
                  'Updated',
                  'Product updated',
                  snackPosition: SnackPosition.BOTTOM,
                );
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
                Get.snackbar(
                  'Created',
                  'Product created',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Text(isEdit ? 'Save Changes' : 'Create Product'),
          ),
        ],
      ),
    );
  }
}

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader({
    required this.totalProducts,
    required this.onRefresh,
    required this.onAdd,
  });

  final int totalProducts;
  final Future<void> Function() onRefresh;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0891B2)],
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
                'Product Catalog',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '$totalProducts products visible',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F766E),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
              OutlinedButton.icon(
                onPressed: onRefresh,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 10),
                actions,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              actions,
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
    required this.selectedStock,
    required this.onStockChanged,
  });

  final ValueChanged<String> onSearchChanged;
  final String selectedStock;
  final ValueChanged<String?> onStockChanged;

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
                  hintText: 'Search by name, category, brand',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: selectedStock,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Stock')),
                  DropdownMenuItem(
                    value: 'In Stock',
                    child: Text('In Stock'),
                  ),
                  DropdownMenuItem(
                    value: 'Out of Stock',
                    child: Text('Out of Stock'),
                  ),
                ],
                onChanged: onStockChanged,
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

class _ProductsTableCard extends StatelessWidget {
  const _ProductsTableCard({
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ProductModel> products;
  final ValueChanged<ProductModel> onEdit;
  final ValueChanged<ProductModel> onDelete;

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
              'Products List',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No products found.')),
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
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Brand')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Discount')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Suggested')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: products.map((p) => _row(context, p)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DataRow _row(BuildContext context, ProductModel p) {
    return DataRow(
      cells: [
        DataCell(Text(p.name)),
        DataCell(Text(p.category.isEmpty ? '-' : p.category)),
        DataCell(Text(p.brandName.isEmpty ? '-' : p.brandName)),
        DataCell(Text(p.priceLabel)),
        DataCell(Text(p.discountLabel ?? '-')),
        DataCell(
          _Tag(
            text: p.inStock ? 'In Stock' : 'Out of Stock',
            color: p.inStock ? const Color(0xFF059669) : const Color(0xFFDC2626),
          ),
        ),
        DataCell(
          _Tag(
            text: p.isSuggested ? 'Yes' : 'No',
            color: p.isSuggested ? const Color(0xFF7C3AED) : const Color(0xFF6B7280),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () => onEdit(p),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => onDelete(p),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ],
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

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
