import 'package:ecommerce_app/features/shop/models/address_model.dart';
import 'package:ecommerce_app/common/widgets/full_width_elevated_button.dart';
import 'package:ecommerce_app/util/constants/address_constants.dart';
import 'package:ecommerce_app/util/validators/address_validator.dart';
import 'package:ecommerce_app/common/widgets/settings/b_text_form.dart';
import 'package:ecommerce_app/common/widgets/settings/dropdown_field.dart';
import 'package:ecommerce_app/features/shop/controllers/addresses_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key, this.addressToEdit});

  final AddressModel? addressToEdit;

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize form for editing or reset for new address
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (addressToEdit != null) {
        controller.initEdit(addressToEdit!);
      } else {
        controller.resetFormFields();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.resetFormFields();
            Get.back();
          },
        ),
        title: Text(
          addressToEdit != null ? 'Edit Address' : 'Add New Address',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(BSizes.paddingLg),
          child: Form(
            key: controller.addressFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: BSizes.spaceBetweenItems),

                // Name Field
                BTextFormField(
                  controller: controller.name,
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Iconsax.user,
                  textCapitalization: TextCapitalization.words,
                  validator: BValidator.validateName,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      BAddressConstants.maxNameLength,
                    ),
                  ],
                ),
                const SizedBox(height: BSizes.spaceBetweenInputFields),

                // Phone Number Field
                BTextFormField(
                  controller: controller.phoneNumber,
                  labelText: 'Phone Number',
                  hintText: '+1 234 567 8900',
                  prefixIcon: Iconsax.call,
                  keyboardType: TextInputType.phone,
                  validator: BValidator.validatePhoneNumber,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[\d\s\+\-\(\)]'),
                    ),
                    LengthLimitingTextInputFormatter(
                      20,
                    ), // Allow formatting chars
                  ],
                ),
                const SizedBox(height: BSizes.spaceBetweenSections),

                // Address Section Header
                Text(
                  'Address Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: BSizes.spaceBetweenItems),

                // Street Field
                BTextFormField(
                  controller: controller.street,
                  labelText: 'Street Address',
                  hintText: '123 Main Street, Apt 4B',
                  prefixIcon: Iconsax.building_31,
                  textCapitalization: TextCapitalization.words,
                  validator: BValidator.validateStreet,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      BAddressConstants.maxStreetLength,
                    ),
                  ],
                ),
                const SizedBox(height: BSizes.spaceBetweenInputFields),

                // City and Postal Code Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: BTextFormField(
                        controller: controller.city,
                        labelText: 'City',
                        hintText: 'New York',
                        prefixIcon: Iconsax.building,
                        textCapitalization: TextCapitalization.words,
                        validator: BValidator.validateCity,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            BAddressConstants.maxCityLength,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: BSizes.spaceBetweenInputFields),
                    Expanded(
                      child: BTextFormField(
                        controller: controller.postalCode,
                        labelText: 'Postal Code',
                        hintText: '10001',
                        prefixIcon: Iconsax.code,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        validator: BValidator.validatePostalCode,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9\s]'),
                          ),
                          LengthLimitingTextInputFormatter(
                            BAddressConstants.maxPostalCodeLength,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BSizes.spaceBetweenInputFields),

                // State Field
                BTextFormField(
                  controller: controller.state,
                  labelText: 'State / Province',
                  hintText: 'California',
                  prefixIcon: Iconsax.activity,
                  textCapitalization: TextCapitalization.words,
                  validator: BValidator.validateState,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      BAddressConstants.maxStateLength,
                    ),
                  ],
                ),
                const SizedBox(height: BSizes.spaceBetweenInputFields),

                // Country Dropdown
                Obx(
                  () => BDropdownFormField<String>(
                    value:
                        controller.selectedCountry.value.isNotEmpty
                            ? controller.selectedCountry.value
                            : null,
                    items: BAddressConstants.getCountriesWithPopularFirst(),
                    labelText: 'Country',
                    hintText: 'Select your country',
                    prefixIcon: Iconsax.global,
                    itemLabel: (country) => country,
                    onChanged: (value) {
                      if (value != null && value != '---') {
                        controller.country.text = value;
                      }
                    },
                    validator: BValidator.validateCountry,
                  ),
                ),
                const SizedBox(height: BSizes.spaceBetweenSections),

                // Save Button
                Obx(
                  () => BFullWidthButton(
                    onPressed: () {
                      if (addressToEdit != null) {
                        controller.updateAddress(addressToEdit!.id);
                      } else {
                        controller.addNewAddress();
                      }
                    },
                    text:
                        addressToEdit != null
                            ? 'Update Address'
                            : 'Save Address',
                    isLoading: controller.isSaving.value,
                  ),
                ),

                // Help Text
                const SizedBox(height: BSizes.spaceBetweenItems),
                Center(
                  child: Text(
                    'This address will be used for delivery',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          isDark ? Colors.white.withOpacity(0.6) : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
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



/// screen completed