import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreController extends GetxController {
  static StoreController get instance => Get.find();

  // Search controller and observables
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  // Selected category
  final selectedCategoryIndex = 0.obs;

  // Expansion states
  final isFeaturedBrandsExpanded = false.obs;
  final isYouMightLikeExpanded = false.obs;

  // Categories
  final categories = ['Sports', 'Furniture', 'Electronics', 'Clothes'];

  // All brands with their data
  final allBrands = [
    {
      'name': 'Nike',
      'logo': 'assets/logos/nike.png',
      'productCount': 265,
      'verified': true,
      'category': 'Sports',
      'products': [
        {
          'id': 'nike1',
          'name': 'Nike Air Max',
          'price': '\$299.99',
          'discount': '50%',
          'image': 'assets/images/products/nike-1.png',
          'category': 'Sports',
        },
        {
          'id': 'nike2',
          'name': 'Nike Jordan',
          'price': '\$249.99',
          'discount': '40%',
          'image': 'assets/images/products/nike-2.png',
          'category': 'Sports',
        },
        {
          'id': 'nike3',
          'name': 'Nike Running',
          'price': '\$189.99',
          'discount': '30%',
          'image': 'assets/images/products/nike-3.png',
          'category': 'Sports',
        },
      ],
    },
    {
      'name': 'Adidas',
      'logo': 'assets/logos/adidas.png',
      'productCount': 145,
      'verified': true,
      'category': 'Sports',
      'products': [
        {
          'id': 'adidas1',
          'name': 'Adidas Ultraboost',
          'price': '\$179.99',
          'discount': '35%',
          'image': 'assets/images/products/adidas-1.png',
          'category': 'Sports',
        },
        {
          'id': 'adidas2',
          'name': 'Adidas Soccer Ball',
          'price': '\$49.99',
          'discount': '20%',
          'image': 'assets/images/products/adidas-2.png',
          'category': 'Sports',
        },
        {
          'id': 'adidas3',
          'name': 'Adidas Training',
          'price': '\$89.99',
          'discount': '25%',
          'image': 'assets/images/products/adidas-3.png',
          'category': 'Sports',
        },
      ],
    },
    {
      'name': 'Puma',
      'logo': 'assets/logos/puma.png',
      'productCount': 98,
      'verified': true,
      'category': 'Sports',
      'products': [
        {
          'id': 'puma1',
          'name': 'Puma Suede Classic',
          'price': '\$129.99',
          'discount': '30%',
          'image': 'assets/images/products/puma-1.png',
          'category': 'Sports',
        },
        {
          'id': 'puma2',
          'name': 'Puma RS-X',
          'price': '\$159.99',
          'discount': '25%',
          'image': 'assets/images/products/puma-2.png',
          'category': 'Sports',
        },
      ],
    },
    {
      'name': 'IKEA',
      'logo': 'assets/logos/ikea.png',
      'productCount': 187,
      'verified': true,
      'category': 'Furniture',
      'products': [
        {
          'id': 'ikea1',
          'name': 'Office Desk',
          'price': '\$249.99',
          'discount': '30%',
          'image': 'assets/images/products/ikea-1.png',
          'category': 'Furniture',
        },
        {
          'id': 'ikea2',
          'name': 'Bookshelf',
          'price': '\$149.99',
          'discount': '25%',
          'image': 'assets/images/products/ikea-2.png',
          'category': 'Furniture',
        },
        {
          'id': 'ikea3',
          'name': 'Table Lamp',
          'price': '\$39.99',
          'discount': '15%',
          'image': 'assets/images/products/ikea-3.png',
          'category': 'Furniture',
        },
      ],
    },
    {
      'name': 'Ashley',
      'logo': 'assets/logos/ashley.png',
      'productCount': 156,
      'verified': true,
      'category': 'Furniture',
      'products': [
        {
          'id': 'ashley1',
          'name': 'Sofa Set',
          'price': '\$899.99',
          'discount': '35%',
          'image': 'assets/images/products/ashley-1.png',
          'category': 'Furniture',
        },
        {
          'id': 'ashley2',
          'name': 'Dining Table',
          'price': '\$549.99',
          'discount': '20%',
          'image': 'assets/images/products/ashley-2.png',
          'category': 'Furniture',
        },
      ],
    },
    {
      'name': 'Kenwood',
      'logo': 'assets/logos/kenwood.png',
      'productCount': 95,
      'verified': true,
      'category': 'Electronics',
      'products': [
        {
          'id': 'kenwood1',
          'name': 'Kitchen Mixer',
          'price': '\$399.99',
          'discount': '15%',
          'image': 'assets/images/products/kenwood-1.png',
          'category': 'Electronics',
        },
        {
          'id': 'kenwood2',
          'name': 'Food Processor',
          'price': '\$299.99',
          'discount': '20%',
          'image': 'assets/images/products/kenwood-2.png',
          'category': 'Electronics',
        },
        {
          'id': 'kenwood3',
          'name': 'Hand Blender',
          'price': '\$149.99',
          'discount': '10%',
          'image': 'assets/images/products/kenwood-3.png',
          'category': 'Electronics',
        },
      ],
    },
    {
      'name': 'Samsung',
      'logo': 'assets/logos/samsung.png',
      'productCount': 234,
      'verified': true,
      'category': 'Electronics',
      'products': [
        {
          'id': 'samsung1',
          'name': 'Smart TV 55"',
          'price': '\$799.99',
          'discount': '25%',
          'image': 'assets/images/products/samsung-1.png',
          'category': 'Electronics',
        },
        {
          'id': 'samsung2',
          'name': 'Galaxy Watch',
          'price': '\$349.99',
          'discount': '20%',
          'image': 'assets/images/products/samsung-2.png',
          'category': 'Electronics',
        },
      ],
    },
    {
      'name': 'Zara',
      'logo': 'assets/logos/zara.png',
      'productCount': 312,
      'verified': true,
      'category': 'Clothes',
      'products': [
        {
          'id': 'zara1',
          'name': 'Denim Jacket',
          'price': '\$89.99',
          'discount': '40%',
          'image': 'assets/images/products/zara-1.png',
          'category': 'Clothes',
        },
        {
          'id': 'zara2',
          'name': 'Cotton T-Shirt',
          'price': '\$29.99',
          'discount': '30%',
          'image': 'assets/images/products/zara-2.png',
          'category': 'Clothes',
        },
        {
          'id': 'zara3',
          'name': 'Casual Pants',
          'price': '\$59.99',
          'discount': '35%',
          'image': 'assets/images/products/zara-3.png',
          'category': 'Clothes',
        },
      ],
    },
    {
      'name': 'H&M',
      'logo': 'assets/logos/hm.png',
      'productCount': 278,
      'verified': true,
      'category': 'Clothes',
      'products': [
        {
          'id': 'hm1',
          'name': 'Summer Dress',
          'price': '\$49.99',
          'discount': '45%',
          'image': 'assets/images/products/hm-1.png',
          'category': 'Clothes',
        },
        {
          'id': 'hm2',
          'name': 'Blazer',
          'price': '\$79.99',
          'discount': '30%',
          'image': 'assets/images/products/hm-2.png',
          'category': 'Clothes',
        },
      ],
    },
  ];

  // All products for "You might like" section
  final allSuggestedProducts = [
    {
      'id': 'suggest1',
      'name': 'Nike Air Zoom',
      'price': '\$159.99',
      'discount': '40%',
      'image': 'assets/images/products/suggest-1.png',
    },
    {
      'id': 'suggest2',
      'name': 'Jordan Retro',
      'price': '\$289.99',
      'discount': '35%',
      'image': 'assets/images/products/suggest-2.png',
    },
    {
      'id': 'suggest3',
      'name': 'Nike Running Pro',
      'price': '\$199.99',
      'discount': '30%',
      'image': 'assets/images/products/suggest-3.png',
    },
    {
      'id': 'suggest4',
      'name': 'Air Force One',
      'price': '\$229.99',
      'discount': '45%',
      'image': 'assets/images/products/suggest-4.png',
    },
    {
      'id': 'suggest5',
      'name': 'IKEA Office Chair',
      'price': '\$199.99',
      'discount': '30%',
      'image': 'assets/images/products/suggest-5.png',
    },
    {
      'id': 'suggest6',
      'name': 'Samsung Buds Pro',
      'price': '\$149.99',
      'discount': '25%',
      'image': 'assets/images/products/suggest-6.png',
    },
    {
      'id': 'suggest7',
      'name': 'Zara Polo Shirt',
      'price': '\$39.99',
      'discount': '50%',
      'image': 'assets/images/products/suggest-7.png',
    },
    {
      'id': 'suggest8',
      'name': 'Adidas Cap',
      'price': '\$29.99',
      'discount': '20%',
      'image': 'assets/images/products/suggest-8.png',
    },
  ];

  // Get featured brands (first 4)
  List<Map<String, dynamic>> get featuredBrands {
    return isFeaturedBrandsExpanded.value
        ? allBrands
        : allBrands.take(4).toList();
  }

  // Get suggested products
  List<Map<String, dynamic>> get suggestedProducts {
    return isYouMightLikeExpanded.value
        ? allSuggestedProducts
        : allSuggestedProducts.take(4).toList();
  }

  // Get filtered brands based on selected category
  List<Map<String, dynamic>> get filteredBrands {
    final selectedCategory = categories[selectedCategoryIndex.value];
    return allBrands
        .where((brand) => brand['category'] == selectedCategory)
        .toList();
  }

  // Get all products for selected category
  List<Map<String, dynamic>> get categoryProducts {
    final selectedCategory = categories[selectedCategoryIndex.value];
    List<Map<String, dynamic>> products = [];

    for (var brand in allBrands) {
      if (brand['category'] == selectedCategory) {
        final brandProducts = brand['products'] as List<Map<String, dynamic>>;
        products.addAll(brandProducts);
      }
    }

    return products;
  }

  // Toggle featured brands expansion
  void toggleFeaturedBrands() {
    isFeaturedBrandsExpanded.value = !isFeaturedBrandsExpanded.value;
  }

  // Toggle you might like expansion
  void toggleYouMightLike() {
    isYouMightLikeExpanded.value = !isYouMightLikeExpanded.value;
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    isSearching.value = false;
  }

  // Select category
  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  // Navigate to brand products
  void viewBrandProducts(String brandName) {
    final selectedCategory = categories[selectedCategoryIndex.value];
    Get.toNamed(
      '/brand-products',
      arguments: {'brandName': brandName, 'category': selectedCategory},
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
