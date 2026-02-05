import 'package:ecommerce_app/data/repositories/user_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountPrivacyController extends GetxController {
  static AccountPrivacyController get instance => Get.find();

  final _userRepo = UserRepository.instance;

  // Privacy settings
  final profileVisibility = 'Public'.obs;
  final showOnlineStatus = true.obs;
  final showPurchaseHistory = false.obs;
  final showWishlist = true.obs;
  final allowDataCollection = true.obs;
  final personalizedAds = true.obs;
  final shareDataWithPartners = false.obs;
  final locationTracking = true.obs;

  // Security settings (Preferences only)
  final twoFactorAuth = false.obs;
  final biometricAuth = false.obs;
  final loginAlerts = true.obs;

  // Data management
  final autoDeleteHistory = false.obs;
  final deleteAfterDays = 90.obs;

  // Loading state
  final isLoading = false.obs;

  // Connected accounts
  final RxList<Map<String, String>> connectedAccounts =
      <Map<String, String>>[].obs;

  // Activity logs
  final RxList<Map<String, dynamic>> activityLogs =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserPrivacySettings();
    loadSampleData();
  }

  /// Fetch user settings from Firestore and update local state
  Future<void> fetchUserPrivacySettings() async {
    try {
      isLoading.value = true;
      final user = await _userRepo.fetchUserDetails();
      
      // Privacy Settings
      if (user.containsKey('privacySettings')) {
        final settings = user['privacySettings'] as Map<String, dynamic>;
        profileVisibility.value = settings['profileVisibility'] ?? 'Public';
        showOnlineStatus.value = settings['showOnlineStatus'] ?? true;
        showPurchaseHistory.value = settings['showPurchaseHistory'] ?? false;
        allowDataCollection.value = settings['allowDataCollection'] ?? true;
        // Add others if they exist in DB, defaulting to existing defaults
      }

      // Security Settings (Simulated storage in privacySettings for now)
         if (user.containsKey('privacySettings')) {
        final settings = user['privacySettings'] as Map<String, dynamic>;
        twoFactorAuth.value = settings['twoFactorAuth'] ?? false;
        biometricAuth.value = settings['biometricAuth'] ?? false;
      }

    } catch (e) {
      // Silent error or retry logic could go here. 
      // For now, defaults are used if fetch fails.
      debugPrint('Error fetching privacy settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Profile visibility options
  final visibilityOptions = ['Public', 'Friends Only', 'Private'];
  final deleteHistoryOptions = [30, 60, 90, 180, 365];

  // --- Toggle Methods with Persistence ---

  void toggleShowOnlineStatus(bool value) async {
    showOnlineStatus.value = value;
    await _updateSetting('showOnlineStatus', value, 'Online Status');
  }

  void toggleShowPurchaseHistory(bool value) async {
    showPurchaseHistory.value = value;
    await _updateSetting('showPurchaseHistory', value, 'Purchase History');
  }

  void toggleShowWishlist(bool value) async {
    showWishlist.value = value;
    // Assuming this might be added to the UI later or exists in other views
    await _updateSetting('showWishlist', value, 'Wishlist Visibility'); 
  }

  void toggleAllowDataCollection(bool value) async {
    allowDataCollection.value = value;
    await _updateSetting('allowDataCollection', value, 'Data Collection');
  }

  void toggleTwoFactorAuth(bool value) async {
    // Just saving preference, not implementing full 2FA flow
    if (value) {
      _showTwoFactorSetupDialog(); // Dialog handles the toggle/save on confirm
    } else {
      _showTwoFactorDisableDialog();
    }
  }

  void toggleBiometricAuth(bool value) async {
    biometricAuth.value = value;
     await _updateSetting('biometricAuth', value, 'Biometric Auth Preference');
  }

  // Helper to update setting in Firestore
  Future<void> _updateSetting(String key, dynamic value, String friendlyName) async {
    try {
      // Optimistic update happened in caller. Now sync to DB.
      await _userRepo.patchSpecificSetting('privacySettings', key, value);
      
      Get.snackbar(
        'Settings Updated',
        '$friendlyName ${value is bool ? (value ? "enabled" : "disabled") : "updated"}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      // Revert logic could be added here if critical
      Get.snackbar('Error', 'Failed to update $friendlyName', backgroundColor: Colors.red.withOpacity(0.1));
    }
  }


  // --- Dialogs & Actions ---

  void _showTwoFactorSetupDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Enable Two-Factor Authentication'),
        content: const Text(
          'This will mark your account as preferring 2FA. Actual SMS/Email verification flows will be implemented in a future update.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              twoFactorAuth.value = true;
              Get.back();
              await _updateSetting('twoFactorAuth', true, '2FA Preference');
            },
            child: const Text('Enable PREFERENCE'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDisableDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Disable Two-Factor Authentication'),
        content: const Text(
          'Disable 2FA preference?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              twoFactorAuth.value = false;
              Get.back();
               await _updateSetting('twoFactorAuth', false, '2FA Preference');
            },
            child: const Text('Disable', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void downloadPersonalData() {
    Get.dialog(
      AlertDialog(
        title: const Text('Download Personal Data'),
        content: const Text(
          'We\'ll prepare a copy of your data and send it to your registered email within 48 hours.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Request Submitted',
                'You\'ll receive your data via email within 48 hours',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 3),
              );
            },
            child: const Text('Request Data'),
          ),
        ],
      ),
    );
  }

  void deleteAccountData() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account Data'),
        content: const Text(
          'This will permanently delete all your data including orders, addresses, and preferences. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              _showFinalDeleteConfirmation();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Are you absolutely sure? This will effectively delete your user profile from the database.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _userRepo.deleteUserData();
                 Get.snackbar(
                'Account Deleted',
                'Your account data has been deleted.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              // In a real app we would logout here
              // AuthenticationRepository.instance.logout();
              } catch (e) {
                 Get.snackbar('Error', 'Failed to delete account data: $e');
              }
            },
            child: const Text(
              'Confirm Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Old mock data for UI placeholders
  void loadSampleData() {
    if (connectedAccounts.isEmpty) {
      connectedAccounts.addAll([
        {'type': 'Google', 'email': 'user@gmail.com'},
        {'type': 'Facebook', 'email': 'user@facebook.com'},
      ]);
    }
  }
}
