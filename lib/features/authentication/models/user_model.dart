import 'package:cloud_firestore/cloud_firestore.dart';

/// User Model
/// Represents a user in the application
class UserModel {
  // Identifiers
  final String uid;
  final String email;

  // Personal Information
  final String firstName;
  final String lastName;
  final String username;
  final String phoneNumber;
  final String profilePicture;
  final String dateOfBirth;
  final String gender;

  // Status
  final bool emailVerified;
  final bool isActive;
  final String role;

  // Settings
  final Map<String, dynamic> privacySettings;
  final Map<String, dynamic> notificationSettings;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Constructor
  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.phoneNumber,
    this.profilePicture = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.emailVerified = false,
    this.isActive = true,
    this.role = 'user',
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? notificationSettings,
    this.createdAt,
    this.updatedAt,
  }) : privacySettings =
           privacySettings ??
           {
             'profileVisibility': 'Public',
             'showOnlineStatus': true,
             'showPurchaseHistory': false,
             'allowDataCollection': true,
           },
       notificationSettings =
           notificationSettings ??
           {
             'orderUpdates': true,
             'promotionalOffers': true,
             'newArrivals': false,
             'pushNotifications': true,
           };

  // Computed property: Full Name
  String get fullName => '$firstName $lastName'.trim();

  // Helper: Empty user
  static UserModel empty() => UserModel(
    uid: '',
    email: '',
    firstName: '',
    lastName: '',
    username: '',
    phoneNumber: '',
  );

  /// Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'username': username,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'emailVerified': emailVerified,
      'isActive': isActive,
      'role': role,
      'privacySettings': privacySettings,
      'notificationSettings': notificationSettings,
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
      'updatedAt':
          updatedAt != null
              ? Timestamp.fromDate(updatedAt!)
              : FieldValue.serverTimestamp(),
    };
  }

  /// Create model from Firestore document
  factory UserModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (!document.exists) {
      return UserModel.empty();
    }

    final data = document.data()!;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      username: data['username'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      gender: data['gender'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      role: data['role'] ?? 'user',
      privacySettings: Map<String, dynamic>.from(data['privacySettings'] ?? {}),
      notificationSettings: Map<String, dynamic>.from(
        data['notificationSettings'] ?? {},
      ),
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  /// Create model from JSON/Map
  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      username: data['username'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      gender: data['gender'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      role: data['role'] ?? 'user',
      privacySettings: Map<String, dynamic>.from(data['privacySettings'] ?? {}),
      notificationSettings: Map<String, dynamic>.from(
        data['notificationSettings'] ?? {},
      ),
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? username,
    String? phoneNumber,
    String? profilePicture,
    String? dateOfBirth,
    String? gender,
    bool? emailVerified,
    bool? isActive,
    String? role,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? notificationSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      emailVerified: emailVerified ?? this.emailVerified,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      privacySettings: privacySettings ?? this.privacySettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $fullName, username: $username)';
  }
}
