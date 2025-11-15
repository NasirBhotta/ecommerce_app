import 'package:ecommerce_app/common/widgets/home/product_card.dart';
import 'package:ecommerce_app/common/widgets/home/search_container.dart';
import 'package:ecommerce_app/common/widgets/home/section_heading.dart';
import 'package:ecommerce_app/common/widgets/store/brand_card.dart';
import 'package:ecommerce_app/common/widgets/store/brand_showcase.dart';
import 'package:ecommerce_app/common/widgets/store/category_tab.dart';
import 'package:ecommerce_app/features/shop/controllers/store_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? BColors.black : BColors.white,
        elevation: 0,
        title: Text('Store', style: Theme.of(context).textTheme.headlineSmall),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Iconsax.shopping_bag),
                onPressed: () {
                  Get.snackbar(
                    'Cart',
                    'Opening shopping cart...',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: BColors.primary.withOpacity(0.8),
                    colorText: BColors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: BColors.black,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      '2',
                      style: Theme.of(context).textTheme.labelSmall!.apply(
                        color: BColors.white,
                        fontSizeFactor: 0.7,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              floating: true,
              backgroundColor: isDark ? BColors.black : BColors.white,
              expandedHeight: BSizes.screenHeight * 0.5,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(
                    left: BSizes.paddingMd,
                    right: BSizes.paddingMd,
                    top: BSizes.paddingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Obx(
                        () => BSearchField(
                          controller: controller.searchController,
                          onChanged: controller.onSearchChanged,
                          hintText: 'Search in Store',
                          showClearButton: controller.isSearching.value,
                          onClear: controller.clearSearch,
                        ),
                      ),
                      const SizedBox(height: BSizes.spaceBetweenSections),
                      // Featured Brands Header
                      BSectionHeading(
                        title: 'Featured Brands',
                        onPressed: () {
                          Get.snackbar(
                            'Brands',
                            'Viewing all brands...',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: BColors.primary.withOpacity(0.8),
                            colorText: BColors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: 4,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: BSizes.spaceBetweenItems,
                              crossAxisSpacing: BSizes.spaceBetweenItems,
                              mainAxisExtent: 80,
                            ),
                        itemBuilder: (_, index) {
                          final brand = controller.featuredBrands[index];
                          return BBrandCard(
                            brandName: brand['name'] as String,
                            productCount: brand['productCount'] as int,
                            verified: brand['verified'] as bool,
                            onTap:
                                () => controller.viewBrandProducts(
                                  brand['name'] as String,
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Category Tabs
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: isDark ? BColors.black : BColors.white,
                  child: Obx(
                    () => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: BSizes.paddingMd,
                      ),
                      child: Row(
                        children: List.generate(
                          controller.categories.length,
                          (index) => BCategoryTab(
                            text: controller.categories[index],
                            isSelected:
                                controller.selectedCategoryIndex.value == index,
                            onTap: () => controller.selectCategory(index),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(BSizes.paddingMd),
            child: Column(
              children: [
                // Brand Showcases with Products
                ...List.generate(controller.filteredBrands.length, (index) {
                  final brand = controller.filteredBrands[index];
                  final products =
                      brand['products'] as List<Map<String, String>>;

                  return BBrandShowcase(
                    brandName: brand['name'] as String,
                    productCount: brand['productCount'] as int,
                    verified: brand['verified'] as bool,
                    products: products,
                    onBrandTap:
                        () => controller.viewBrandProducts(
                          brand['name'] as String,
                        ),
                  );
                }),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // You Might Like Section
                BSectionHeading(
                  title: 'You might like',
                  onPressed: () {
                    Get.snackbar(
                      'Suggestions',
                      'Viewing all suggestions...',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: BColors.primary.withOpacity(0.8),
                      colorText: BColors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),

                const SizedBox(height: BSizes.spaceBetweenItems),

                // Products Grid
                GridView.builder(
                  itemCount: controller.suggestedProducts.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: BSizes.spaceBetweenItems,
                    crossAxisSpacing: BSizes.spaceBetweenItems,
                    mainAxisExtent: 288,
                  ),
                  itemBuilder: (_, index) {
                    final product = controller.suggestedProducts[index];
                    return BProductCardVertical(
                      productName: product['name']!,
                      price: product['price']!,
                      discount: product['discount'],
                      onTap: () {
                        Get.snackbar(
                          'Product',
                          'You tapped on ${product['name']}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: BColors.primary.withOpacity(0.8),
                          colorText: BColors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      onFavoriteTap: () {
                        Get.snackbar(
                          'Wishlist',
                          '${product['name']} added to wishlist',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: BColors.secondary.withOpacity(0.8),
                          colorText: BColors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
