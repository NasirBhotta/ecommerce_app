import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileEditController extends GetxController {
  static ProfileEditController get instance => Get.find();

  // Text editing controllers
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // User data observables
  final name = 'Nasir Bhutta'.obs;
  final username = 'nasir_bhutta'.obs;
  final userId = '45689'.obs;
  final email = 'support@nasirbhutta.com'.obs;
  final phoneNumber = '+92-300-1234567'.obs;
  final gender = 'Male'.obs;
  final dateOfBirth = '10 Oct, 1994'.obs;
  final profileImage = ''.obs;

  // Loading state
  final isLoading = false.obs;

  // Gender options
  final genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers with current values
    nameController.text = name.value;
    usernameController.text = username.value;
    emailController.text = email.value;
    phoneController.text = phoneNumber.value;
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Show edit name dialog
  void showEditNameDialog() {
    nameController.text = name.value;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(Get.context!), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                updateName(nameController.text.trim());
                Navigator.pop(Get.context!);
              } else {
                Get.snackbar(
                  'Error',
                  'Name cannot be empty',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show edit username dialog
  void showEditUsernameDialog() {
    usernameController.text = username.value;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Enter username',
            prefixIcon: Icon(Icons.alternate_email),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(Get.context!), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (usernameController.text.trim().isNotEmpty) {
                updateUsername(usernameController.text.trim());
                Navigator.pop(Get.context!);
              } else {
                Get.snackbar(
                  'Error',
                  'Username cannot be empty',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show edit email dialog
  void showEditEmailDialog() {
    emailController.text = email.value;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter email address',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            const Text(
              'You will receive a verification email',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(Get.context!), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.trim().isNotEmpty &&
                  GetUtils.isEmail(emailController.text.trim())) {
                updateEmail(emailController.text.trim());
                Navigator.pop(Get.context!);
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter a valid email address',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show edit phone dialog
  void showEditPhoneDialog() {
    phoneController.text = phoneNumber.value;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            const Text(
              'You will receive a verification SMS',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(Get.context!), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.trim().isNotEmpty) {
                updatePhoneNumber(phoneController.text.trim());
                Navigator.pop(Get.context!);
              } else {
                Get.snackbar(
                  'Error',
                  'Phone number cannot be empty',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show gender selection dialog
  void showGenderSelectionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              genderOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: gender.value,
                  onChanged: (value) {
                    if (value != null) {
                      updateGender(value);
                      Get.back(canPop: true);
                    }
                  },
                );
              }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(Get.context!), child: const Text('Cancel')),
        ],
      ),
    );
  }

  // Show date of birth picker
  void showDateOfBirthPicker() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime(1994, 10, 10),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
    );

    if (picked != null) {
      updateDateOfBirth(picked);
    }
  }

  // Update methods
  void updateName(String newName) {
    name.value = newName;
    Get.snackbar(
      'Success',
      'Name updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void updateUsername(String newUsername) {
    username.value = newUsername;
    Get.snackbar(
      'Success',
      'Username updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void updateEmail(String newEmail) {
    email.value = newEmail;
    Get.snackbar(
      'Verification Required',
      'Please check your email for verification link',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void updatePhoneNumber(String newPhone) {
    phoneNumber.value = newPhone;
    Get.snackbar(
      'Verification Required',
      'Please check your SMS for verification code',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void updateGender(String newGender) {
    gender.value = newGender;
    Get.snackbar(
      'Success',
      'Gender updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void updateDateOfBirth(DateTime date) {
    final formattedDate =
        '${date.day} ${_getMonthName(date.month)}, ${date.year}';
    dateOfBirth.value = formattedDate;
    Get.snackbar(
      'Success',
      'Date of birth updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Copy user ID to clipboard
  void copyUserId() {
    // In production: Use Clipboard.setData()
    Get.snackbar(
      'Copied',
      'User ID copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Close/Delete account
  void closeAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Close Account'),
        content: const Text(
          'Are you sure you want to close your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(Get.context!), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(Get.context!);
              Get.snackbar(
                'Account Closed',
                'Your account has been scheduled for deletion',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 3),
              );
              // In production: Call API to close account
            },
            child: const Text(
              'Close Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Change profile picture
  void changeProfilePicture() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(Get.context!);
                Get.snackbar(
                  'Camera',
                  'Opening camera...',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(Get.context!);
                Get.snackbar(
                  'Gallery',
                  'Opening gallery...',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            if (profileImage.value.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  profileImage.value = '';
                  Navigator.pop(Get.context!);
                  Get.snackbar(
                    'Success',
                    'Profile picture removed',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
