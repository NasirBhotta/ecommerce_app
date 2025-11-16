import 'package:ecommerce_app/data/repositories/auth_repo.dart';
import 'package:ecommerce_app/data/repositories/user_repo.dart';
import 'package:ecommerce_app/features/authentication/screens/authscreens/forgot_pass.dart';
import 'package:ecommerce_app/features/authentication/screens/authscreens/signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observables
  final hidePassword = true.obs;
  final rememberMe = false.obs;
  final isLoading = false.obs;

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Repositories
  final authRepo = AuthenticationRepository.instance;
  final userRepo = UserRepository.instance;
  final localStorage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Load saved credentials if remember me was checked
    _loadSavedCredentials();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Load saved credentials
  void _loadSavedCredentials() {
    final savedEmail = localStorage.read('REMEMBER_ME_EMAIL');
    final savedPassword = localStorage.read('REMEMBER_ME_PASSWORD');

    if (savedEmail != null) {
      emailController.text = savedEmail;
      rememberMe.value = true;
    }

    if (savedPassword != null) {
      passwordController.text = savedPassword;
    }
  }

  // Save credentials
  void _saveCredentials() {
    if (rememberMe.value) {
      localStorage.write('REMEMBER_ME_EMAIL', emailController.text.trim());
      localStorage.write(
        'REMEMBER_ME_PASSWORD',
        passwordController.text.trim(),
      );
    } else {
      localStorage.remove('REMEMBER_ME_EMAIL');
      localStorage.remove('REMEMBER_ME_PASSWORD');
    }
  }

  // Toggle Password Visibility
  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  // Toggle Remember Me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // Validate Email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validate Password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /* =====================================================
     LOGIN WITH EMAIL & PASSWORD
     Uses BOTH AuthRepository AND UserRepository
  ===================================================== */

  Future<void> login() async {
    try {
      // 1. Validate form
      if (!formKey.currentState!.validate()) {
        return;
      }

      // 2. Start loading
      isLoading.value = true;

      // 3. Save credentials if remember me is checked
      _saveCredentials();

      // 4. Login user with Firebase Authentication
      // Uses: AuthRepository
      await authRepo.loginWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 5. Check if email is verified
      // Uses: AuthRepository
      final isVerified = await authRepo.isEmailVerified();

      if (!isVerified) {
        Get.snackbar(
          'Email Not Verified',
          'Please verify your email before logging in',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await authRepo.logout();
        return;
      }

      // 6. Optional: Fetch user data to verify it exists
      // Uses: UserRepository
      try {
        await userRepo.fetchUserDetails();
      } catch (e) {
        // User data doesn't exist in Firestore (shouldn't happen)
        // But we can create it now
        print('Warning: User data not found, creating now...');
        await userRepo.saveUserRecord(
          uid: authRepo.userId,
          email: emailController.text.trim(),
          firstName: '',
          lastName: '',
          username: emailController.text.split('@')[0],
          phoneNumber: '',
        );
      }

      // 7. Show success message
      Get.snackbar(
        'Success',
        'Welcome back!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // 8. Navigate to home
      authRepo.screenRedirect();
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /* =====================================================
     LOGIN WITH GOOGLE
     Uses BOTH AuthRepository AND UserRepository
  ===================================================== */

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // 1. Sign in with Google
      // Uses: AuthRepository
      final userCredential = await authRepo.signInWithGoogle();

      if (userCredential != null) {
        // 2. Check if user data already exists in Firestore
        // Uses: UserRepository
        try {
          await userRepo.fetchUserDetails();
          // User data exists, just navigate
        } catch (e) {
          // User data doesn't exist, create it
          // This is first time Google sign-in
          final names = userCredential.user?.displayName?.split(' ') ?? [];
          final firstName = names.isNotEmpty ? names[0] : '';
          final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

          // Uses: UserRepository
          await userRepo.saveUserRecord(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            firstName: firstName,
            lastName: lastName,
            username: userCredential.user?.email?.split('@')[0] ?? '',
            phoneNumber: userCredential.user?.phoneNumber ?? '',
            profilePicture: userCredential.user?.photoURL,
          );
        }

        Get.snackbar(
          'Success',
          'Welcome back!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate to home
        authRepo.screenRedirect();
      }
    } catch (e) {
      Get.snackbar(
        'Google Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Login with Facebook
  Future<void> loginWithFacebook() async {
    try {
      isLoading.value = true;

      Get.snackbar(
        'Coming Soon',
        'Facebook login will be available soon',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Facebook Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    Get.to(
      () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    );
  }

  // Navigate to Sign Up
  void navigateToSignUp() {
    Get.to(
      () => const SignUpScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    );
  }
}

// Forgot Password
