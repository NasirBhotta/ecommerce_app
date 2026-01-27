import 'package:cloud_firestore/cloud_firestore.dart';

class BankAccountModel {
  String id;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String routingNumber;
  final bool isPrimary;
  final DateTime? createdAt;

  BankAccountModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.routingNumber,
    this.isPrimary = false,
    this.createdAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber':
          accountNumber.length > 4
              ? accountNumber.substring(accountNumber.length - 4)
              : accountNumber, // Store only last 4 digits
      'accountHolderName': accountHolderName,
      'routingNumber': routingNumber,
      'isPrimary': isPrimary,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore DocumentSnapshot
  factory BankAccountModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BankAccountModel(
      id: snapshot.id,
      bankName: data['bankName'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      accountHolderName: data['accountHolderName'] ?? '',
      routingNumber: data['routingNumber'] ?? '',
      isPrimary: data['isPrimary'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Create from Map
  factory BankAccountModel.fromMap(Map<String, dynamic> data) {
    return BankAccountModel(
      id: data['id'] ?? '',
      bankName: data['bankName'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      accountHolderName: data['accountHolderName'] ?? '',
      routingNumber: data['routingNumber'] ?? '',
      isPrimary: data['isPrimary'] ?? false,
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
    );
  }

  // Empty model
  static BankAccountModel empty() {
    return BankAccountModel(
      id: '',
      bankName: '',
      accountNumber: '',
      accountHolderName: '',
      routingNumber: '',
      isPrimary: false,
    );
  }

  // Copy with
  BankAccountModel copyWith({
    String? id,
    String? bankName,
    String? accountNumber,
    String? accountHolderName,
    String? routingNumber,
    bool? isPrimary,
    DateTime? createdAt,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      routingNumber: routingNumber ?? this.routingNumber,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
