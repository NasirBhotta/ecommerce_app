import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/common/widgets/home/circular_container.dart';
import 'package:ecommerce_app/common/widgets/home/curved_edges.dart';
import 'package:ecommerce_app/common/widgets/home/product_card.dart';
import 'package:ecommerce_app/common/widgets/home/rounded_image.dart';
import 'package:ecommerce_app/common/widgets/home/search_container.dart';
import 'package:ecommerce_app/common/widgets/home/section_heading.dart';
import 'package:ecommerce_app/common/widgets/home/vertical_image_text.dart';
import 'package:ecommerce_app/features/shop/controllers/home_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';

import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
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
                                      onPressed: () {},
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
                          // Search Bar
                          const BSearchContainer(
                            text: 'Search in Store',
                            icon: Iconsax.search_normal,
                          ),
                          const SizedBox(height: BSizes.spaceBetweenSections),
                          // Categories Section
                          Padding(
                            padding: const EdgeInsets.only(
                              left: BSizes.paddingMd,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                        image: 'assets/icons/category.png',
                                        title:
                                            controller
                                                .categories[index]['title']!,
                                        onTap: () {},
                                      );
                                    },
                                  ),
                                ),
                              ],
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
              child: Column(
                children: [
                  // Promo Slider
                  Column(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          viewportFraction: 1,
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
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ),
                          BRoundedImage(
                            imageUrl:
                                'assets/images/banners/promo-banner-2.png',
                            backgroundColor:
                                isDark
                                    ? BColors.grey.withOpacity(0.1)
                                    : BColors.grey.withOpacity(0.1),
                            height: 200,
                            width: double.infinity,
                          ),
                          BRoundedImage(
                            imageUrl:
                                'assets/images/banners/promo-banner-3.png',
                            backgroundColor:
                                isDark
                                    ? BColors.grey.withOpacity(0.1)
                                    : BColors.grey.withOpacity(0.1),
                            height: 200,
                            width: double.infinity,
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
                                      controller.carousalCurrentIndex.value == i
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
                  BSectionHeading(title: 'Popular Products', onPressed: () {}),
                  const SizedBox(height: BSizes.spaceBetweenItems),

                  // Products Grid
                  GridView.builder(
                    itemCount: 4,
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
                      return const BProductCardVertical(
                        productName: 'Nike Air Jordan Shoes',
                        price: '\$299.99',
                        discount: '70%',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
