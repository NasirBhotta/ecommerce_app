import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/admin/models/admin_wallet_entry.dart';
import 'package:get/get.dart';

class AdminWalletController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString statusFilter = 'All'.obs;
  final RxString typeFilter = 'All'.obs;
  final RxString errorMessage = ''.obs;
  final RxList<AdminWalletEntry> entries = <AdminWalletEntry>[].obs;

  final List<String> statuses = const ['All', 'pending', 'completed', 'failed'];
  final List<String> types = const ['All', 'credit', 'debit'];

  @override
  void onInit() {
    super.onInit();
    loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final snapshot = await _db.collectionGroup('wallet_ledger').get();
      var rows =
          snapshot.docs.map((e) => AdminWalletEntry.fromDocument(e)).toList();

      if (statusFilter.value != 'All') {
        rows = rows.where((e) => e.status == statusFilter.value).toList();
      }

      if (typeFilter.value != 'All') {
        rows = rows.where((e) => e.type == typeFilter.value).toList();
      }

      rows.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      entries.assignAll(rows);
    } catch (e) {
      entries.clear();
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setStatusFilter(String value) async {
    statusFilter.value = value;
    await loadEntries();
  }

  Future<void> setTypeFilter(String value) async {
    typeFilter.value = value;
    await loadEntries();
  }
}
