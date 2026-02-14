import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AdminExportsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString exportType = 'users'.obs;
  final RxString csvData = ''.obs;
  final RxString errorMessage = ''.obs;

  final List<String> types = const ['users', 'orders', 'wallet_ledger'];

  Future<void> generateCsv() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (exportType.value == 'users') {
        final snapshot = await _db.collection('users').get();
        final rows = <List<String>>[
          ['uid', 'email', 'fullName', 'role', 'isActive'],
        ];
        for (final doc in snapshot.docs) {
          final d = doc.data();
          rows.add([
            doc.id,
            '${d['email'] ?? ''}',
            '${d['fullName'] ?? ''}',
            '${d['role'] ?? ''}',
            '${d['isActive'] ?? ''}',
          ]);
        }
        csvData.value = _rowsToCsv(rows);
      } else if (exportType.value == 'orders') {
        final snapshot = await _db.collectionGroup('orders').get();
        final rows = <List<String>>[
          [
            'orderId',
            'userId',
            'status',
            'totalAmount',
            'paymentMethod',
            'orderDate',
          ],
        ];
        for (final doc in snapshot.docs) {
          final d = doc.data();
          final ts = d['orderDate'];
          final date = ts is Timestamp ? ts.toDate().toIso8601String() : '';
          rows.add([
            doc.id,
            '${d['userId'] ?? ''}',
            '${d['status'] ?? ''}',
            '${d['totalAmount'] ?? ''}',
            '${d['paymentMethod'] ?? ''}',
            date,
          ]);
        }
        csvData.value = _rowsToCsv(rows);
      } else {
        final snapshot = await _db.collectionGroup('wallet_ledger').get();
        final rows = <List<String>>[
          [
            'entryId',
            'userId',
            'type',
            'status',
            'amount',
            'description',
            'timestamp',
          ],
        ];
        for (final doc in snapshot.docs) {
          final d = doc.data();
          final ts = d['timestamp'];
          final date = ts is Timestamp ? ts.toDate().toIso8601String() : '';
          final userId = doc.reference.parent.parent?.id ?? '';
          rows.add([
            doc.id,
            userId,
            '${d['type'] ?? ''}',
            '${d['status'] ?? ''}',
            '${d['amount'] ?? ''}',
            '${d['description'] ?? ''}',
            date,
          ]);
        }
        csvData.value = _rowsToCsv(rows);
      }
    } catch (e) {
      csvData.value = '';
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> copyCsv() async {
    if (csvData.value.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: csvData.value));
  }

  String _rowsToCsv(List<List<String>> rows) {
    return rows.map((row) => row.map(_escapeCsv).join(',')).join('\n');
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    if (escaped.contains(',') ||
        escaped.contains('\n') ||
        escaped.contains('"')) {
      return '"$escaped"';
    }
    return escaped;
  }
}
