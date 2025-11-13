import 'package:ecommerce_app/features/authentication/controllers/auth/forgot_pass_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/login_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/reset_pass_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/signup_controller.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/onboarding.dart';
import 'package:ecommerce_app/util/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const EcommrceApp());
}

// ============================================
// APP BINDINGS - Pre-register Controllers
// ============================================
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization - controllers created only when needed
    // This prevents slow navigation by having controllers ready
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<SignUpController>(() => SignUpController(), fenix: true);
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(),
      fenix: true,
    );
    Get.lazyPut<ResetPasswordController>(
      () => ResetPasswordController(),
      fenix: true,
    );
  }
}

class EcommrceApp extends StatelessWidget {
  const EcommrceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'E-Commerce App',
      themeMode: ThemeMode.system,
      theme: BAppTheme.lightTheme,
      darkTheme: BAppTheme.darkTheme,

      // Register bindings globally
      initialBinding: AppBindings(),

      // Set default transition for smoother navigation
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
