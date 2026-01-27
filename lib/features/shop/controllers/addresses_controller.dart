import 'package:ecommerce_app/features/shop/models/address_model.dart';
import 'package:ecommerce_app/data/repositories/address_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  // Text Controllers
  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final street = TextEditingController();
  final postalCode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();

  // Form Key
  GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  // Observable Variables
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxList<AddressModel> allAddresses = <AddressModel>[].obs;
  final Rx<AddressModel> selectedAddress = AddressModel.empty().obs;
  final Rx<String> selectedCountry = ''.obs;

  // Repository
  final addressRepository = Get.put(AddressRepository());

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  @override
  void onClose() {
    // Dispose controllers
    name.dispose();
    phoneNumber.dispose();
    street.dispose();
    postalCode.dispose();
    city.dispose();
    state.dispose();
    country.dispose();
    super.onClose();
  }

  // Fetch all user addresses
  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      final addresses = await addressRepository.fetchUserAddresses();
      allAddresses.assignAll(addresses);

      // Set the selected address
      selectedAddress.value = addresses.firstWhere(
        (element) => element.selectedAddress,
        orElse: () => AddressModel.empty(),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load addresses: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Select an address
  Future<void> selectAddress(AddressModel newSelectedAddress) async {
    try {
      // Optimistically update UI
      final previousSelectedAddress = selectedAddress.value;
      selectedAddress.value = newSelectedAddress;

      // Clear the previous selected field in database
      if (previousSelectedAddress.id.isNotEmpty) {
        await addressRepository.updateSelectedField(
          previousSelectedAddress.id,
          false,
        );
      }

      // Set the new selected field to true
      await addressRepository.updateSelectedField(newSelectedAddress.id, true);

      // Update the local list
      final index = allAddresses.indexWhere(
        (e) => e.id == newSelectedAddress.id,
      );
      if (index != -1) {
        allAddresses[index].selectedAddress = true;
      }

      // Update previous address in local list
      if (previousSelectedAddress.id.isNotEmpty) {
        final prevIndex = allAddresses.indexWhere(
          (e) => e.id == previousSelectedAddress.id,
        );
        if (prevIndex != -1) {
          allAddresses[prevIndex].selectedAddress = false;
        }
      }

      allAddresses.refresh();
    } catch (e) {
      // Revert on error
      selectedAddress.value = allAddresses.firstWhere(
        (element) => element.selectedAddress,
        orElse: () => AddressModel.empty(),
      );

      Get.snackbar(
        'Error',
        'Failed to select address: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Delete an address
  Future<void> deleteAddress(String addressId) async {
    try {
      // Delete from database
      await addressRepository.deleteAddress(addressId);

      // Remove from local list
      allAddresses.removeWhere((element) => element.id == addressId);

      // If deleted address was selected, select the first one available
      if (selectedAddress.value.id == addressId) {
        if (allAddresses.isNotEmpty) {
          await selectAddress(allAddresses.first);
        } else {
          selectedAddress.value = AddressModel.empty();
        }
      }

      Get.snackbar(
        'Success',
        'Address deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete address: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Add new address
  Future<void> addNewAddress() async {
    try {
      // Validate form
      if (!addressFormKey.currentState!.validate()) {
        return;
      }

      isSaving.value = true;

      // Create address model
      final address = AddressModel(
        id: '',
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress:
            allAddresses.isEmpty, // First address is selected by default
      );

      // Add to database
      final id = await addressRepository.addAddress(address);

      // Update address with ID
      address.id = id;

      // Add to local list
      allAddresses.add(address);

      // If this is the first address or should be selected
      if (address.selectedAddress) {
        await selectAddress(address);
      }

      Get.snackbar(
        'Success',
        'Address added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 2),
      );

      // Reset and navigate back
      resetFormFields();
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add address: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Update existing address
  Future<void> updateAddress(String addressId) async {
    try {
      // Validate form
      if (!addressFormKey.currentState!.validate()) {
        return;
      }

      isSaving.value = true;

      // Create updated address model
      final address = AddressModel(
        id: addressId,
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: selectedAddress.value.id == addressId,
      );

      // Update in database
      await addressRepository.updateAddress(address);

      // Update in local list
      final index = allAddresses.indexWhere((e) => e.id == addressId);
      if (index != -1) {
        allAddresses[index] = address;
        allAddresses.refresh();
      }

      // Update selected address if it was the one being edited
      if (selectedAddress.value.id == addressId) {
        selectedAddress.value = address;
      }

      Get.snackbar(
        'Success',
        'Address updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 2),
      );

      // Reset and navigate back
      resetFormFields();
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update address: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Initialize form with existing data for editing
  void initEdit(AddressModel address) {
    name.text = address.name;
    phoneNumber.text = address.phoneNumber;
    street.text = address.street;
    postalCode.text = address.postalCode;
    city.text = address.city;
    state.text = address.state;
    country.text = address.country;
    selectedCountry.value = address.country; // Update observable too
  }

  // Reset form fields
  void resetFormFields() {
    name.clear();
    phoneNumber.clear();
    street.clear();
    postalCode.clear();
    city.clear();
    state.clear();
    country.clear();
    selectedCountry.value = ''; // Reset observable
    addressFormKey.currentState?.reset();
  }
}
