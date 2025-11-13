import 'package:ecommerce_app/common/widgets/Divider_with_text.dart';
import 'package:ecommerce_app/common/widgets/auth_header.dart';
import 'package:ecommerce_app/common/widgets/email_input.dart';
import 'package:ecommerce_app/common/widgets/full_width_elevated_button.dart';
import 'package:ecommerce_app/common/widgets/password_input.dart';
import 'package:ecommerce_app/common/widgets/social_login_buttons.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/signup_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BSizes.paddingLg),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const BAuthHeader(
                  title: 'Create Account',
                  subtitle:
                      'Fill your information below or register\nwith your social account.',
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // First Name & Last Name
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.firstNameController,
                        validator: controller.validateFirstName,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          labelText: 'First Name',
                        ),
                      ),
                    ),
                    const SizedBox(width: BSizes.spaceBetweenInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: controller.lastNameController,
                        validator: controller.validateLastName,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          labelText: 'Last Name',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: BSizes.spaceBetweenInputFields),

                // Username
                TextFormField(
                  controller: controller.usernameController,
                  validator: controller.validateUsername,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.account_circle_outlined),
                    labelText: 'Username',
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenInputFields),

                // Email
                BEmailField(
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                ),

                const SizedBox(height: BSizes.spaceBetweenInputFields),

                // Phone Number
                TextFormField(
                  controller: controller.phoneController,
                  validator: controller.validatePhone,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_outlined),
                    labelText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: BSizes.spaceBetweenInputFields),

                // Password
                Obx(
                  () => BPasswordField(
                    controller: controller.passwordController,
                    validator: controller.validatePassword,
                    obscureText: controller.hidePassword.value,
                    onToggleVisibility: controller.togglePasswordVisibility,
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenItems),

                // Terms and Conditions
                Obx(
                  () => Row(
                    children: [
                      Checkbox(
                        value: controller.agreeToTerms.value,
                        onChanged: (value) => controller.toggleTermsAgreement(),
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'I agree to ',
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              TextSpan(
                                text: 'Privacy Policy',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: BColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Terms of Use',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: BColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenItems),

                // Sign Up Button
                Obx(
                  () => BFullWidthButton(
                    onPressed: controller.signUp,
                    text: 'Create Account',
                    isLoading: controller.isLoading.value,
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Divider
                const BDividerWithText(text: 'or Sign Up with'),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Social Login
                BSocialLoginRow(
                  onGoogleTap: controller.signUpWithGoogle,
                  onFacebookTap: controller.signUpWithFacebook,
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
