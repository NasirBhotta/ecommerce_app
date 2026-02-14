import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminAnalyticsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt totalOrders = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt totalUsers = 0.obs;
  final RxInt repeatUsers = 0.obs;
  final RxMap<String, int> ordersByDay = <String, int>{}.obs;
  final RxMap<String, double> revenueByDay = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userCount = await _db.collection('users').count().get();
      totalUsers.value = userCount.count ?? 0;

      final ordersSnapshot = await _db.collectionGroup('orders').get();
      totalOrders.value = ordersSnapshot.docs.length;

      final perDayCount = <String, int>{};
      final perDayRevenue = <String, double>{};
      final byUser = <String, int>{};

      var revenue = 0.0;
      for (final doc in ordersSnapshot.docs) {
        final data = doc.data();
        final amount = ((data['totalAmount'] ?? 0) as num).toDouble();
        revenue += amount;

        final ts = data['orderDate'];
        final dt =
            ts is Timestamp
                ? ts.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);
        final day =
            '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

        perDayCount[day] = (perDayCount[day] ?? 0) + 1;
        perDayRevenue[day] = (perDayRevenue[day] ?? 0) + amount;

        final userId = (data['userId'] ?? '').toString();
        if (userId.isNotEmpty) {
          byUser[userId] = (byUser[userId] ?? 0) + 1;
        }
      }

      totalRevenue.value = revenue;
      repeatUsers.value = byUser.values.where((v) => v > 1).length;

      final sortedDays = perDayCount.keys.toList()..sort();
      final trimmed =
          sortedDays.length > 14
              ? sortedDays.sublist(sortedDays.length - 14)
              : sortedDays;

      ordersByDay.assignAll({for (final d in trimmed) d: perDayCount[d] ?? 0});
      revenueByDay.assignAll({
        for (final d in trimmed) d: perDayRevenue[d] ?? 0,
      });
    } catch (e) {
      errorMessage.value = e.toString();
      totalOrders.value = 0;
      totalRevenue.value = 0;
      totalUsers.value = 0;
      repeatUsers.value = 0;
      ordersByDay.clear();
      revenueByDay.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
