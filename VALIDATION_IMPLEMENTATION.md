# Login & Registration Validation Implementation

## Overview
Comprehensive validation has been added to both Login and Registration screens with real-time error display.

## Validation Rules Implemented

### 1. **Username Validation**
- **Length**: 4-20 characters
- **Error Messages**:
  - "Username is required" (if empty)
  - "Username must be at least 4 characters" (if too short)
  - "Username must be at most 20 characters" (if too long)

### 2. **Email Validation**
- **Requirements**: Must contain "@" and ".com"
- **Format**: `username@domain.com` (e.g., johndoe@gmail.com)
- **Error Messages**:
  - "Email is required" (if empty)
  - "Email must contain @" (if @ is missing)
  - "Email must end with .com" (if .com is missing)
  - "Please enter a valid email (e.g., johndoe@gmail.com)" (if format is invalid)

### 3. **Contact Number Validation**
- **Length**: Exactly 8 digits
- **Requirement**: Must always start with digit "5"
- **Format**: Numeric only (non-numeric characters are stripped)
- **Error Messages**:
  - "Contact number is required" (if empty)
  - "Invalid number" (if not 8 digits)
  - "Invalid number" (if doesn't start with 5)

### 4. **Password Validation**
- **Length**: 8-15 characters
- **Character Type**: Alphanumerical (letters A-Z, a-z and numbers 0-9 only)
- **Error Messages**:
  - "Password is required" (if empty)
  - "Password must be at least 8 characters" (if too short)
  - "Password must be at most 15 characters" (if too long)
  - "Password must contain only letters and numbers" (if special characters present)

### 5. **Name Validation** (Registration only)
- **Requirements**: Non-empty, minimum 2 characters
- **Error Messages**:
  - "Name is required" (if empty)
  - "Name must be at least 2 characters" (if too short)

## Files Modified/Created

### Created:
- **[lib/features/auth/validators.dart](lib/features/auth/validators.dart)** - Contains `ValidationHelper` class with all validation methods

### Modified:
- **[lib/features/auth/login_screen.dart](lib/features/auth/login_screen.dart)**
  - Added import for validators
  - Added error state variables (`_usernameError`, `_passwordError`)
  - Updated `_login()` method to validate before submission
  - Enhanced UI with real-time error display and border color changes

- **[lib/features/auth/signup_screen.dart](lib/features/auth/signup_screen.dart)**
  - Added import for validators
  - Added error state variables for all fields
  - Updated `_signup()` method to validate all fields before submission
  - Enhanced all form fields with real-time validation and error display

## Features

### Real-time Validation
- Errors are displayed as users type in each field
- Text field borders turn red when there's an error
- Error messages appear below invalid fields

### Error Display
- Inline error messages with red text (12px font size)
- Dynamic border color changes based on validation state
- Error messages remain visible until the input is corrected

### User Experience
- Validation occurs on field change (`onChanged` callback)
- Submit button validation occurs on click
- Clear, descriptive error messages guide users
- All validations prevent form submission until resolved

## Usage Example

```dart
// Import the validation helper
import 'validators.dart';

// Validate a field
String? error = ValidationHelper.validateUsername(inputValue);
if (error != null) {
  // Handle error
}
```

## Testing the Validation

### Valid Login Examples:
- Username: `john_doe` (8 characters) + Password: `Pass1234` (8 characters, alphanumeric)
- Username: `admin123` (8 characters) + Password: `Admin@123` ❌ (special character not allowed)

### Valid Registration Examples:
- Username: `john_doe` (8 chars) + Name: `John Doe` + Email: `johndoe@gmail.com` + Phone: `50123456` (starts with 5) + Password: `Pass1234`

### Invalid Examples:
- Username: `joe` ❌ (only 3 characters, needs 4+)
- Email: `john@domain.co` ❌ (must end with .com)
- Phone: `40123456` ❌ (doesn't start with 5)
- Password: `pass` ❌ (only 4 characters, needs 8+)
- Password: `Pass@1234` ❌ (contains special character @)
