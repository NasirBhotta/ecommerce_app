import 'package:ecommerce_app/features/shop/screens/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/features/shop/models/product_model.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  // Observable for carousel index
  final carousalCurrentIndex = 0.obs;

  // Search controller and observables
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  final ProductRepository _productRepo = ProductRepository.instance;

  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Filtered products based on search
  RxList<ProductModel> get filteredProducts {
    if (searchQuery.value.isEmpty) {
      return allProducts;
    }
    return allProducts
        .where(
          (product) =>
              product.name.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              product.category.toLowerCase().contains(
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

  void navigateToDetailedScreen(ProductModel product) {
    Get.to(
      () => ProductDetailScreen(product: product),
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
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final products =
          await _productRepo.fetchAllProducts(forceRefresh: forceRefresh);
      allProducts.assignAll(products);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
