import 'package:ecommerce_app/features/authentication/screens/authscreens/forgot_pass.dart';
import 'package:ecommerce_app/features/authentication/screens/authscreens/signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observables
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final isLoading = false.obs;

  // Form Key
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle Remember Me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // Toggle Password Visibility
  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
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

  // Sign In
  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      // Navigate to home with smooth transition
      // Get.offAll(
      //   () => const HomeScreen(),
      //   transition: Transition.fadeIn,
      //   duration: const Duration(milliseconds: 250),
      // );

      Get.snackbar(
        'Success',
        'Login successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign In with Google
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Implement Google Sign In
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Success',
        'Google Sign In successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google Sign In failed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign In with Facebook
  Future<void> signInWithFacebook() async {
    try {
      isLoading.value = true;

      // Implement Facebook Sign In
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Success',
        'Facebook Sign In successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Facebook Sign In failed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
