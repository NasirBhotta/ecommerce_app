import 'package:ecommerce_app/common/widgets/address_controller.dart';
import 'package:ecommerce_app/common/widgets/address_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../util/constants/sized.dart'; // Assuming you have this

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key, this.addressToEdit});

  final AddressModel? addressToEdit;

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;

    // If editing, initialize the form
    if (addressToEdit != null) {
      controller.initEdit(addressToEdit!);
    } else {
      controller.resetFormFields();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(addressToEdit != null ? 'Edit Address' : 'Add New Address'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.resetFormFields();
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24), // Or 24.0
          child: Form(
            key: controller.addressFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: controller.name,
                  validator:
                      (value) => value!.isEmpty ? 'Name is required' : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(
                  height: BSizes.spaceBetweenInputFields,
                ), // Or 16.0
                TextFormField(
                  controller: controller.phoneNumber,
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Phone Number is required' : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.mobile),
                    labelText: 'Phone Number',
                  ),
                ),
                const SizedBox(height: BSizes.spaceBetweenInputFields),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.street,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Street is required' : null,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building_31),
                          labelText: 'Street',
                        ),
                      ),
                    ),
                    const SizedBox(width: BSizes.spaceBetweenInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: controller.postalCode,
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Postal Code is required'
                                    : null,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.code),
                          labelText: 'Postal Code',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BSizes.spaceBetweenInputFields),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.city,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'City is required' : null,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building),
                          labelText: 'City',
                        ),
                      ),
                    ),
                    const SizedBox(width: BSizes.spaceBetweenInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: controller.state,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'State is required' : null,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.activity),
                          labelText: 'State',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BSizes.spaceBetweenInputFields),
                TextFormField(
                  controller: controller.country,
                  validator:
                      (value) => value!.isEmpty ? 'Country is required' : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.global),
                    labelText: 'Country',
                  ),
                ),
                const SizedBox(height: BSizes.spaceDefault),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (addressToEdit != null) {
                        controller.updateAddress(addressToEdit!.id);
                      } else {
                        controller.addNewAddresses();
                      }
                    },
                    child: const Text('Save'),
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
