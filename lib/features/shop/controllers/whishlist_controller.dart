import 'package:get/get.dart';

class WishlistController extends GetxController {
  static WishlistController get instance => Get.find();

  // Observable list of wishlist items
  final RxList<Map<String, dynamic>> wishlistItems =
      <Map<String, dynamic>>[].obs;

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    return wishlistItems.any((item) => item['id'] == productId);
  }

  // Add product to wishlist
  void addToWishlist(Map<String, dynamic> product) {
    if (!isInWishlist(product['id'])) {
      wishlistItems.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'discount': product['discount'],
        'image': product['image'],
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
  void removeFromWishlist(String productId) {
    wishlistItems.removeWhere((item) => item['id'] == productId);

    Get.snackbar(
      'Removed from Wishlist',
      'Item has been removed from your wishlist',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Toggle wishlist status
  void toggleWishlist(Map<String, dynamic> product) {
    if (isInWishlist(product['id'])) {
      removeFromWishlist(product['id']);
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

  // Add some sample data for demo
  void addSampleData() {
    if (wishlistItems.isEmpty) {
      final sampleProducts = [
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
      ];

      for (var product in sampleProducts) {
        addToWishlist(product);
      }
    }
  }
}
