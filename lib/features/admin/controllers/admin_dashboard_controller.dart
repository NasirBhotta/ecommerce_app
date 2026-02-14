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
  final RxDouble averageOrderValue = 0.0.obs;
  final RxString errorMessage = ''.obs;
  final RxList<AdminOrderItem> recentOrders = <AdminOrderItem>[].obs;
  final RxMap<String, int> orderStatusCounts = <String, int>{}.obs;
  final RxMap<String, int> paymentMethodCounts = <String, int>{}.obs;
  final RxList<double> revenueLast7Days = <double>[].obs;
  final RxList<String> revenueLast7DaysLabels = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';
    recentOrders.clear();
    orderStatusCounts.clear();
    paymentMethodCounts.clear();
    revenueLast7Days.clear();
    revenueLast7DaysLabels.clear();

    try {
      final usersAgg = await _db.collection('users').count().get();
      totalUsers.value = usersAgg.count ?? 0;
    } catch (e) {
      totalUsers.value = 0;
      errorMessage.value = 'Users metric failed: $e';
    }

    try {
      var ordersSnapshot = await _db.collectionGroup('orders').get();

      if (ordersSnapshot.docs.isEmpty) {
        final topLevelOrders = await _db.collection('orders').get();
        if (topLevelOrders.docs.isNotEmpty) {
          _processOrders(topLevelOrders.docs);
          return;
        }
      }

      _processOrders(ordersSnapshot.docs);
    } catch (e) {
      totalOrders.value = 0;
      pendingOrders.value = 0;
      totalRevenue.value = 0;
      averageOrderValue.value = 0;
      recentOrders.clear();
      orderStatusCounts.clear();
      paymentMethodCounts.clear();
      revenueLast7Days.clear();
      revenueLast7DaysLabels.clear();
      if (errorMessage.value.isEmpty) {
        errorMessage.value = 'Orders metric failed: $e';
      } else {
        errorMessage.value = '${errorMessage.value}\nOrders metric failed: $e';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _processOrders(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    totalOrders.value = docs.length;

    var revenue = 0.0;
    var pending = 0;
    final rows = <AdminOrderItem>[];
    final statusCounts = <String, int>{};
    final paymentCounts = <String, int>{};
    final dailyRevenue = <DateTime, double>{};

    for (final doc in docs) {
      final data = doc.data();
      final amount = ((data['totalAmount'] ?? 0) as num).toDouble();
      final status = ((data['status'] ?? '').toString()).trim();
      final paymentMethod = ((data['paymentMethod'] ?? '').toString()).trim();
      final rawDate = data['orderDate'];

      final orderDate =
          rawDate is Timestamp
              ? rawDate.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0);

      revenue += amount;

      final normalizedStatus = status.isEmpty ? 'Unknown' : status;
      statusCounts[normalizedStatus] =
          (statusCounts[normalizedStatus] ?? 0) + 1;

      final normalizedPayment = paymentMethod.isEmpty ? 'Unknown' : paymentMethod;
      paymentCounts[normalizedPayment] =
          (paymentCounts[normalizedPayment] ?? 0) + 1;

      if (normalizedStatus == 'Processing' || normalizedStatus == 'Shipped') {
        pending++;
      }

      if (orderDate.millisecondsSinceEpoch > 0) {
        final day = DateTime(orderDate.year, orderDate.month, orderDate.day);
        dailyRevenue[day] = (dailyRevenue[day] ?? 0) + amount;
      }

      rows.add(
        AdminOrderItem(
          id: doc.id,
          userId: (data['userId'] ?? '').toString(),
          status: normalizedStatus,
          totalAmount: amount,
          paymentMethod: normalizedPayment,
          orderDate: orderDate,
          reference: doc.reference,
        ),
      );
    }

    rows.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    totalRevenue.value = revenue;
    pendingOrders.value = pending;
    averageOrderValue.value =
        totalOrders.value == 0 ? 0 : (revenue / totalOrders.value);
    recentOrders.assignAll(rows.take(8).toList());

    final sortedStatuses = statusCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    orderStatusCounts.assignAll({for (final e in sortedStatuses) e.key: e.value});

    final sortedPayments = paymentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    paymentMethodCounts.assignAll({for (final e in sortedPayments) e.key: e.value});

    _buildRevenueLast7Days(dailyRevenue);
  }

  void _buildRevenueLast7Days(Map<DateTime, double> dailyRevenue) {
    final today = DateTime.now();
    final values = <double>[];
    final labels = <String>[];

    for (var i = 6; i >= 0; i--) {
      final day = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: i));

      labels.add('${day.month}/${day.day}');
      values.add(dailyRevenue[day] ?? 0);
    }

    revenueLast7Days.assignAll(values);
    revenueLast7DaysLabels.assignAll(labels);
  }
}
