import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressesController extends GetxController {
  static AddressesController get instance => Get.find();

  // Observable addresses list
  final RxList<Map<String, dynamic>> addresses = <Map<String, dynamic>>[].obs;

  // Selected address
  final selectedAddressId = ''.obs;

  // Loading state
  final isLoading = false.obs;

  // Text controllers for add/edit form
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipController = TextEditingController();
  final countryController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSampleData();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    countryController.dispose();
    super.onClose();
  }

  // Get selected address
  Map<String, dynamic>? get selectedAddress {
    if (selectedAddressId.value.isEmpty) return null;
    try {
      return addresses.firstWhere(
        (addr) => addr['id'] == selectedAddressId.value,
      );
    } catch (e) {
      return null;
    }
  }

  // Select address
  void selectAddress(String addressId) {
    selectedAddressId.value = addressId;
    Get.snackbar(
      'Address Selected',
      'This address will be used for delivery',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Show add address dialog
  void showAddAddressDialog() {
    _clearControllers();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Address'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Full Name', Icons.person),
              const SizedBox(height: 12),
              _buildTextField(phoneController, 'Phone Number', Icons.phone),
              const SizedBox(height: 12),
              _buildTextField(streetController, 'Street Address', Icons.home),
              const SizedBox(height: 12),
              _buildTextField(cityController, 'City', Icons.location_city),
              const SizedBox(height: 12),
              _buildTextField(stateController, 'State/Province', Icons.map),
              const SizedBox(height: 12),
              _buildTextField(
                zipController,
                'ZIP/Postal Code',
                Icons.markunread_mailbox,
              ),
              const SizedBox(height: 12),
              _buildTextField(countryController, 'Country', Icons.flag),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_validateAddress()) {
                addAddress();
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show edit address dialog
  void showEditAddressDialog(Map<String, dynamic> address) {
    nameController.text = address['name'];
    phoneController.text = address['phone'];
    streetController.text = address['street'];
    cityController.text = address['city'];
    stateController.text = address['state'];
    zipController.text = address['zip'];
    countryController.text = address['country'];

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Address'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Full Name', Icons.person),
              const SizedBox(height: 12),
              _buildTextField(phoneController, 'Phone Number', Icons.phone),
              const SizedBox(height: 12),
              _buildTextField(streetController, 'Street Address', Icons.home),
              const SizedBox(height: 12),
              _buildTextField(cityController, 'City', Icons.location_city),
              const SizedBox(height: 12),
              _buildTextField(stateController, 'State/Province', Icons.map),
              const SizedBox(height: 12),
              _buildTextField(
                zipController,
                'ZIP/Postal Code',
                Icons.markunread_mailbox,
              ),
              const SizedBox(height: 12),
              _buildTextField(countryController, 'Country', Icons.flag),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_validateAddress()) {
                updateAddress(address['id']);
                Get.back();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Add address
  void addAddress() {
    final newAddress = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'street': streetController.text.trim(),
      'city': cityController.text.trim(),
      'state': stateController.text.trim(),
      'zip': zipController.text.trim(),
      'country': countryController.text.trim(),
      'isDefault': addresses.isEmpty,
      'createdAt': DateTime.now().toIso8601String(),
    };

    addresses.add(newAddress);

    if (addresses.length == 1) {
      selectedAddressId.value = newAddress['id'] as String;
    }

    Get.snackbar(
      'Success',
      'Address added successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Update address
  void updateAddress(String addressId) {
    final index = addresses.indexWhere((addr) => addr['id'] == addressId);
    if (index != -1) {
      addresses[index] = {
        ...addresses[index],
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'street': streetController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'zip': zipController.text.trim(),
        'country': countryController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      Get.snackbar(
        'Success',
        'Address updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Delete address
  void deleteAddress(String addressId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              addresses.removeWhere((addr) => addr['id'] == addressId);
              if (selectedAddressId.value == addressId) {
                selectedAddressId.value =
                    addresses.isNotEmpty ? addresses[0]['id'] : '';
              }
              Get.back();
              Get.snackbar(
                'Deleted',
                'Address deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Set as default address
  void setAsDefault(String addressId) {
    for (var addr in addresses) {
      addr['isDefault'] = addr['id'] == addressId;
    }
    addresses.refresh();
    selectedAddressId.value = addressId;

    Get.snackbar(
      'Success',
      'Default address updated',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Validate address
  bool _validateAddress() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter name');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter phone number');
      return false;
    }
    if (streetController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter street address');
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter city');
      return false;
    }
    return true;
  }

  // Clear controllers
  void _clearControllers() {
    nameController.clear();
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    zipController.clear();
    countryController.clear();
  }

  // Build text field
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  // Load sample data
  void loadSampleData() {
    if (addresses.isEmpty) {
      addresses.addAll([
        {
          'id': '1',
          'name': 'Taimoor Sikander',
          'phone': '+92-300-1234567',
          'street': '123 Main Street, Apartment 4B',
          'city': 'Islamabad',
          'state': 'Federal Capital',
          'zip': '44000',
          'country': 'Pakistan',
          'isDefault': true,
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'name': 'Taimoor Sikander',
          'phone': '+92-300-1234567',
          'street': '456 Park Avenue',
          'city': 'Karachi',
          'state': 'Sindh',
          'zip': '75500',
          'country': 'Pakistan',
          'isDefault': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
      ]);
      selectedAddressId.value = '1';
    }
  }

  // Firebase methods (commented for now)

  // Future<void> loadAddressesFromFirebase(String userId) async {
  //   try {
  //     isLoading.value = true;
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('addresses')
  //         .get();
  //
  //     addresses.value = snapshot.docs
  //         .map((doc) => {...doc.data(), 'id': doc.id})
  //         .toList();
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to load addresses');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<void> saveAddressToFirebase(String userId, Map<String, dynamic> address) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('addresses')
  //         .doc(address['id'])
  //         .set(address);
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to save address');
  //   }
  // }
}
