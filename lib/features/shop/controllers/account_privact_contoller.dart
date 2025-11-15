import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountPrivacyController extends GetxController {
  static AccountPrivacyController get instance => Get.find();

  // Privacy settings
  final profileVisibility = 'Public'.obs;
  final showOnlineStatus = true.obs;
  final showPurchaseHistory = false.obs;
  final showWishlist = true.obs;
  final allowDataCollection = true.obs;
  final personalizedAds = true.obs;
  final shareDataWithPartners = false.obs;
  final locationTracking = true.obs;

  // Security settings
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
    loadSampleData();
  }

  // Profile visibility options
  final visibilityOptions = ['Public', 'Friends Only', 'Private'];
  final deleteHistoryOptions = [30, 60, 90, 180, 365];

  // Toggle settings
  void toggleShowOnlineStatus(bool value) {
    showOnlineStatus.value = value;
    _showSettingUpdated('Online Status', value);
  }

  void toggleShowPurchaseHistory(bool value) {
    showPurchaseHistory.value = value;
    _showSettingUpdated('Purchase History', value);
  }

  void toggleShowWishlist(bool value) {
    showWishlist.value = value;
    _showSettingUpdated('Wishlist', value);
  }

  void toggleAllowDataCollection(bool value) {
    allowDataCollection.value = value;
    _showSettingUpdated('Data Collection', value);
  }

  void togglePersonalizedAds(bool value) {
    personalizedAds.value = value;
    _showSettingUpdated('Personalized Ads', value);
  }

  void toggleShareDataWithPartners(bool value) {
    shareDataWithPartners.value = value;
    _showSettingUpdated('Share Data with Partners', value);
  }

  void toggleLocationTracking(bool value) {
    locationTracking.value = value;
    _showSettingUpdated('Location Tracking', value);
  }

  void toggleTwoFactorAuth(bool value) {
    if (value) {
      _showTwoFactorSetupDialog();
    } else {
      _showTwoFactorDisableDialog();
    }
  }

  void toggleBiometricAuth(bool value) {
    biometricAuth.value = value;
    _showSettingUpdated('Biometric Authentication', value);
  }

  void toggleLoginAlerts(bool value) {
    loginAlerts.value = value;
    _showSettingUpdated('Login Alerts', value);
  }

  void toggleAutoDeleteHistory(bool value) {
    autoDeleteHistory.value = value;
    _showSettingUpdated('Auto Delete History', value);
  }

  // Change profile visibility
  void changeProfileVisibility(String visibility) {
    profileVisibility.value = visibility;
    Get.snackbar(
      'Privacy Updated',
      'Profile visibility set to $visibility',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Change auto-delete period
  void changeDeletePeriod(int days) {
    deleteAfterDays.value = days;
    Get.snackbar(
      'Settings Updated',
      'History will be deleted after $days days',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Two-factor auth dialogs
  void _showTwoFactorSetupDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Enable Two-Factor Authentication'),
        content: const Text(
          'Two-factor authentication adds an extra layer of security to your account. You\'ll need to enter a code from your phone in addition to your password.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              twoFactorAuth.value = true;
              Get.back();
              Get.snackbar(
                'Success',
                '2FA enabled successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Enable'),
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
          'Are you sure you want to disable two-factor authentication? This will make your account less secure.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              twoFactorAuth.value = false;
              Get.back();
              Get.snackbar(
                'Disabled',
                '2FA has been disabled',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Disable', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // View activity logs
  void viewActivityLogs() {
    Get.snackbar(
      'Activity Logs',
      'Opening activity logs...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Navigate to activity logs screen
    // Get.toNamed('/activity-logs');
  }

  // Download personal data
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

  // Delete account data
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
          'Are you absolutely sure? Type "DELETE" to confirm.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Account Deleted',
                'Your account data has been scheduled for deletion',
                snackPosition: SnackPosition.BOTTOM,
              );
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

  // Manage connected accounts
  void disconnectAccount(String accountType) {
    Get.dialog(
      AlertDialog(
        title: Text('Disconnect $accountType'),
        content: Text(
          'Are you sure you want to disconnect your $accountType account?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              connectedAccounts.removeWhere(
                (acc) => acc['type'] == accountType,
              );
              Get.back();
              Get.snackbar(
                'Disconnected',
                '$accountType account disconnected',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text(
              'Disconnect',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Clear browsing history
  void clearBrowsingHistory() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Browsing History'),
        content: const Text(
          'Are you sure you want to clear your browsing history?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Cleared',
                'Browsing history cleared',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // Clear search history
  void clearSearchHistory() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Search History'),
        content: const Text(
          'Are you sure you want to clear your search history?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Cleared',
                'Search history cleared',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSettingUpdated(String setting, bool enabled) {
    Get.snackbar(
      'Settings Updated',
      '$setting ${enabled ? "enabled" : "disabled"}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Load sample data
  void loadSampleData() {
    if (connectedAccounts.isEmpty) {
      connectedAccounts.addAll([
        {'type': 'Google', 'email': 'taimoor@gmail.com'},
        {'type': 'Facebook', 'email': 'taimoor@facebook.com'},
      ]);
    }

    if (activityLogs.isEmpty) {
      activityLogs.addAll([
        {
          'action': 'Login',
          'device': 'Chrome on Windows',
          'location': 'Islamabad, Pakistan',
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
        },
        {
          'action': 'Password Changed',
          'device': 'Chrome on Windows',
          'location': 'Islamabad, Pakistan',
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(days: 5))
                  .toIso8601String(),
        },
      ]);
    }
  }

  // Firebase methods (commented for now)

  // Future<void> loadPrivacySettingsFromFirebase(String userId) async {
  //   try {
  //     isLoading.value = true;
  //     final doc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .get();
  //
  //     final settings = doc.data()?['privacySettings'] as Map<String, dynamic>?;
  //     if (settings != null) {
  //       profileVisibility.value = settings['profileVisibility'] ?? 'Public';
  //       showOnlineStatus.value = settings['showOnlineStatus'] ?? true;
  //       // ... load other settings
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to load privacy settings');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<void> updatePrivacySettings(String userId) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .update({
  //       'privacySettings': {
  //         'profileVisibility': profileVisibility.value,
  //         'showOnlineStatus': showOnlineStatus.value,
  //         'showPurchaseHistory': showPurchaseHistory.value,
  //         'showWishlist': showWishlist.value,
  //         'allowDataCollection': allowDataCollection.value,
  //         'personalizedAds': personalizedAds.value,
  //         'shareDataWithPartners': shareDataWithPartners.value,
  //         'locationTracking': locationTracking.value,
  //         'twoFactorAuth': twoFactorAuth.value,
  //         'biometricAuth': biometricAuth.value,
  //         'loginAlerts': loginAlerts.value,
  //       },
  //     });
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to update privacy settings');
  //   }
  // }
}
