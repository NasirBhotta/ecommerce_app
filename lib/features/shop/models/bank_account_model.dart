import 'package:cloud_firestore/cloud_firestore.dart';

class BankAccountModel {
  final String id;
  final String userId;
  String bankName;
  String accountNumber;
  String accountHolderName;
  bool isPrimary;

  BankAccountModel({
    this.id = '',
    this.userId = '',
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    this.isPrimary = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'BankName': bankName,
      'AccountNumber': accountNumber,
      'AccountHolderName': accountHolderName,
      'IsPrimary': isPrimary,
    };
  }

  factory BankAccountModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BankAccountModel(
      id: snapshot.id,
      userId: data['UserId'] ?? '',
      bankName: data['BankName'] ?? '',
      accountNumber: data['AccountNumber'] ?? '',
      accountHolderName: data['AccountHolderName'] ?? '',
      isPrimary: data['IsPrimary'] ?? false,
    );
  }
}
