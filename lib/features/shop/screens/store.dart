import 'package:ecommerce_app/common/widgets/home/product_card.dart';
import 'package:ecommerce_app/common/widgets/home/search_container.dart';
import 'package:ecommerce_app/common/widgets/home/section_heading.dart';
import 'package:ecommerce_app/common/widgets/store/brand_card.dart';
import 'package:ecommerce_app/common/widgets/store/brand_showcase.dart';
import 'package:ecommerce_app/common/widgets/store/category_tab.dart';
import 'package:ecommerce_app/features/shop/controllers/cart_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/store_controller.dart';
import 'package:ecommerce_app/features/shop/screens/cart.dart';
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
    final cartController = Get.find<CartController>();
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
                  Get.to(
                    () => const CartScreen(),
                    transition: Transition.rightToLeft,
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Obx(
                  () =>
                      cartController.totalQuantity > 0
                          ? Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: BColors.black,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Text(
                                '${cartController.totalQuantity}',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall!.apply(
                                  color: BColors.white,
                                  fontSizeFactor: 0.7,
                                ),
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
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
                      Obx(
                        () => BSectionHeading(
                          title: 'Featured Brands',
                          showActionButton: true,
                          buttonTitle:
                              controller.isFeaturedBrandsExpanded.value
                                  ? 'Show Less'
                                  : 'View All',
                          onPressed: controller.toggleFeaturedBrands,
                        ),
                      ),
                      Obx(
                        () => GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: controller.featuredBrands.length,
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
                              onTap: () {
                                // Navigate to brand detail screen
                                Get.to(
                                  () => BrandDetailScreen(
                                    brandName: brand['name'] as String,
                                    category: brand['category'] as String,
                                  ),
                                  transition: Transition.rightToLeft,
                                );
                              },
                            );
                          },
                        ),
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
            child: Obx(
              () => Column(
                children: [
                  // Brand Showcases with Products for selected category
                  ...List.generate(controller.filteredBrands.length, (index) {
                    final brand = controller.filteredBrands[index];
                    final products =
                        brand['products'] as List<Map<String, dynamic>>;

                    return BBrandShowcase(
                      brandName: brand['name'] as String,
                      productCount: brand['productCount'] as int,
                      verified: brand['verified'] as bool,
                      products:
                          products
                              .map(
                                (p) => {
                                  'name': p['name'] as String,
                                  'price': p['price'] as String,
                                  'discount': (p['discount'] as String?) ?? '',
                                  'image': p['image'] as String,
                                },
                              )
                              .toList(),
                      onBrandTap: () {
                        // Navigate to brand detail screen
                        Get.to(
                          () => BrandDetailScreen(
                            brandName: brand['name'] as String,
                            category: brand['category'] as String,
                          ),
                          transition: Transition.rightToLeft,
                        );
                      },
                    );
                  }),

                  const SizedBox(height: BSizes.spaceBetweenSections),

                  // You Might Like Section
                  BSectionHeading(
                    title: 'You might like',
                    showActionButton: true,
                    buttonTitle:
                        controller.isYouMightLikeExpanded.value
                            ? 'Show Less'
                            : 'View All',
                    onPressed: controller.toggleYouMightLike,
                  ),

                  const SizedBox(height: BSizes.spaceBetweenItems),

                  // Products Grid
                  GridView.builder(
                    itemCount: controller.suggestedProducts.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: BSizes.spaceBetweenItems,
                          crossAxisSpacing: BSizes.spaceBetweenItems,
                          mainAxisExtent: 288,
                        ),
                    itemBuilder: (_, index) {
                      final product = controller.suggestedProducts[index];
                      return BProductCardVertical(
                        productId: product['id']!,
                        productName: product['name']!,
                        price: product['price']!,
                        discount: product['discount'],
                        onTap: () {
                          Get.snackbar(
                            'Product',
                            'You tapped on ${product['name']}',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: BColors.primary.withValues(
                              alpha: 0.8,
                            ),
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
      ),
    );
  }
}

// Brand Detail Screen - New Screen for showing brand products
class BrandDetailScreen extends StatefulWidget {
  final String brandName;
  final String category;

  const BrandDetailScreen({
    super.key,
    required this.brandName,
    required this.category,
  });

  @override
  State<BrandDetailScreen> createState() => _BrandDetailScreenState();
}

class _BrandDetailScreenState extends State<BrandDetailScreen> {
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    final controller = Get.find<StoreController>();

    // Find the brand
    final brand = controller.allBrands.firstWhere(
      (b) => b['name'] == widget.brandName && b['category'] == widget.category,
      orElse: () => {},
    );

    if (brand.isEmpty) return [];

    final products = brand['products'] as List<Map<String, dynamic>>;

    // Filter by search query if searching
    if (searchQuery.value.isEmpty) {
      return products;
    }

    return products
        .where(
          (product) => product['name']!.toString().toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        )
        .toList();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    isSearching.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<StoreController>();
    final cartController = Get.find<CartController>();

    // Find brand data
    final brand = controller.allBrands.firstWhere(
      (b) => b['name'] == widget.brandName && b['category'] == widget.category,
      orElse: () => {},
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? BColors.black : BColors.white,
        elevation: 0,
        title: Text(
          '${widget.brandName} - ${widget.category}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Iconsax.shopping_bag),
                onPressed: () {
                  Get.to(
                    () => const CartScreen(),
                    transition: Transition.rightToLeft,
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Obx(
                  () =>
                      cartController.totalQuantity > 0
                          ? Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: BColors.black,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Text(
                                '${cartController.totalQuantity}',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall!.apply(
                                  color: BColors.white,
                                  fontSizeFactor: 0.7,
                                ),
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(BSizes.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Obx(
                () => BSearchField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  hintText: 'Search ${widget.brandName} products',
                  showClearButton: isSearching.value,
                  onClear: clearSearch,
                ),
              ),
              const SizedBox(height: BSizes.spaceBetweenSections),

              // Brand Info
              if (brand.isNotEmpty)
                BBrandCard(
                  brandName: brand['name'] as String,
                  productCount: brand['productCount'] as int,
                  verified: brand['verified'] as bool,
                  onTap: () {},
                ),

              const SizedBox(height: BSizes.spaceBetweenSections),

              // Products Header
              Obx(() {
                final products = filteredProducts;
                return Text(
                  'Products (${products.length})',
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              }),

              const SizedBox(height: BSizes.spaceBetweenItems),

              // Products Grid
              Obx(() {
                final products = filteredProducts;

                if (products.isEmpty) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'No products found',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  itemCount: products.length,
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
                    final product = products[index];
                    return BProductCardVertical(
                      productId: product['id']!,
                      productName: product['name']!,
                      price: product['price']!,
                      discount: product['discount'],
                      onTap: () {
                        Get.snackbar(
                          'Product',
                          'You tapped on ${product['name']}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: BColors.primary.withValues(
                            alpha: 0.8,
                          ),
                          colorText: BColors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                    );
                  },
                );
              }),

              const SizedBox(height: BSizes.spaceBetweenSections),
            ],
          ),
        ),
      ),
    );
  }
}
