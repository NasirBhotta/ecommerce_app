import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  String id;
  String code;
  String type; // 'percentage' or 'fixed'
  double value;
  DateTime? expiryDate;
  bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.expiryDate,
    this.isActive = true,
  });

  static CouponModel empty() =>
      CouponModel(id: '', code: '', type: '', value: 0);

  Map<String, dynamic> toJson() {
    return {
      'Code': code,
      'Type': type,
      'Value': value,
      'ExpiryDate': expiryDate,
      'IsActive': isActive,
    };
  }

  factory CouponModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return CouponModel(
      id: snapshot.id,
      code: data['Code'] ?? '',
      type: data['Type'] ?? 'fixed',
      value: (data['Value'] ?? 0.0).toDouble(),
      expiryDate:
          data['ExpiryDate'] != null
              ? (data['ExpiryDate'] as Timestamp).toDate()
              : null,
      isActive: data['IsActive'] ?? true,
    );
  }
}
