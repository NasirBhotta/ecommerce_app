import 'package:ecommerce_app/features/shop/models/cart_item.dart';
import 'package:ecommerce_app/features/shop/screens/checkout/checkout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  // Observable cart items
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  // Loading state
  final isLoading = false.obs;
  final RxList<CartItem> cartItemsCount = <CartItem>[].obs;

  // Reactive cart count
  RxInt get cartCount => cartItemsCount.fold<RxInt>(0.obs, (prev, item) {
    prev.value += item.quantity.value;
    return prev;
  });

  // Get quantity of a specific product
  int getProductQuantity(String productId) {
    // If productId is empty, try to match by name or return 0
    if (productId.isEmpty) return 0;

    final item = cartItems.firstWhere(
      (element) => element['id'] == productId,
      orElse: () => {},
    );
    return item.isNotEmpty ? item['quantity'] : 0;
  }

  // Calculate total quantity
  int get totalQuantity {
    return cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  // Calculate subtotal
  double get subtotal {
    return cartItems.fold(
      0.0,
      (sum, item) =>
          sum + (item['quantity'] * _parsePrice(item['price'] as String)),
    );
  }

  // Calculate tax (10%)
  double get tax => subtotal * 0.10;

  // Calculate shipping
  double get shipping => cartItems.isEmpty ? 0.0 : 50.0;

  // Calculate total
  double get total => subtotal + tax + shipping;

  // Parse price string to double
  double _parsePrice(String price) {
    return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
  }

  // Add item to cart
  void addToCart(Map<String, dynamic> product) {
    // Check if product already exists
    final existingIndex = cartItems.indexWhere(
      (item) => item['id'] == product['id'],
    );

    if (existingIndex != -1) {
      // Increase quantity
      cartItems[existingIndex]['quantity']++;
      Get.snackbar(
        'Updated',
        'Quantity updated in cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      // Add new item
      cartItems.add({
        'id': product['id'] ?? DateTime.now().toString(),
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'brand': product['brand'] ?? 'Unknown',
        'size': product['size'] ?? 'M',
        'color': product['color'] ?? 'Default',
        'quantity': 1,
      });
      Get.snackbar(
        'Added to Cart',
        '${product['name']} added to cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Remove item from cart
  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item['id'] == productId);
    Get.snackbar(
      'Removed',
      'Item removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Update quantity
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      cartItems.refresh();
      return;
    }

    final index = cartItems.indexWhere((item) => item['id'] == productId);
    if (index != -1) {
      cartItems[index]['quantity'] = quantity;
      cartItems.refresh();
    }
  }

  // Increase quantity
  void increaseQuantity(String productId) {
    final index = cartItems.indexWhere((item) => item['id'] == productId);
    if (index != -1) {
      cartItems[index]['quantity']++;
      cartItems.refresh();
    }
  }

  // Decrease quantity
  void decreaseQuantity(String productId) {
    final index = cartItems.indexWhere((item) => item['id'] == productId);
    if (index != -1) {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
        cartItems.refresh();
      } else {
        removeFromCart(productId);
        cartItems.refresh();
      }
    }
  }

  // Clear cart
  void clearCart() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              cartItems.clear();
              Get.back();
              Get.snackbar(
                'Cart Cleared',
                'All items removed from cart',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Proceed to checkout
  void proceedToCheckout() {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Add items to cart before checkout',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(() => const CheckoutScreen()); 
  }

  // Apply coupon
  void applyCoupon(String couponCode) {
    // Validate and apply coupon
    Get.snackbar(
      'Coupon',
      'Coupon "$couponCode" applied',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Load sample data
  void loadSampleData() {
    if (cartItems.isEmpty) {
      cartItems.addAll([
        {
          'id': '1',
          'name': 'Nike Air Jordan Shoes',
          'price': '\$299.99',
          'image': '',
          'brand': 'Nike',
          'size': 'EU 42',
          'color': 'Black',
          'quantity': 2,
        },
        {
          'id': '2',
          'name': 'Blue Cotton T-Shirt',
          'price': '\$49.99',
          'image': '',
          'brand': 'Adidas',
          'size': 'L',
          'color': 'Blue',
          'quantity': 1,
        },
      ]);
    }
  }

  // Firebase methods (implement when connecting to Firebase)

  // Future<void> syncCartWithFirebase(String userId) async {
  //   try {
  //     isLoading.value = true;
  //     final cartRef = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('cart');
  //
  //     final snapshot = await cartRef.get();
  //     cartItems.value = snapshot.docs
  //         .map((doc) => {...doc.data(), 'id': doc.id})
  //         .toList();
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to load cart');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<void> saveCartToFirebase(String userId) async {
  //   try {
  //     final cartRef = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('cart');
  //
  //     // Clear existing cart
  //     final batch = FirebaseFirestore.instance.batch();
  //     final snapshot = await cartRef.get();
  //     for (var doc in snapshot.docs) {
  //       batch.delete(doc.reference);
  //     }
  //
  //     // Add current cart items
  //     for (var item in cartItems) {
  //       final docRef = cartRef.doc();
  //       batch.set(docRef, item);
  //     }
  //
  //     await batch.commit();
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to save cart');
  //   }
  // }
}
