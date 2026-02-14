import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/models/admin_order_item.dart';
import 'package:ecommerce_app/features/admin/services/admin_audit_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AdminOrdersController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString errorMessage = ''.obs;
  final RxList<AdminOrderItem> orders = <AdminOrderItem>[].obs;

  final List<String> statusFilters = const [
    'All',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      var snapshot = await _db.collectionGroup('orders').get();
      if (snapshot.docs.isEmpty) {
        final topLevelOrders = await _db.collection('orders').get();
        if (topLevelOrders.docs.isNotEmpty) {
          snapshot = topLevelOrders;
        }
      }

      final loaded =
          snapshot.docs.map((doc) => AdminOrderItem.fromDocument(doc)).toList()
            ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

      if (selectedFilter.value == 'All') {
        orders.assignAll(loaded);
      } else {
        orders.assignAll(
          loaded.where((o) => o.status == selectedFilter.value).toList(),
        );
      }
    } catch (e) {
      orders.clear();
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeFilter(String status) async {
    selectedFilter.value = status;
    await loadOrders();
  }

  Future<void> updateStatus(AdminOrderItem order, String status) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await order.reference.update({
      'status': status,
      'updatedBy': adminUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await AdminAuditLogger.log(
      action: 'order_status_updated',
      resourceType: 'order',
      resourceId: order.id,
      details: {'status': status, 'userId': order.userId},
    );
    await loadOrders();
  }
}
