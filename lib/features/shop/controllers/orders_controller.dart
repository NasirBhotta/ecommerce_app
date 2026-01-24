import 'package:ecommerce_app/data/repositories/order_repo.dart';
import 'package:ecommerce_app/features/shop/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  static OrdersController get instance => Get.find();

  /// Variables
  final orderRepository = Get.find<OrderRepository>();
  final filterOptions = [
    'All',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];
  final selectedFilter = 'All'.obs;
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    fetchUserOrders();
    super.onInit();
  }

  /// Fetch user's orders
  Future<void> fetchUserOrders() async {
    try {
      final orders = await orderRepository.fetchUserOrders();
      allOrders.assignAll(orders);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  /// Filter orders
  List<OrderModel> get filteredOrders {
    if (selectedFilter.value == 'All') {
      return allOrders;
    }
    return allOrders
        .where((order) => order.status == selectedFilter.value)
        .toList();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  int getOrderCountByStatus(String status) {
    if (status == 'All') return allOrders.length;
    return allOrders.where((order) => order.status == status).length;
  }

  /// Get Status Color
  Color getStatusColor(String status) {
    if (status == 'Processing') return Colors.blue;
    if (status == 'Shipped') return Colors.orange;
    if (status == 'Delivered') return Colors.green;
    if (status == 'Cancelled') return Colors.red;
    return Colors.grey;
  }

  void viewOrderDetails(OrderModel order) {
    Get.snackbar('Order Details', 'Viewing details for order ${order.id}');
  }

  void trackOrder(String orderId) {
    Get.snackbar('Track Order', 'Tracking order $orderId');
  }

  void cancelOrder(String orderId) {
    Get.snackbar('Cancel Order', 'Cancelling order $orderId');
  }
}
