import 'package:ecommerce_app/features/authentication/controllers/auth/forgot_pass_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/login_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/reset_pass_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/signup_controller.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/onboarding.dart';
import 'package:ecommerce_app/features/shop/controllers/home_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/navigation_controller.dart';
import 'package:ecommerce_app/util/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const EcommrceApp());
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization - controllers created only when needed
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
    Get.lazyPut<NavigationController>(
      () => NavigationController(),
      fenix: true,
    );
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
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
      initialBinding: AppBindings(),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
