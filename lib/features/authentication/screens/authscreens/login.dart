import 'package:ecommerce_app/features/authentication/controllers/auth/login_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                Image.asset(
                  'assets/logos/b-logo.png',
                  height: BSizes.imageThumb,
                  fit: BoxFit.cover,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? BColors.white
                          : BColors.primary,
                ),
                const SizedBox(height: BSizes.spaceBetweenSections),

                // Welcome Text
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover Limitless Choices and Unmatched\nConvenience.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        isDark
                            ? BColors.white.withOpacity(0.6)
                            : BColors.black.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Email Field
                TextFormField(
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    labelText: 'E-Mail',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: BSizes.spaceBetweenInputFields),

                // Password Field
                Obx(
                  () => TextFormField(
                    controller: controller.passwordController,
                    validator: controller.validatePassword,
                    obscureText: controller.hidePassword.value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.hidePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenItems),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Row(
                        children: [
                          Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: (value) => controller.toggleRememberMe(),
                          ),
                          Text(
                            'Remember Me',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: controller.forgotPassword,
                      child: Text(
                        'Forget Password?',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: BColors.primary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: BSizes.spaceBetweenItems),

                // Sign In Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : controller.signIn,
                      child:
                          controller.isLoading.value
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    BColors.white,
                                  ),
                                ),
                              )
                              : const Text('Sign In'),
                    ),
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenItems),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: controller.navigateToSignUp,
                    child: const Text('Create Account'),
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Divider with Text
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color:
                            isDark
                                ? BColors.white.withOpacity(0.2)
                                : BColors.black.withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or Sign In with',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              isDark
                                  ? BColors.white.withOpacity(0.6)
                                  : BColors.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color:
                            isDark
                                ? BColors.white.withOpacity(0.2)
                                : BColors.black.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Button
                    InkWell(
                      onTap: controller.signInWithGoogle,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isDark
                                    ? BColors.white.withOpacity(0.2)
                                    : BColors.black.withOpacity(0.2),
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/logos/google.png', // Add your Google logo
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.g_mobiledata, size: 32);
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Facebook Button
                    InkWell(
                      onTap: controller.signInWithFacebook,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isDark
                                    ? BColors.white.withOpacity(0.2)
                                    : BColors.black.withOpacity(0.2),
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/logos/facebook.png', // Add your Facebook logo
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.facebook, size: 32);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
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
