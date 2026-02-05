class ValidationHelper {
  /// Validates username (4-20 characters)
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 4) {
      return 'Username must be at least 4 characters';
    }
    if (value.length > 20) {
      return 'Username must be at most 20 characters';
    }
    return null;
  }

  /// Validates email (must contain @ and .com)
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Email must contain @';
    }
    if (!value.contains('.com')) {
      return 'Email must end with .com';
    }
    // Basic email format check
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.com$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email (e.g., johndoe@gmail.com)';
    }
    return null;
  }

  /// Validates contact number (8 digits, must start with 5)
  static String? validateContactNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contact number is required';
    }
    // Remove any non-digit characters
    final cleanedValue = value.replaceAll(RegExp(r'\D'), '');

    if (cleanedValue.length != 8) {
      return 'Invalid number';
    }
    if (!cleanedValue.startsWith('5')) {
      return 'Invalid number';
    }
    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(cleanedValue)) {
      return 'Invalid number';
    }
    return null;
  }

  /// Validates password (8-15 characters, alphanumerical)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (value.length > 15) {
      return 'Password must be at most 15 characters';
    }
    // Check if password is alphanumerical (letters and numbers only)
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Password must contain only letters and numbers';
    }
    return null;
  }

  /// Validates name (non-empty)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}
