import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  // Observable for selected color
  final selectedColorIndex = 0.obs;

  // Observable for selected size
  final selectedSizeIndex = 0.obs;

  // Observable for selected variant image
  final selectedImageIndex = 0.obs;

  // Observable for quantity
  final quantity = 0.obs;

  // Observable for favorite
  final isFavorite = false.obs;

  // Available colors
  final colors = [
    {'name': 'Green', 'color': '0xFF00BFA6'},
    {'name': 'Black', 'color': '0xFF000000'},
    {'name': 'Red', 'color': '0xFFFF5252'},
  ];

  // Available sizes
  final sizes = ['EU 30', 'EU 32', 'EU 34', 'EU 36', 'EU 38'];

  // Product variant images
  final variantImages = [
    'assets/images/products/nike-green.png',
    'assets/images/products/nike-black.png',
    'assets/images/products/nike-red.png',
    'assets/images/products/nike-purple.png',
  ];

  // Select color
  void selectColor(int index) {
    selectedColorIndex.value = index;
  }

  // Select size
  void selectSize(int index) {
    selectedSizeIndex.value = index;
  }

  // Select variant image
  void selectImage(int index) {
    selectedImageIndex.value = index;
  }

  // Increase quantity
  void increaseQuantity() {
    quantity.value++;
  }

  // Decrease quantity
  void decreaseQuantity() {
    if (quantity.value > 0) {
      quantity.value--;
    }
  }

  // Toggle favorite
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  // Add to bag
  void addToBag() {
    if (quantity.value > 0) {
      Get.snackbar(
        'Success',
        '${quantity.value} item(s) added to bag',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Info',
        'Please select quantity first',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Checkout
  void checkout() {
    if (quantity.value > 0) {
      Get.snackbar(
        'Checkout',
        'Proceeding to checkout...',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Info',
        'Please add items to cart first',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
