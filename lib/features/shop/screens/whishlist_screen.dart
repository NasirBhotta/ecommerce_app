import 'package:ecommerce_app/common/widgets/home/product_card.dart';
import 'package:ecommerce_app/features/shop/controllers/whishlist_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WishlistController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Add sample data for demo (remove in production)
    controller.addSampleData();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? BColors.black : BColors.white,
        elevation: 0,
        title: Obx(
          () => Text(
            'Wishlist (${controller.wishlistCount})',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        actions: [
          Obx(
            () =>
                controller.wishlistItems.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Iconsax.trash),
                      onPressed: () {
                        // Show confirmation dialog
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Clear Wishlist'),
                            content: const Text(
                              'Are you sure you want to remove all items from your wishlist?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  controller.clearWishlist();
                                  Get.back();
                                },
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        // Show empty state if no items
        if (controller.wishlistItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(BSizes.paddingLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.heart,
                    size: 100,
                    color:
                        isDark
                            ? BColors.white.withOpacity(0.2)
                            : BColors.grey.withOpacity(0.4),
                  ),
                  const SizedBox(height: BSizes.spaceBetweenSections),
                  Text(
                    'Your Wishlist is Empty',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: BSizes.spaceBetweenItems),
                  Text(
                    'Add items you like to your wishlist.\nThey will appear here.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isDark
                              ? BColors.white.withOpacity(0.6)
                              : BColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: BSizes.spaceBetweenSections),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to home or store
                      Get.back();
                    },
                    child: const Text('Start Shopping'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show wishlist items in grid
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(BSizes.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sort and Filter Options
                Row(
                  children: [
                    Text(
                      '${controller.wishlistCount} ${controller.wishlistCount == 1 ? 'Item' : 'Items'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        // Show sort options
                        Get.bottomSheet(
                          Container(
                            padding: const EdgeInsets.all(BSizes.paddingLg),
                            decoration: BoxDecoration(
                              color: isDark ? BColors.black : BColors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(BSizes.cardRadius),
                                topRight: Radius.circular(BSizes.cardRadius),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sort By',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(
                                  height: BSizes.spaceBetweenItems,
                                ),
                                ListTile(
                                  leading: const Icon(Iconsax.arrow_down),
                                  title: const Text('Newest First'),
                                  onTap: () {
                                    // Sort implementation
                                    Get.back();
                                    Get.snackbar(
                                      'Sorted',
                                      'Wishlist sorted by newest first',
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 1),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Iconsax.arrow_up),
                                  title: const Text('Oldest First'),
                                  onTap: () {
                                    Get.back();
                                    Get.snackbar(
                                      'Sorted',
                                      'Wishlist sorted by oldest first',
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 1),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Iconsax.sort, size: 20),
                      label: const Text('Sort'),
                    ),
                  ],
                ),
                const SizedBox(height: BSizes.spaceBetweenItems),

                // Wishlist Items Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: controller.wishlistItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: BSizes.spaceBetweenItems,
                    crossAxisSpacing: BSizes.spaceBetweenItems,
                    mainAxisExtent: 288,
                  ),
                  itemBuilder: (_, index) {
                    final product = controller.wishlistItems[index];
                    return BProductCardVertical(
                      productName: product['name'],
                      price: product['price'],
                      discount: product['discount'],
                      onTap: () {
                        Get.snackbar(
                          'Product',
                          'Opening ${product['name']}...',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: BColors.primary.withOpacity(0.8),
                          colorText: BColors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      onFavoriteTap: () {
                        controller.removeFromWishlist(product['name']);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
