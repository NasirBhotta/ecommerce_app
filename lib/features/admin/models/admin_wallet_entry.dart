import 'package:cloud_firestore/cloud_firestore.dart';

class AdminWalletEntry {
  AdminWalletEntry({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.reference,
  });

  final String id;
  final String userId;
  final String type;
  final String status;
  final double amount;
  final String description;
  final DateTime timestamp;
  final DocumentReference<Map<String, dynamic>> reference;

  bool get isWithdrawal =>
      type == 'debit' && description.toLowerCase().contains('withdrawal');

  factory AdminWalletEntry.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final ts = data['timestamp'];
    final userId = doc.reference.parent.parent?.id ?? '';

    return AdminWalletEntry(
      id: doc.id,
      userId: userId,
      type: (data['type'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      amount: ((data['amount'] ?? 0) as num).toDouble(),
      description: (data['description'] ?? '').toString(),
      timestamp:
          ts is Timestamp
              ? ts.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0),
      reference: doc.reference,
    );
  }
}
