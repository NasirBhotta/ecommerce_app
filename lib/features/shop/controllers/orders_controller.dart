import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  static OrdersController get instance => Get.find();

  // Observable orders list
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;

  // Loading state
  final isLoading = false.obs;

  // Filter
  final selectedFilter = 'All'.obs;
  final filterOptions = [
    'All',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    loadSampleData();
  }

  // Get filtered orders
  List<Map<String, dynamic>> get filteredOrders {
    if (selectedFilter.value == 'All') {
      return orders;
    }
    return orders
        .where((order) => order['status'] == selectedFilter.value)
        .toList();
  }

  // Get order count by status
  int getOrderCountByStatus(String status) {
    if (status == 'All') return orders.length;
    return orders.where((order) => order['status'] == status).length;
  }

  // Change filter
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  // View order details
  void viewOrderDetails(Map<String, dynamic> order) {
    Get.snackbar(
      'Order Details',
      'Opening order #${order['orderId']}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Navigate to order details screen
    // Get.toNamed('/order-details', arguments: order);
  }

  // Track order
  void trackOrder(String orderId) {
    Get.snackbar(
      'Track Order',
      'Opening tracking for order #$orderId',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Navigate to tracking screen
    // Get.toNamed('/track-order', arguments: orderId);
  }

  // Cancel order
  void cancelOrder(String orderId) {
    final order = orders.firstWhere((o) => o['orderId'] == orderId);

    if (order['status'] == 'Delivered' || order['status'] == 'Cancelled') {
      Get.snackbar(
        'Cannot Cancel',
        'This order cannot be cancelled',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order #$orderId?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No')),
          TextButton(
            onPressed: () {
              final index = orders.indexWhere((o) => o['orderId'] == orderId);
              if (index != -1) {
                orders[index]['status'] = 'Cancelled';
                orders.refresh();
              }
              Get.back();
              Get.snackbar(
                'Order Cancelled',
                'Order #$orderId has been cancelled',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Reorder
  void reorder(String orderId) {
    final order = orders.firstWhere((o) => o['orderId'] == orderId);

    Get.snackbar(
      'Reorder',
      'Adding items from order #$orderId to cart',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Add order items to cart
  }

  // Download invoice
  void downloadInvoice(String orderId) {
    Get.snackbar(
      'Download Invoice',
      'Downloading invoice for order #$orderId',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Download invoice PDF
  }

  // Get order status color
  String getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return '0xFFFF9800'; // Orange
      case 'Shipped':
        return '0xFF2196F3'; // Blue
      case 'Delivered':
        return '0xFF4CAF50'; // Green
      case 'Cancelled':
        return '0xFFF44336'; // Red
      default:
        return '0xFF9E9E9E'; // Grey
    }
  }

  // Get order status icon
  String getStatusIcon(String status) {
    switch (status) {
      case 'Processing':
        return 'clock';
      case 'Shipped':
        return 'truck';
      case 'Delivered':
        return 'check_circle';
      case 'Cancelled':
        return 'cancel';
      default:
        return 'info';
    }
  }

  // Calculate order total
  double calculateOrderTotal(List<dynamic> items) {
    return items.fold(0.0, (sum, item) {
      final price =
          double.tryParse(
            item['price'].toString().replaceAll(RegExp(r'[^\d.]'), ''),
          ) ??
          0.0;
      final quantity = item['quantity'] as int;
      return sum + (price * quantity);
    });
  }

  // Load sample data
  void loadSampleData() {
    if (orders.isEmpty) {
      orders.addAll([
        {
          'orderId': 'ORD-2024-001',
          'date': '15 Nov, 2024',
          'status': 'Processing',
          'total': '\$349.98',
          'items': [
            {
              'name': 'Nike Air Jordan Shoes',
              'price': '\$299.99',
              'quantity': 1,
              'image': '',
            },
            {
              'name': 'Blue Cotton T-Shirt',
              'price': '\$49.99',
              'quantity': 1,
              'image': '',
            },
          ],
          'shippingAddress': {
            'name': 'Taimoor Sikander',
            'street': '123 Main Street',
            'city': 'Islamabad',
            'country': 'Pakistan',
          },
          'paymentMethod': 'Credit Card',
          'trackingNumber': 'TRK123456789',
        },
        {
          'orderId': 'ORD-2024-002',
          'date': '10 Nov, 2024',
          'status': 'Shipped',
          'total': '\$189.99',
          'items': [
            {
              'name': 'Adidas Running Sneakers',
              'price': '\$189.99',
              'quantity': 1,
              'image': '',
            },
          ],
          'shippingAddress': {
            'name': 'Taimoor Sikander',
            'street': '123 Main Street',
            'city': 'Islamabad',
            'country': 'Pakistan',
          },
          'paymentMethod': 'Cash on Delivery',
          'trackingNumber': 'TRK987654321',
        },
        {
          'orderId': 'ORD-2024-003',
          'date': '5 Nov, 2024',
          'status': 'Delivered',
          'total': '\$399.99',
          'items': [
            {
              'name': 'Smart Watch Series 5',
              'price': '\$399.99',
              'quantity': 1,
              'image': '',
            },
          ],
          'shippingAddress': {
            'name': 'Taimoor Sikander',
            'street': '123 Main Street',
            'city': 'Islamabad',
            'country': 'Pakistan',
          },
          'paymentMethod': 'Credit Card',
          'trackingNumber': 'TRK456789123',
          'deliveredDate': '8 Nov, 2024',
        },
      ]);
    }
  }

  // Firebase methods (commented for now)

  // Future<void> loadOrdersFromFirebase(String userId) async {
  //   try {
  //     isLoading.value = true;
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('orders')
  //         .orderBy('createdAt', descending: true)
  //         .get();
  //
  //     orders.value = snapshot.docs
  //         .map((doc) => {...doc.data(), 'id': doc.id})
  //         .toList();
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to load orders');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<void> updateOrderStatus(String orderId, String status) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('orders')
  //         .doc(orderId)
  //         .update({
  //       'status': status,
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to update order status');
  //   }
  // }
}
