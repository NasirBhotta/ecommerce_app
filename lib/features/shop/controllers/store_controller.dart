import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/features/shop/models/brand_model.dart';
import 'package:ecommerce_app/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreController extends GetxController {
  static StoreController get instance => Get.find();

  // Search controller and observables
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  final ProductRepository _productRepo = ProductRepository.instance;

  // Selected category
  final selectedCategoryIndex = 0.obs;

  // Expansion states
  final isFeaturedBrandsExpanded = false.obs;
  final isYouMightLikeExpanded = false.obs;

  // Categories
  final categories = <String>[].obs;

  final RxList<BrandModel> allBrands = <BrandModel>[].obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> allSuggestedProducts = <ProductModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Get featured brands (first 4)
  List<BrandModel> get featuredBrands {
    return isFeaturedBrandsExpanded.value
        ? allBrands
        : allBrands.take(4).toList();
  }

  // Get suggested products
  List<ProductModel> get suggestedProducts {
    return isYouMightLikeExpanded.value
        ? allSuggestedProducts
        : allSuggestedProducts.take(4).toList();
  }

  // Get filtered brands based on selected category
  List<BrandModel> get filteredBrands {
    if (categories.isEmpty) return [];
    final selectedCategory = categories[selectedCategoryIndex.value];
    return allBrands
        .where((brand) => brand.category == selectedCategory)
        .toList();
  }

  List<ProductModel> productsForBrand(String brandId) {
    return allProducts.where((product) => product.brandId == brandId).toList();
  }

  int productCountForBrand(String brandId) {
    final brand = allBrands.firstWhereOrNull((b) => b.id == brandId);
    if (brand != null && brand.productCount > 0) return brand.productCount;
    return productsForBrand(brandId).length;
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
  void viewBrandProducts(BrandModel brand) {
    final selectedCategory =
        categories.isEmpty ? brand.category : categories[selectedCategoryIndex.value];
    Get.toNamed(
      '/brand-products',
      arguments: {
        'brandId': brand.id,
        'brandName': brand.name,
        'category': selectedCategory,
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadStoreData();
  }

  Future<void> loadStoreData({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final brands = await _productRepo.fetchBrands();
      final products =
          await _productRepo.fetchAllProducts(forceRefresh: forceRefresh);
      final suggested =
          await _productRepo.fetchSuggestedProducts(forceRefresh: forceRefresh);

      allBrands.assignAll(brands);
      allProducts.assignAll(products);
      allSuggestedProducts.assignAll(suggested);
      _setCategoriesFromBrands();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _setCategoriesFromBrands() {
    final unique =
        allBrands
            .map((b) => b.category)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();

    if (unique.isEmpty) {
      final fromProducts =
          allProducts
              .map((p) => p.category)
              .where((c) => c.isNotEmpty)
              .toSet()
              .toList();
      categories.assignAll(fromProducts);
    } else {
      categories.assignAll(unique);
    }

    if (selectedCategoryIndex.value >= categories.length) {
      selectedCategoryIndex.value = 0;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
