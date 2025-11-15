import 'package:ecommerce_app/data/repositories/auth_repo.dart';
import 'package:ecommerce_app/features/authentication/screens/authscreens/email_verification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  // Text Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Observables
  final agreeToTerms = false.obs;
  final hidePassword = true.obs;
  final isLoading = false.obs;

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Authentication Repository
  final authRepo = AuthenticationRepository.instance;

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle Terms Agreement
  void toggleTermsAgreement() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  // Toggle Password Visibility
  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  // Validate First Name
  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (value.length < 2) {
      return 'First name must be at least 2 characters';
    }
    return null;
  }

  // Validate Last Name
  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (value.length < 2) {
      return 'Last name must be at least 2 characters';
    }
    return null;
  }

  // Validate Username
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    // Check if username contains only alphanumeric and underscore
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
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

  // Validate Phone
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove any spaces, dashes, or parentheses
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanedValue.length < 10) {
      return 'Enter a valid phone number (at least 10 digits)';
    }
    return null;
  }

  // Validate Password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // Sign Up with Email & Password
  Future<void> signUp() async {
    try {
      // Validate form
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Check terms agreement
      if (!agreeToTerms.value) {
        Get.snackbar(
          'Terms Required',
          'Please agree to the Privacy Policy and Terms of Use',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Start loading
      isLoading.value = true;

      // Register user with Firebase Authentication
      final userCredential = await authRepo.registerWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save user data to Firestore
      await authRepo.saveUserRecord(
        userCredential,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        username: usernameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      // Send email verification
      await authRepo.sendEmailVerification();

      // Show success message
      Get.snackbar(
        'Success',
        'Account created successfully! Please verify your email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate to email verification screen
      Get.off(
        () => EmailVerificationScreen(email: emailController.text.trim()),
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Sign Up Failed',
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

  // Sign Up with Google
  Future<void> signUpWithGoogle() async {
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
          'Google Sign In successful!',
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
        'Google Sign In Failed',
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

  // Sign Up with Facebook
  Future<void> signUpWithFacebook() async {
    try {
      isLoading.value = true;

      Get.snackbar(
        'Coming Soon',
        'Facebook sign-in will be available soon',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // TODO: Implement Facebook sign-in
      // final userCredential = await authRepo.signInWithFacebook();
      // if (userCredential != null) {
      //   // Save user data if first time
      //   authRepo.screenRedirect();
      // }
    } catch (e) {
      Get.snackbar(
        'Facebook Sign In Failed',
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
}
