import 'package:ecommerce_app/common/widgets/address_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/address_repository.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final street = TextEditingController();
  final postalCode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
  GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  RxBool refreshData = true.obs;
  final RxList<AddressModel> allAddresses = <AddressModel>[].obs;
  final Rx<AddressModel> selectedAddress = AddressModel.empty().obs;
  final addressRepository = Get.put(AddressRepository());

  @override
  void onInit() {
    super.onInit();
    getAllUserAddresses();
  }

  // Fetch all user specific addresses
  Future<List<AddressModel>> getAllUserAddresses() async {
    try {
      final addresses = await addressRepository.fetchUserAddresses();
      allAddresses.assignAll(addresses);
      selectedAddress.value = addresses.firstWhere(
        (element) => element.selectedAddress,
        orElse: () => AddressModel.empty(),
      );
      return addresses;
    } catch (e) {
      Get.snackbar('Error', 'Address not found! $e');
      return [];
    }
  }

  Future<void> selectAddress(AddressModel newSelectedAddress) async {
    try {
      // Clear the "selected" field
      if (selectedAddress.value.id.isNotEmpty) {
        await addressRepository.updateSelectedField(
          selectedAddress.value.id,
          false,
        );
      }

      // Assign selected address
      newSelectedAddress.selectedAddress = true;
      selectedAddress.value = newSelectedAddress;

      // Set the "selected" field to true for the newly selected address
      await addressRepository.updateSelectedField(
        selectedAddress.value.id,
        true,
      );
    } catch (e) {
      Get.snackbar('Error', 'Error in Selection: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await addressRepository.deleteAddress(addressId);
      allAddresses.removeWhere((element) => element.id == addressId);
      // If deleted address was selected, select the first one available or none
      if (selectedAddress.value.id == addressId) {
        if (allAddresses.isNotEmpty) {
          selectAddress(allAddresses.first);
        } else {
          selectedAddress.value = AddressModel.empty();
        }
      }
      Get.snackbar('Success', 'Address deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Could not delete address: $e');
    }
  }

  // Add new Address (Modified to handle both Add and Update if needed, though usually separated)
  Future<void> addNewAddresses() async {
    try {
      // Start Loading
      // TFullScreenLoader.openLoadingDialog('Storing Address...', 'assets/animations/loader.json');

      // Check Internet Connectivity
      // final isConnected = await NetworkManager.instance.isConnected();
      // if (!isConnected) { TFullScreenLoader.stopLoading(); return; }

      // Form Validation
      if (!addressFormKey.currentState!.validate()) {
        // TFullScreenLoader.stopLoading();
        return;
      }

      // Save Address Data
      final address = AddressModel(
        id: '',
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: true,
      );

      // Add to DB
      final id = await addressRepository.addAddress(address);

      // Update Selected Address status
      address.id = id;
      allAddresses.add(address);
      await selectAddress(address);

      // Remove Loader
      // TFullScreenLoader.stopLoading();

      // Show Success Message
      Get.snackbar('Success', 'Your address has been saved successfully.');

      // Refresh Addresses Data
      refreshData.toggle();

      // Reset fields
      resetFormFields();

      // Redirect
      Navigator.of(Get.context!).pop();
    } catch (e) {
      // TFullScreenLoader.stopLoading();
      Get.snackbar('Error', 'Address not saved: $e');
    }
  }

  // Update existing address
  Future<void> updateAddress(String addressId) async {
    try {
      if (!addressFormKey.currentState!.validate()) return;

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

      await addressRepository.updateAddress(address);

      // Update local list
      final index = allAddresses.indexWhere((e) => e.id == addressId);
      if (index != -1) {
        allAddresses[index] = address;
        allAddresses.refresh(); // Notify listeners
      }

      Get.snackbar('Success', 'Address updated successfully.');
      resetFormFields();
      Navigator.of(Get.context!).pop();
    } catch (e) {
      Get.snackbar('Error', 'Address not updated: $e');
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
  }

  void resetFormFields() {
    name.clear();
    phoneNumber.clear();
    street.clear();
    postalCode.clear();
    city.clear();
    state.clear();
    country.clear();
    addressFormKey.currentState?.reset();
  }
}
