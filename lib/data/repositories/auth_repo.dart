import 'package:ecommerce_app/features/authentication/screens/authscreens/login.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/onboarding.dart';
import 'package:ecommerce_app/features/shop/screens/navigation_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// AuthenticationRepository
/// Handles ONLY Firebase Authentication
/// For user data operations, use UserRepository
class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  // Get authenticated user
  User? get authUser => _auth.currentUser;

  // Get user ID
  String get userId {
    final user = _auth.currentUser;
    if (user == null) throw 'No user logged in';
    return user.uid;
  }

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  void onReady() {
    super.onReady();
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  /// Screen Redirect based on authentication state
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

  /// Register with Email & Password
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

  /// Login with Email & Password
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

  /// Send Email Verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Check if Email is Verified
  Future<bool> isEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Re-Authenticate User
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

  /* ----------------------- Social Authentication ----------------------- */

  /// Google Sign In
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

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  /* ----------------------- Password Management ----------------------- */

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Change Password
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

  /* ----------------------- Logout & Delete ----------------------- */

  /// Logout User
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

  /// Delete User Authentication
  /// WARNING: Call UserRepository.deleteUser() FIRST to delete user data!
  Future<void> deleteUserAuth() async {
    try {
      await _auth.currentUser?.delete();
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
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
