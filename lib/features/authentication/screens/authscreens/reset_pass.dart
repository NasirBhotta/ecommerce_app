import 'package:ecommerce_app/common/widgets/auth_header.dart';
import 'package:ecommerce_app/common/widgets/full_width_elevated_button.dart';
import 'package:ecommerce_app/common/widgets/password_input.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/reset_pass_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResetPasswordController());

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
                  title: 'Reset Password',
                  subtitle:
                      'Your new password must be different\nfrom previously used passwords.',
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // New Password Field
                Obx(
                  () => BPasswordField(
                    controller: controller.newPasswordController,
                    validator: controller.validateNewPassword,
                    obscureText: controller.hideNewPassword.value,
                    onToggleVisibility: controller.toggleNewPasswordVisibility,
                    label: 'New Password',
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenInputFields),

                // Confirm Password Field
                Obx(
                  () => BPasswordField(
                    controller: controller.confirmPasswordController,
                    validator: controller.validateConfirmPassword,
                    obscureText: controller.hideConfirmPassword.value,
                    onToggleVisibility:
                        controller.toggleConfirmPasswordVisibility,
                    label: 'Confirm Password',
                  ),
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Reset Password Button
                Obx(
                  () => BFullWidthButton(
                    onPressed: controller.resetPassword,
                    text: 'Reset Password',
                    isLoading: controller.isLoading.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
