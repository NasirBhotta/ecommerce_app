import 'package:ecommerce_app/common/widgets/Divider_with_text.dart';
import 'package:ecommerce_app/common/widgets/auth_header.dart';
import 'package:ecommerce_app/common/widgets/checkbox.dart';
import 'package:ecommerce_app/common/widgets/email_input.dart';
import 'package:ecommerce_app/common/widgets/full_width_elevated_button.dart';
import 'package:ecommerce_app/common/widgets/full_width_outlined_button.dart';
import 'package:ecommerce_app/common/widgets/logo.dart';
import 'package:ecommerce_app/common/widgets/password_input.dart';
import 'package:ecommerce_app/common/widgets/social_login_buttons.dart';
import 'package:ecommerce_app/common/widgets/text_link_button.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/login_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BSizes.paddingLg),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: BSizes.spaceBetweenSections),

                // Logo
                const BLogo(),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Header
                const BAuthHeader(
                  title: 'Welcome back,',
                  subtitle:
                      'Discover Limitless Choices and Unmatched\nConvenience.',
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Email Field
                BEmailField(
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                ),

                const SizedBox(height: BSizes.spaceBetweenInputFields),

                // Password Field
                Obx(
                  () => BPasswordField(
                    controller: controller.passwordController,
                    validator: controller.validatePassword,
                    obscureText: controller.hidePassword.value,
                    onToggleVisibility: controller.togglePasswordVisibility,
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenItems),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => BRememberMeCheckbox(
                        value: controller.rememberMe.value,
                        onChanged: (value) => controller.toggleRememberMe(),
                      ),
                    ),
                    BTextButtonLink(
                      text: 'Forget Password?',
                      onPressed: controller.forgotPassword,
                    ),
                  ],
                ),

                const SizedBox(height: BSizes.spaceBetweenItems),

                // Sign In Button
                Obx(
                  () => BFullWidthButton(
                    onPressed: controller.signIn,
                    text: 'Sign In',
                    isLoading: controller.isLoading.value,
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenItems),

                // Create Account Button
                BFullWidthOutlinedButton(
                  onPressed: controller.navigateToSignUp,
                  text: 'Create Account',
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Divider
                const BDividerWithText(text: 'or Sign In with'),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Social Login
                BSocialLoginRow(
                  onGoogleTap: controller.signInWithGoogle,
                  onFacebookTap: controller.signInWithFacebook,
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
