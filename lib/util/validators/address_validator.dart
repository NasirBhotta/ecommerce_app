class BValidator {
  // Validate empty field
  static String? validateEmptyField(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    // Check for minimum length
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    // Check for maximum length
    if (value.length > 50) {
      return 'Name cannot exceed 50 characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // Check if it has at least 10 digits
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    // Check if it has at most 15 digits (international format)
    if (digitsOnly.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }

    // Optional: Check for valid phone number pattern
    // This regex allows for various formats: +1234567890, (123) 456-7890, 123-456-7890, etc.
    final phoneRegex = RegExp(
      r'^[\+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,9}$',
    );
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Validate street address
  static String? validateStreet(String? value) {
    if (value == null || value.isEmpty) {
      return 'Street address is required';
    }

    if (value.length < 3) {
      return 'Street address must be at least 3 characters long';
    }

    if (value.length > 100) {
      return 'Street address cannot exceed 100 characters';
    }

    return null;
  }

  // Validate postal code
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }

    // Remove spaces and convert to uppercase for validation
    final cleanValue = value.replaceAll(' ', '').toUpperCase();

    // Check length
    if (cleanValue.length < 3) {
      return 'Postal code must be at least 3 characters';
    }

    if (cleanValue.length > 10) {
      return 'Postal code cannot exceed 10 characters';
    }

    // Allow alphanumeric postal codes (for international support)
    final postalCodeRegex = RegExp(r'^[A-Z0-9]+$');
    if (!postalCodeRegex.hasMatch(cleanValue)) {
      return 'Please enter a valid postal code';
    }

    return null;
  }

  // Validate city
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }

    if (value.length < 2) {
      return 'City must be at least 2 characters long';
    }

    if (value.length > 50) {
      return 'City cannot exceed 50 characters';
    }

    // Allow letters, spaces, hyphens, and apostrophes
    final cityRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!cityRegex.hasMatch(value)) {
      return 'City can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // Validate state/province
  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State/Province is required';
    }

    if (value.length < 2) {
      return 'State/Province must be at least 2 characters long';
    }

    if (value.length > 50) {
      return 'State/Province cannot exceed 50 characters';
    }

    // Allow letters, spaces, hyphens, and apostrophes
    final stateRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!stateRegex.hasMatch(value)) {
      return 'State/Province can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // Validate country
  static String? validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Country is required';
    }
    return null;
  }
}
