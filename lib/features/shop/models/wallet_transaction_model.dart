import 'package:cloud_firestore/cloud_firestore.dart';

class WalletTransactionModel {
  final String id;
  final double amount;
  final String type; // 'deposit', 'withdrawal', 'purchase'
  final String status; // 'confirmed', 'pending', 'failed'
  final String description;
  final DateTime timestamp;

  WalletTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    required this.timestamp,
  });

  factory WalletTransactionModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return WalletTransactionModel(
      id: snapshot.id,
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: data['type'] ?? 'unknown',
      status: data['status'] ?? 'unknown',
      description: data['description'] ?? '',
      timestamp:
          data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  // Helper to check if this transaction adds to available balance
  bool get isCredit => amount > 0;

  // Helper for display formatting
  String get formattedAmount {
    return '${isCredit ? '+' : ''}\$${amount.abs().toStringAsFixed(2)}';
  }
}
