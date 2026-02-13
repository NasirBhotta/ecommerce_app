import 'package:ecommerce_app/features/shop/controllers/product_detail_controller.dart';
import 'package:ecommerce_app/features/shop/models/product_model.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductDetailController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? BColors.white : BColors.black,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isFavorite.value ? Iconsax.heart5 : Iconsax.heart,
                color:
                    controller.isFavorite.value
                        ? Colors.red
                        : (isDark ? BColors.white : BColors.black),
              ),
              onPressed: controller.toggleFavorite,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Variants
            Container(
              height: 300,
              color:
                  isDark
                      ? BColors.grey.withValues(alpha: 0.1)
                      : BColors.grey.withValues(alpha: 0.05),
              child: Column(
                children: [
                  // Main Image
                  Expanded(child: Center(child: _buildImage(product.imageUrl))),

                  // Variant Images
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(
                      horizontal: BSizes.paddingMd,
                    ),
                    child: Obx(
                      () {
                        final images =
                            product.images.isNotEmpty
                                ? product.images
                                : (product.imageUrl.isNotEmpty
                                    ? [product.imageUrl]
                                    : <String>[]);
                        final count = images.isEmpty ? 4 : images.length;

                        return Row(
                          children: List.generate(
                            count,
                            (index) => GestureDetector(
                              onTap: () => controller.selectImage(index),
                              child: Container(
                                width: 60,
                                height: 60,
                                margin: const EdgeInsets.only(
                                  right: BSizes.paddingSm,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    BSizes.paddingSm,
                                  ),
                                  border: Border.all(
                                    color:
                                        controller.selectedImageIndex.value ==
                                                index
                                            ? BColors.primary
                                            : BColors.grey.withValues(
                                              alpha: 0.3,
                                            ),
                                    width:
                                        controller.selectedImageIndex.value ==
                                                index
                                            ? 2
                                            : 1,
                                  ),
                                  color:
                                      isDark
                                          ? BColors.grey.withValues(alpha: 0.1)
                                          : BColors.white,
                                ),
                                child: Center(
                                  child:
                                      images.isEmpty
                                          ? Icon(
                                            Icons.image,
                                            size: 30,
                                            color: BColors.grey.withValues(
                                              alpha: 0.5,
                                            ),
                                          )
                                          : _buildThumbnail(images[index]),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: BSizes.spaceBetweenItems),
                ],
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(BSizes.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating and Share
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '5.0 (199)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Icon(
                        Iconsax.share,
                        color: isDark ? BColors.white : BColors.black,
                      ),
                    ],
                  ),

                  const SizedBox(height: BSizes.spaceBetweenItems),

                  // Price with Discount
                  Row(
                    children: [
                      if (product.discountLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BSizes.paddingSm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade700,
                            borderRadius: BorderRadius.circular(
                              BSizes.paddingSm,
                            ),
                          ),
                          child: Text(
                            product.discountLabel!,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall!.apply(
                              color: BColors.black,
                              fontWeightDelta: 2,
                            ),
                          ),
                        ),
                      const SizedBox(width: BSizes.paddingSm),
                      Text(
                        product.priceLabel,
                        style: Theme.of(context).textTheme.headlineSmall!.apply(
                          color: BColors.primary,
                          fontWeightDelta: 2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: BSizes.spaceBetweenItems),

                  // Product Name
                  Text(
                    product.name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.apply(fontWeightDelta: 1),
                  ),

                  const SizedBox(height: 4),

                  // Stock Status and Brand
                  Row(
                    children: [
                      Text(
                        'In Stock',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.apply(color: Colors.green),
                      ),
                      const SizedBox(width: BSizes.paddingSm),
                      const Icon(Icons.circle, size: 6, color: BColors.grey),
                      const SizedBox(width: BSizes.paddingSm),
                      Row(
                        children: [
                          Text(
                            product.brandName.isNotEmpty
                                ? product.brandName
                                : 'Brand',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: BColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: BSizes.spaceBetweenSections),

                  // Color Selection
                  Text(
                    'Color',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.apply(fontWeightDelta: 1),
                  ),
                  const SizedBox(height: BSizes.spaceBetweenItems),
                  Obx(
                    () => Row(
                      children: List.generate(controller.colors.length, (
                        index,
                      ) {
                        final colorValue = int.parse(
                          controller.colors[index]['color']!,
                        );
                        return GestureDetector(
                          onTap: () => controller.selectColor(index),
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(
                              right: BSizes.paddingSm,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(colorValue),
                              border: Border.all(
                                color:
                                    controller.selectedColorIndex.value == index
                                        ? BColors.primary
                                        : BColors.grey.withValues(alpha: 0.3),
                                width:
                                    controller.selectedColorIndex.value == index
                                        ? 3
                                        : 1,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: BSizes.spaceBetweenSections),

                  // Size Selection
                  Text(
                    'Size',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.apply(fontWeightDelta: 1),
                  ),
                  const SizedBox(height: BSizes.spaceBetweenItems),
                  Obx(
                    () => Wrap(
                      spacing: BSizes.paddingSm,
                      children: List.generate(
                        controller.sizes.length,
                        (index) => GestureDetector(
                          onTap: () => controller.selectSize(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: BSizes.paddingMd,
                              vertical: BSizes.paddingSm,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                BSizes.paddingSm,
                              ),
                              border: Border.all(
                                color:
                                    controller.selectedSizeIndex.value == index
                                        ? BColors.primary
                                        : BColors.grey.withValues(alpha: 0.3),
                                width:
                                    controller.selectedSizeIndex.value == index
                                        ? 2
                                        : 1,
                              ),
                              color:
                                  controller.selectedSizeIndex.value == index
                                      ? BColors.primary.withValues(alpha: 0.1)
                                      : Colors.transparent,
                            ),
                            child: Text(
                              controller.sizes[index],
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.apply(
                                color:
                                    controller.selectedSizeIndex.value == index
                                        ? BColors.primary
                                        : (isDark
                                            ? BColors.white
                                            : BColors.black),
                                fontWeightDelta:
                                    controller.selectedSizeIndex.value == index
                                        ? 2
                                        : 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: BSizes.spaceBetweenSections * 2),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Bar with Quantity and Actions
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(BSizes.paddingLg),
        decoration: BoxDecoration(
          color: isDark ? BColors.black : BColors.white,
          boxShadow: [
            BoxShadow(
              color: BColors.grey.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color:
                        controller.quantity.value > 0
                            ? BColors.primary
                            : (isDark
                                ? BColors.grey.withValues(alpha: 0.3)
                                : BColors.black),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child:
                      controller.quantity.value > 0
                          ? Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: BColors.white,
                                ),
                                onPressed: controller.decreaseQuantity,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: BSizes.paddingSm,
                                ),
                                child: Text(
                                  '${controller.quantity.value}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium!.apply(
                                    color: BColors.white,
                                    fontWeightDelta: 2,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: BColors.white,
                                ),
                                onPressed: controller.increaseQuantity,
                              ),
                            ],
                          )
                          : IconButton(
                            icon: const Icon(Icons.add, color: BColors.white),
                            onPressed: controller.increaseQuantity,
                          ),
                ),
              ),

              const SizedBox(width: BSizes.paddingMd),

              // Action Buttons
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.addToBag,
                        icon: const Icon(Iconsax.bag_2),
                        label: const Text('Add to Bag'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: BSizes.paddingMd,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: BSizes.paddingSm),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.checkout,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: BSizes.paddingMd,
                          ),
                        ),
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Icon(
        Icons.image,
        size: 150,
        color: BColors.grey.withValues(alpha: 0.3),
      );
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder:
            (_, __, ___) => Icon(
              Icons.broken_image,
              size: 150,
              color: BColors.grey.withValues(alpha: 0.3),
            ),
      );
    }

    return Image.asset(url, fit: BoxFit.contain);
  }

  Widget _buildThumbnail(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder:
            (_, __, ___) => Icon(
              Icons.broken_image,
              size: 30,
              color: BColors.grey.withValues(alpha: 0.5),
            ),
      );
    }

    return Image.asset(url, fit: BoxFit.contain);
  }
}
