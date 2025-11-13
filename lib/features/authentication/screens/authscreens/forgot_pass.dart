import 'package:ecommerce_app/common/widgets/auth_header.dart';
import 'package:ecommerce_app/common/widgets/email_input.dart';
import 'package:ecommerce_app/common/widgets/full_width_elevated_button.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/forgot_pass_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

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
                  title: 'Forgot Password',
                  subtitle:
                      'Don\'t worry! It happens. Please enter the\nemail address associated with your account.',
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Email Field
                BEmailField(
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                ),

                const SizedBox(height: BSizes.spaceBetweenSections),

                // Submit Button
                Obx(
                  () => BFullWidthButton(
                    onPressed: controller.submit,
                    text: 'Submit',
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
