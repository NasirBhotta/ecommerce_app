import 'package:ecommerce_app/data/repositories/auth_repo.dart';
import 'package:ecommerce_app/features/authentication/screens/authscreens/forgot_pass.dart';
import 'package:ecommerce_app/features/authentication/screens/authscreens/signup.dart';
import 'package:ecommerce_app/features/shop/screens/navigation_menu.dart';
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

  // Authentication Repository
  final authRepo = AuthenticationRepository.instance;
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

  // Login with Email & Password
  Future<void> login() async {
    try {
      // Validate form
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Start loading
      isLoading.value = true;

      // Save credentials if remember me is checked
      _saveCredentials();

      // Login user with Firebase Authentication
      await authRepo.loginWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check if email is verified
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

      // Show success message
      Get.snackbar(
        'Success',
        'Welcome back!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to home
      Get.offAll(
        () => const NavigationMenu(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 250),
      );
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

  // Login with Google
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // Sign in with Google
      final userCredential = await authRepo.signInWithGoogle();

      if (userCredential != null) {
        // Check if user data already exists
        final userData = await authRepo.fetchUserRecord();

        if (userData == null) {
          // First time Google sign-in, save user data
          final names = userCredential.user?.displayName?.split(' ') ?? [];
          await authRepo.saveUserRecord(
            userCredential,
            firstName: names.isNotEmpty ? names[0] : '',
            lastName: names.length > 1 ? names[1] : '',
            username: userCredential.user?.email?.split('@')[0] ?? '',
            phone: userCredential.user?.phoneNumber ?? '',
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

      // TODO: Implement Facebook login
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

  // Forgot Password
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
