import 'package:get/get.dart';

class WishlistController extends GetxController {
  static WishlistController get instance => Get.find();

  // Observable list of wishlist items
  final RxList<Map<String, dynamic>> wishlistItems =
      <Map<String, dynamic>>[].obs;

  // Check if product is in wishlist
  bool isInWishlist(String productName) {
    return wishlistItems.any((item) => item['name'] == productName);
  }

  // Add product to wishlist
  void addToWishlist(Map<String, dynamic> product) {
    if (!isInWishlist(product['name'])) {
      wishlistItems.add({
        'name': product['name'],
        'price': product['price'],
        'discount': product['discount'],
        'category': product['category'] ?? 'General',
        'addedAt': DateTime.now(),
      });

      Get.snackbar(
        'Added to Wishlist',
        '${product['name']} has been added to your wishlist',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Remove product from wishlist
  void removeFromWishlist(String productName) {
    wishlistItems.removeWhere((item) => item['name'] == productName);

    Get.snackbar(
      'Removed from Wishlist',
      '$productName has been removed from your wishlist',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Toggle wishlist status
  void toggleWishlist(Map<String, dynamic> product) {
    if (isInWishlist(product['name'])) {
      removeFromWishlist(product['name']);
    } else {
      addToWishlist(product);
    }
  }

  // Clear all wishlist items
  void clearWishlist() {
    wishlistItems.clear();

    Get.snackbar(
      'Wishlist Cleared',
      'All items have been removed from your wishlist',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Get wishlist count
  int get wishlistCount => wishlistItems.length;

  // Get wishlist items by category
  List<Map<String, dynamic>> getItemsByCategory(String category) {
    return wishlistItems.where((item) => item['category'] == category).toList();
  }

  // Sort wishlist by date added (newest first)
  List<Map<String, dynamic>> get sortedByNewest {
    final sorted = List<Map<String, dynamic>>.from(wishlistItems);
    sorted.sort((a, b) => b['addedAt'].compareTo(a['addedAt']));
    return sorted;
  }

  // Sort wishlist by date added (oldest first)
  List<Map<String, dynamic>> get sortedByOldest {
    final sorted = List<Map<String, dynamic>>.from(wishlistItems);
    sorted.sort((a, b) => a['addedAt'].compareTo(b['addedAt']));
    return sorted;
  }

  // Add some sample data for demo
  void addSampleData() {
    if (wishlistItems.isEmpty) {
      final sampleProducts = [
        {
          'name': 'Nike Air Jordan Shoes',
          'price': '\$299.99',
          'discount': '70%',
          'category': 'Sports',
        },
        {
          'name': 'Blue Cotton T-Shirt',
          'price': '\$49.99',
          'discount': '40%',
          'category': 'Clothes',
        },
        {
          'name': 'Adidas Running Sneakers',
          'price': '\$189.99',
          'discount': '50%',
          'category': 'Sports',
        },
      ];

      for (var product in sampleProducts) {
        addToWishlist(product);
      }
    }
  }
}
