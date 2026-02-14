import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/models/admin_order_item.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxInt totalUsers = 0.obs;
  final RxInt totalOrders = 0.obs;
  final RxInt pendingOrders = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxList<AdminOrderItem> recentOrders = <AdminOrderItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;

      final usersAgg = await _db.collection('users').count().get();
      totalUsers.value = usersAgg.count ?? 0;

      final ordersSnapshot = await _db.collectionGroup('orders').get();
      totalOrders.value = ordersSnapshot.docs.length;

      var revenue = 0.0;
      var pending = 0;
      for (final doc in ordersSnapshot.docs) {
        final data = doc.data();
        revenue += ((data['totalAmount'] ?? 0) as num).toDouble();
        final status = (data['status'] ?? '').toString();
        if (status == 'Processing' || status == 'Shipped') {
          pending++;
        }
      }
      totalRevenue.value = revenue;
      pendingOrders.value = pending;

      final recent =
          ordersSnapshot.docs
              .map((doc) => AdminOrderItem.fromDocument(doc))
              .toList()
            ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

      recentOrders.assignAll(recent.take(8).toList());
    } finally {
      isLoading.value = false;
    }
  }
}
