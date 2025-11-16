import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/data/repositories/auth_repo.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

/// UserRepository
/// ONLY handles Firestore user data operations
/// Does NOT handle authentication - use AuthRepository for that
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _authRepo = AuthenticationRepository.instance;

  // Get current user ID
  String get userId => _authRepo.authUser?.uid ?? '';

  /* ----------------------- Create User ----------------------- */

  /// Save user record to Firestore (called after sign up)
  Future<void> saveUserRecord({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String username,
    required String phoneNumber,
    String? profilePicture,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'fullName': '$firstName $lastName',
        'username': username,
        'phoneNumber': phoneNumber,
        'profilePicture': profilePicture ?? '',
        'dateOfBirth': '',
        'gender': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
        'isActive': true,
        'role': 'user',

        // Default Settings
        'privacySettings': {
          'profileVisibility': 'Public',
          'showOnlineStatus': true,
          'showPurchaseHistory': false,
          'allowDataCollection': true,
        },

        'notificationSettings': {
          'orderUpdates': true,
          'promotionalOffers': true,
          'newArrivals': false,
          'pushNotifications': true,
        },
      });
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to save user data';
    } catch (e) {
      throw 'Something went wrong while saving user data.';
    }
  }

  /* ----------------------- Read User ----------------------- */

  /// Fetch user details from Firestore
  Future<Map<String, dynamic>> fetchUserDetails() async {
    try {
      final doc = await _db.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      } else {
        throw 'User data not found';
      }
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to fetch user data';
    } catch (e) {
      throw 'Something went wrong while fetching user data.';
    }
  }

  /// Stream user details (real-time updates)
  Stream<Map<String, dynamic>> streamUserDetails() {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
      return {};
    });
  }

  /* ----------------------- Update User ----------------------- */

  /// Update single field
  Future<void> updateSingleField(String field, dynamic value) async {
    try {
      await _db.collection('users').doc(userId).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to update $field';
    } catch (e) {
      throw 'Something went wrong while updating $field.';
    }
  }

  /// Update multiple fields
  Future<void> updateUserRecord(Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to update user data';
    } catch (e) {
      throw 'Something went wrong while updating user data.';
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;

      if (firstName != null || lastName != null) {
        final first = firstName ?? '';
        final last = lastName ?? '';
        updates['fullName'] = '$first $last'.trim();
      }

      if (username != null) updates['username'] = username;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (dateOfBirth != null) updates['dateOfBirth'] = dateOfBirth;
      if (gender != null) updates['gender'] = gender;

      if (updates.isNotEmpty) {
        await updateUserRecord(updates);
      }
    } catch (e) {
      throw 'Failed to update profile: ${e.toString()}';
    }
  }

  /* ----------------------- Profile Picture ----------------------- */

  /// Upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(File image) async {
    try {
      // Create reference
      final ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('profile.jpg');

      // Upload image
      final uploadTask = await ref.putFile(image);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update Firestore
      await updateSingleField('profilePicture', downloadUrl);

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to upload profile picture';
    } catch (e) {
      throw 'Something went wrong while uploading profile picture.';
    }
  }

  /// Remove profile picture
  Future<void> removeProfilePicture() async {
    try {
      // Delete from Storage
      final ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('profile.jpg');

      await ref.delete();

      // Update Firestore
      await updateSingleField('profilePicture', '');
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }

  /* ----------------------- Settings ----------------------- */

  /// Update privacy settings
  Future<void> updatePrivacySettings(Map<String, dynamic> settings) async {
    try {
      await updateSingleField('privacySettings', settings);
    } catch (e) {
      throw 'Failed to update privacy settings: ${e.toString()}';
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      await updateSingleField('notificationSettings', settings);
    } catch (e) {
      throw 'Failed to update notification settings: ${e.toString()}';
    }
  }

  /* ----------------------- User Validation ----------------------- */

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final query =
          await _db
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      return query.docs.isEmpty;
    } catch (e) {
      throw 'Failed to check username availability';
    }
  }

  /* ----------------------- Delete User Data ----------------------- */

  /// Delete all user data from Firestore
  /// Note: This does NOT delete authentication - use AuthRepository for that
  Future<void> deleteUserData() async {
    try {
      // Delete profile picture
      try {
        await removeProfilePicture();
      } catch (e) {
        // Ignore if doesn't exist
      }

      // Delete subcollections
      await _deleteSubcollection('cart');
      await _deleteSubcollection('addresses');
      await _deleteSubcollection('orders');
      await _deleteSubcollection('wishlist');
      await _deleteSubcollection('bankAccounts');
      await _deleteSubcollection('notifications');

      // Delete user document
      await _db.collection('users').doc(userId).delete();
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to delete user data';
    } catch (e) {
      throw 'Something went wrong while deleting user data.';
    }
  }

  /// Helper: Delete subcollection
  Future<void> _deleteSubcollection(String subcollection) async {
    try {
      final snapshot =
          await _db
              .collection('users')
              .doc(userId)
              .collection(subcollection)
              .get();

      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      // Ignore if subcollection doesn't exist
    }
  }
}
