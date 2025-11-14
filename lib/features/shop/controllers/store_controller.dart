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

  // Categories
  final categories = ['Sports', 'Furniture', 'Electronics', 'Clothes'];

  // Featured brands with their data
  final featuredBrands = [
    {
      'name': 'Nike',
      'logo': 'assets/logos/nike.png',
      'productCount': 265,
      'verified': true,
      'products': [
        {
          'name': 'Nike Air Max',
          'price': '\$299.99',
          'discount': '50%',
          'image': 'assets/images/products/nike-1.png',
        },
        {
          'name': 'Nike Jordan',
          'price': '\$249.99',
          'discount': '40%',
          'image': 'assets/images/products/nike-2.png',
        },
        {
          'name': 'Nike Running',
          'price': '\$189.99',
          'discount': '30%',
          'image': 'assets/images/products/nike-3.png',
        },
      ],
    },
    {
      'name': 'Adidas',
      'logo': 'assets/logos/adidas.png',
      'productCount': 145,
      'verified': true,
      'products': [
        {
          'name': 'Adidas Ultraboost',
          'price': '\$179.99',
          'discount': '35%',
          'image': 'assets/images/products/adidas-1.png',
        },
        {
          'name': 'Adidas Soccer Ball',
          'price': '\$49.99',
          'discount': '20%',
          'image': 'assets/images/products/adidas-2.png',
        },
        {
          'name': 'Adidas Training',
          'price': '\$89.99',
          'discount': '25%',
          'image': 'assets/images/products/adidas-3.png',
        },
      ],
    },
    {
      'name': 'Kenwood',
      'logo': 'assets/logos/kenwood.png',
      'productCount': 95,
      'verified': true,
      'products': [
        {
          'name': 'Kitchen Mixer',
          'price': '\$399.99',
          'discount': '15%',
          'image': 'assets/images/products/kenwood-1.png',
        },
        {
          'name': 'Food Processor',
          'price': '\$299.99',
          'discount': '20%',
          'image': 'assets/images/products/kenwood-2.png',
        },
        {
          'name': 'Hand Blender',
          'price': '\$149.99',
          'discount': '10%',
          'image': 'assets/images/products/kenwood-3.png',
        },
      ],
    },
    {
      'name': 'IKEA',
      'logo': 'assets/logos/ikea.png',
      'productCount': 187,
      'verified': true,
      'products': [
        {
          'name': 'Office Desk',
          'price': '\$249.99',
          'discount': '30%',
          'image': 'assets/images/products/ikea-1.png',
        },
        {
          'name': 'Bookshelf',
          'price': '\$149.99',
          'discount': '25%',
          'image': 'assets/images/products/ikea-2.png',
        },
        {
          'name': 'Table Lamp',
          'price': '\$39.99',
          'discount': '15%',
          'image': 'assets/images/products/ikea-3.png',
        },
      ],
    },
  ];

  // All products for "You might like" section
  final suggestedProducts = [
    {
      'name': 'Nike Air Zoom',
      'price': '\$159.99',
      'discount': '40%',
      'image': 'assets/images/products/suggest-1.png',
    },
    {
      'name': 'Jordan Retro',
      'price': '\$289.99',
      'discount': '35%',
      'image': 'assets/images/products/suggest-2.png',
    },
    {
      'name': 'Nike Running Pro',
      'price': '\$199.99',
      'discount': '30%',
      'image': 'assets/images/products/suggest-3.png',
    },
    {
      'name': 'Air Force One',
      'price': '\$229.99',
      'discount': '45%',
      'image': 'assets/images/products/suggest-4.png',
    },
  ];

  // Get filtered brands based on selected category
  List<Map<String, dynamic>> get filteredBrands {
    // For now, return all brands. In a real app, you'd filter by category
    return featuredBrands;
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
    Get.snackbar(
      'Brand',
      'Viewing all products from $brandName',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
