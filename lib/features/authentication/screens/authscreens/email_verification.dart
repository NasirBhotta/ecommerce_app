import 'dart:async';
import 'package:ecommerce_app/data/repositories/auth_repo.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  final authRepo = AuthenticationRepository.instance;
  final isResending = false.obs;
  final canResend = true.obs;
  final countdown = 60.obs;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Start checking for email verification
  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final isVerified = await authRepo.isEmailVerified();
      if (isVerified) {
        timer.cancel();
        Get.snackbar(
          'Success',
          'Email verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        authRepo.screenRedirect();
      }
    });
  }

  // Resend verification email
  Future<void> _resendVerificationEmail() async {
    if (!canResend.value) return;

    try {
      isResending.value = true;
      await authRepo.sendEmailVerification();

      Get.snackbar(
        'Email Sent',
        'Verification email has been sent to ${widget.email}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Start countdown
      canResend.value = false;
      countdown.value = 60;

      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (countdown.value > 0) {
          countdown.value--;
        } else {
          canResend.value = true;
          timer.cancel();
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isResending.value = false;
    }
  }

  // Manual check
  Future<void> _checkVerificationStatus() async {
    try {
      final isVerified = await authRepo.isEmailVerified();
      if (isVerified) {
        Get.snackbar(
          'Success',
          'Email verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        authRepo.screenRedirect();
      } else {
        Get.snackbar(
          'Not Verified',
          'Please verify your email first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => authRepo.logout(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BSizes.paddingLg),
          child: Column(
            children: [
              const SizedBox(height: BSizes.spaceBetweenSections),

              // Email Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: BColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.sms,
                  size: 60,
                  color: BColors.primary,
                ),
              ),

              const SizedBox(height: BSizes.spaceBetweenSections),

              // Title
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: BSizes.spaceBetweenItems),

              // Subtitle
              Text(
                widget.email,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: BColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: BSizes.spaceBetweenItems),

              Text(
                'We\'ve sent a verification email to the address above. Please click the link in the email to verify your account.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? BColors.white.withOpacity(0.7) : BColors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: BSizes.spaceBetweenSections * 2),

              // Check Status Button
              ElevatedButton.icon(
                onPressed: _checkVerificationStatus,
                icon: const Icon(Iconsax.tick_circle),
                label: const Text('I\'ve Verified'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: BSizes.spaceBetweenItems),

              // Resend Email Button
              Obx(
                () => OutlinedButton.icon(
                  onPressed:
                      canResend.value && !isResending.value
                          ? _resendVerificationEmail
                          : null,
                  icon:
                      isResending.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Iconsax.send_1),
                  label: Text(
                    canResend.value
                        ? 'Resend Email'
                        : 'Resend in ${countdown.value}s',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),

              const SizedBox(height: BSizes.spaceBetweenSections),

              // Tips
              Container(
                padding: const EdgeInsets.all(BSizes.paddingMd),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? BColors.grey.withOpacity(0.1)
                          : BColors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(BSizes.borderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          color: BColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Check your spam or junk folder\n'
                      '• Make sure you entered the correct email\n'
                      '• The link expires in 24 hours\n'
                      '• You can resend the email after 60 seconds',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
