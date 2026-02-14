import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderItem {
  AdminOrderItem({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderDate,
    required this.reference,
  });

  final String id;
  final String userId;
  final String status;
  final double totalAmount;
  final String paymentMethod;
  final DateTime orderDate;
  final DocumentReference<Map<String, dynamic>> reference;

  factory AdminOrderItem.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final ts = data['orderDate'];

    return AdminOrderItem(
      id: doc.id,
      userId: (data['userId'] ?? '').toString(),
      status: (data['status'] ?? 'Processing').toString(),
      totalAmount: ((data['totalAmount'] ?? 0) as num).toDouble(),
      paymentMethod: (data['paymentMethod'] ?? '').toString(),
      orderDate:
          ts is Timestamp
              ? ts.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0),
      reference: doc.reference,
    );
  }
}
