import 'package:ecommerce_app/features/shop/screens/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  // Observable for carousel index
  final carousalCurrentIndex = 0.obs;

  // Search controller and observables
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  // All products list
  final allProducts =
      <Map<String, String>>[
        {
          'id': '1',
          'name': 'Nike Air Jordan Shoes',
          'price': '\$299.99',
          'discount': '70%',
          'category': 'Sports',
        },
        {
          'id': '2',
          'name': 'Blue Cotton T-Shirt',
          'price': '\$49.99',
          'discount': '40%',
          'category': 'Clothes',
        },
        {
          'id': '3',
          'name': 'Adidas Running Sneakers',
          'price': '\$189.99',
          'discount': '50%',
          'category': 'Sports',
        },
        {
          'id': '4',
          'name': 'Leather Office Shoes',
          'price': '\$159.99',
          'discount': '30%',
          'category': 'Shoes',
        },
        {
          'id': '5',
          'name': 'Gaming Laptop Pro',
          'price': '\$1299.99',
          'discount': '15%',
          'category': 'Electronics',
        },
        {
          'id': '6',
          'name': 'Wireless Headphones',
          'price': '\$89.99',
          'discount': '25%',
          'category': 'Electronics',
        },
        {
          'id': '7',
          'name': 'Denim Jacket',
          'price': '\$79.99',
          'discount': '35%',
          'category': 'Clothes',
        },
        {
          'id': '8',
          'name': 'Smart Watch Series 5',
          'price': '\$399.99',
          'discount': '20%',
          'category': 'Electronics',
        },
        {
          'id': '9',
          'name': 'Casual Sneakers',
          'price': '\$69.99',
          'discount': '45%',
          'category': 'Shoes',
        },
        {
          'id': '10',
          'name': 'Cotton Polo Shirt',
          'price': '\$39.99',
          'discount': '30%',
          'category': 'Clothes',
        },
        {
          'id': '11',
          'name': 'Basketball Shoes',
          'price': '\$149.99',
          'discount': '40%',
          'category': 'Sports',
        },
        {
          'id': '12',
          'name': 'Modern Office Chair',
          'price': '\$249.99',
          'discount': '25%',
          'category': 'Furniture',
        },
      ].obs;

  // Filtered products based on search
  RxList<Map<String, String>> get filteredProducts {
    if (searchQuery.value.isEmpty) {
      return allProducts;
    }
    return allProducts
        .where(
          (product) =>
              product['name']!.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              product['category']!.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList()
        .obs;
  }

  // Update carousel index
  void updatePageIndicator(int index) {
    carousalCurrentIndex.value = index;
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

  void navigateToDetailedScreen(Map<String, String> product) {
    Get.to(
      () => ProductDetailScreen(
        productName: product['name']!,
        price: product['price']!,
        discount: product['discount'],
      ),
      transition: Transition.rightToLeft,
    );
  }

  // Sample categories data
  final categories = [
    {'icon': 'sports_baseball', 'title': 'Sports'},
    {'icon': 'chair', 'title': 'Furniture'},
    {'icon': 'devices', 'title': 'Electronics'},
    {'icon': 'checkroom', 'title': 'Clothes'},
    {'icon': 'pets', 'title': 'Animals'},
    {'icon': 'shopping_bag', 'title': 'Shoes'},
  ];

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
