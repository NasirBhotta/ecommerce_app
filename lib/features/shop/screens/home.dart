import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/common/widgets/home/circular_container.dart';
import 'package:ecommerce_app/common/widgets/home/curved_edges.dart';
import 'package:ecommerce_app/common/widgets/home/empty_state.dart';
import 'package:ecommerce_app/common/widgets/home/product_card.dart';
import 'package:ecommerce_app/common/widgets/home/rounded_image.dart';
import 'package:ecommerce_app/common/widgets/home/search_container.dart';
import 'package:ecommerce_app/common/widgets/home/section_heading.dart';
import 'package:ecommerce_app/common/widgets/home/vertical_image_text.dart';
import 'package:ecommerce_app/features/shop/controllers/home_controller.dart';
import 'package:ecommerce_app/features/shop/screens/product_detail.dart';
import 'package:ecommerce_app/util/constants/sized.dart';

import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Curved Background
            BCurvedEdgeWidget(
              child: Container(
                color: BColors.primary,
                padding: const EdgeInsets.all(0),
                child: SizedBox(
                  child: Stack(
                    children: [
                      // Background Patterns
                      Positioned(
                        top: -150,
                        right: -250,
                        child: BCircularContainer(
                          backgroundColor: BColors.white.withOpacity(0.1),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        right: -300,
                        child: BCircularContainer(
                          backgroundColor: BColors.white.withOpacity(0.1),
                        ),
                      ),
                      // Content
                      Column(
                        children: [
                          // AppBar
                          Padding(
                            padding: const EdgeInsets.only(
                              left: BSizes.paddingMd,
                              right: BSizes.paddingMd,
                              top: BSizes.appBarHeight,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Good day for shopping',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .apply(color: BColors.white70),
                                    ),
                                    Text(
                                      'Nasir Bhutta',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .apply(color: BColors.white),
                                    ),
                                  ],
                                ),
                                Stack(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Iconsax.shopping_bag,
                                        color: BColors.white,
                                      ),
                                      onPressed: () {
                                        Get.snackbar(
                                          'Cart',
                                          'Opening shopping cart...',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: BColors.primary
                                              .withOpacity(0.8),
                                          colorText: BColors.white,
                                          duration: const Duration(seconds: 2),
                                        );
                                      },
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: BColors.black,
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '2',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall!.apply(
                                              color: BColors.white,
                                              fontSizeFactor: 0.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: BSizes.spaceBetweenSections),
                          // Search Field
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
                          // Categories Section - Hide when searching
                          Obx(
                            () =>
                                controller.isSearching.value
                                    ? const SizedBox.shrink()
                                    : Padding(
                                      padding: const EdgeInsets.only(
                                        left: BSizes.paddingMd,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          BSectionHeading(
                                            title: 'Popular Categories',
                                            showActionButton: false,
                                            textColor: BColors.white,
                                          ),
                                          const SizedBox(
                                            height: BSizes.spaceBetweenItems,
                                          ),
                                          // Categories List
                                          SizedBox(
                                            height: 80,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: 6,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (_, index) {
                                                return BVerticalImageText(
                                                  image:
                                                      'assets/icons/category.png',
                                                  title:
                                                      controller
                                                          .categories[index]['title']!,
                                                  onTap: () {
                                                    Get.snackbar(
                                                      'Category',
                                                      'You selected ${controller.categories[index]['title']}',
                                                      snackPosition:
                                                          SnackPosition.BOTTOM,
                                                      backgroundColor: BColors
                                                          .primary
                                                          .withOpacity(0.8),
                                                      colorText: BColors.white,
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
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
                          const SizedBox(height: BSizes.spaceBetweenSections),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Body Section
            Padding(
              padding: const EdgeInsets.all(BSizes.paddingMd),
              child: Obx(() {
                // Show search results when searching
                if (controller.isSearching.value) {
                  final filteredProducts = controller.filteredProducts;

                  if (filteredProducts.isEmpty) {
                    return SizedBox(
                      height: 400,
                      child: BEmptyState(
                        message:
                            'No products found for "${controller.searchQuery.value}"',
                        icon: Icons.search_off,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Results (${filteredProducts.length})',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: BSizes.spaceBetweenItems),
                      GridView.builder(
                        itemCount: filteredProducts.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        // Update the onTap in your HomeScreen's GridView.builder

                        // In the GridView.builder for products, replace the onTap:
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: BSizes.spaceBetweenItems,
                              crossAxisSpacing: BSizes.spaceBetweenItems,
                              mainAxisExtent: 288,
                            ),
                        itemBuilder: (_, index) {
                          final product = controller.allProducts[index];
                          return BProductCardVertical(
                            productName: product['name']!,
                            price: product['price']!,
                            discount: product['discount'],
                            onTap: () {
                              // Navigate to Product Detail Screen
                              Get.to(
                                () => ProductDetailScreen(
                                  productName: product['name']!,
                                  price: product['price']!,
                                  discount: product['discount'],
                                ),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 300),
                              );
                            },
                            onFavoriteTap: () {
                              Get.snackbar(
                                'Wishlist',
                                '${product['name']} added to wishlist',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: BColors.secondary.withOpacity(
                                  0.8,
                                ),
                                colorText: BColors.white,
                                duration: const Duration(seconds: 2),
                              );
                            },
                          );
                        },

                        // Also add this import at the top of your home_screen.dart:
                        // import 'package:ecommerce_app/features/shop/screens/product_detail_screen.dart';
                      ),
                    ],
                  );
                }

                // Show regular home content when not searching
                return Column(
                  children: [
                    // Promo Slider
                    Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            viewportFraction: 1,
                            height: 200,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 4),
                            autoPlayAnimationDuration: const Duration(
                              milliseconds: 800,
                            ),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            onPageChanged:
                                (index, _) =>
                                    controller.updatePageIndicator(index),
                          ),
                          items: [
                            BRoundedImage(
                              imageUrl:
                                  'assets/images/banners/promo-banner-1.png',
                              backgroundColor:
                                  isDark
                                      ? BColors.grey.withOpacity(0.1)
                                      : BColors.grey.withOpacity(0.1),
                              padding: const EdgeInsets.all(BSizes.paddingMd),
                              height: 200,
                              width: double.infinity,
                              // child: Container(
                              //   padding: const EdgeInsets.all(BSizes.paddingLg),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       Text(
                              //         'SNEAKERS OF\nTHE WEEK',
                              //         style: Theme.of(
                              //           context,
                              //         ).textTheme.headlineMedium!.apply(
                              //           color:
                              //               isDark
                              //                   ? BColors.white
                              //                   : BColors.black,
                              //           fontWeightDelta: 2,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  BSizes.cardRadius,
                                ),
                                gradient: LinearGradient(
                                  colors: [BColors.primary, BColors.secondary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    BSizes.paddingLg,
                                  ),
                                  child: Text(
                                    'Summer Sale\n50% OFF',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium!.apply(
                                      color: BColors.white,
                                      fontWeightDelta: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  BSizes.cardRadius,
                                ),
                                color:
                                    isDark
                                        ? BColors.grey.withOpacity(0.2)
                                        : BColors.grey.withOpacity(0.1),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    BSizes.paddingLg,
                                  ),
                                  child: Text(
                                    'New Arrivals\nCheck Now!',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium!.apply(
                                      color:
                                          isDark
                                              ? BColors.white
                                              : BColors.black,
                                      fontWeightDelta: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: BSizes.spaceBetweenItems),
                        // Carousel Indicator
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < 3; i++)
                                Container(
                                  width: 20,
                                  height: 4,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        controller.carousalCurrentIndex.value ==
                                                i
                                            ? BColors.primary
                                            : BColors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: BSizes.spaceBetweenSections),

                    // Popular Products Section
                    BSectionHeading(
                      title: 'Popular Products',
                      onPressed: () {
                        Get.snackbar(
                          'View All',
                          'Showing all products...',
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
                      itemCount: controller.allProducts.length,
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
                        final product = controller.allProducts[index];
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
                              backgroundColor: BColors.secondary.withOpacity(
                                0.8,
                              ),
                              colorText: BColors.white,
                              duration: const Duration(seconds: 2),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
