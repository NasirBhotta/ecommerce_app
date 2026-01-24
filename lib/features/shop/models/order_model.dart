import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderModel {
  final String id;
  final String userId;
  final String status; // Processing, Shipped, Delivered, Cancelled
  final double totalAmount;
  final DateTime orderDate;
  final String paymentMethod;
  final Map<String, dynamic>? address;
  final DateTime? deliveryDate;
  final List<Map<String, dynamic>> items;

  OrderModel({
    required this.id,
    this.userId = '',
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    this.paymentMethod = 'Paypal',
    this.address,
    this.deliveryDate,
    this.items = const [],
  });

  String get formattedOrderDate => DateFormat('dd MMM yyyy').format(orderDate);

  String get formattedTotalAmount => '\$${totalAmount.toStringAsFixed(2)}';

  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OrderModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'Processing',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      paymentMethod: data['paymentMethod'] ?? 'Paypal',
      address:
          data['address'] is Map
              ? data['address'] as Map<String, dynamic>
              : null,
      deliveryDate:
          data['deliveryDate'] != null
              ? (data['deliveryDate'] as Timestamp).toDate()
              : null,
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'status': status,
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'paymentMethod': paymentMethod,
      'address': address,
      'deliveryDate': deliveryDate,
      'items': items,
    };
  }
}
