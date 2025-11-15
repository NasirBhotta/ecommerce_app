import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/authentication/screens/authscreens/login.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/onboarding.dart';
import 'package:ecommerce_app/features/shop/screens/navigation_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Get authenticated user data
  User? get authUser => _auth.currentUser;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  void onReady() {
    super.onReady();
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  // Function to show relevant screen
  void screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      // User is logged in
      Get.offAll(() => const NavigationMenu());
    } else {
      // User is not logged in
      deviceStorage.writeIfNull("isFirstTime", true);
      deviceStorage.read("isFirstTime") != true
          ? Get.offAll(() => const LoginScreen())
          : Get.offAll(() => const OnboardingScreen());
    }
  }

  /* ----------------------- Email & Password Authentication ----------------------- */

  /// [EmailAuthentication] - SignUp
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      throw e.message ?? 'Firebase error occurred';
    } on FormatException catch (_) {
      throw 'Invalid format. Please check your input.';
    } on PlatformException catch (e) {
      throw e.message ?? 'Platform error occurred';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - Login
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      throw e.message ?? 'Firebase error occurred';
    } on FormatException catch (_) {
      throw 'Invalid format. Please check your input.';
    } on PlatformException catch (e) {
      throw e.message ?? 'Platform error occurred';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailVerification] - Send Email Verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailVerification] - Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  /// [ReAuthentication] - ReAuthenticate User
  Future<void> reAuthenticateWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /* ----------------------- Federated Identity & Social Sign-In ----------------------- */

  /// [GoogleAuthentication] - Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      return userCredential;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  /// [FacebookAuthentication] - Facebook Sign In (requires facebook_auth package)
  // Future<UserCredential?> signInWithFacebook() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();
  //
  //     if (result.status == LoginStatus.success) {
  //       final OAuthCredential credential =
  //           FacebookAuthProvider.credential(result.accessToken!.token);
  //       return await _auth.signInWithCredential(credential);
  //     }
  //     return null;
  //   } on FirebaseAuthException catch (e) {
  //     throw _handleFirebaseAuthException(e);
  //   } catch (e) {
  //     if (kDebugMode) print('Error during Facebook Sign In: $e');
  //     return null;
  //   }
  // }

  /* ----------------------- ./END Federated Identity & Social Sign-In ----------------------- */

  /// [LogoutUser] - Valid for any authentication
  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [DeleteUser] - Remove user Auth and Firestore Account
  Future<void> deleteAccount() async {
    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(_auth.currentUser?.uid).delete();

      // Delete user authentication
      await _auth.currentUser?.delete();

      // Navigate to login
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /* ----------------------- Password Management ----------------------- */

  /// [ForgotPassword] - Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [ChangePassword] - Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user found';

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /* ----------------------- User Management ----------------------- */

  /// Save user record in Firestore
  Future<void> saveUserRecord(
    UserCredential? userCredential, {
    required String firstName,
    required String lastName,
    required String username,
    required String phone,
  }) async {
    try {
      if (userCredential != null) {
        // Save user data to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email ?? '',
          'firstName': firstName,
          'lastName': lastName,
          'fullName': '$firstName $lastName',
          'username': username,
          'phoneNumber': phone,
          'profilePicture': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),

          // Additional fields
          'emailVerified': userCredential.user!.emailVerified,
          'isActive': true,
          'role': 'user',

          // Privacy settings
          'privacySettings': {
            'profileVisibility': 'Public',
            'showOnlineStatus': true,
            'showPurchaseHistory': false,
          },

          // Notification settings
          'notificationSettings': {
            'orderUpdates': true,
            'promotionalOffers': true,
            'pushNotifications': true,
          },
        });
      }
    } on FirebaseException catch (e) {
      throw e.message ?? 'Firebase error occurred';
    } catch (e) {
      throw 'Something went wrong while saving user data.';
    }
  }

  /// Update user data in Firestore
  Future<void> updateUserRecord(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw e.message ?? 'Firebase error occurred';
    } catch (e) {
      throw 'Something went wrong while updating user data.';
    }
  }

  /// Fetch user data from Firestore
  Future<Map<String, dynamic>?> fetchUserRecord() async {
    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } on FirebaseException catch (e) {
      throw e.message ?? 'Firebase error occurred';
    } catch (e) {
      throw 'Something went wrong while fetching user data.';
    }
  }

  /* ----------------------- Error Handling ----------------------- */

  /// Handle Firebase Authentication Exceptions
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
