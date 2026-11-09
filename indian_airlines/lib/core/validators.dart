/// Form field validation rules for Indian Airlines booking & auth flows
class AppValidators {
  /// Required text field
  static String? requiredField(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Passenger / User Full Name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter name as on official photo ID';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    final regex = RegExp(r"^[a-zA-Z\s.'-]+$");
    if (!regex.hasMatch(trimmed)) {
      return 'Name can only contain alphabets and spaces';
    }
    return null;
  }

  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email address';
    }
    final email = value.trim();
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!regex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// 10-digit mobile phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mobile number';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-+()]'), '');
    // Support 10 digit Indian number or international with country code
    if (cleaned.length < 10 || cleaned.length > 13) {
      return 'Please enter a valid 10-digit mobile number';
    }
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Mobile number must contain digits only';
    }
    return null;
  }

  /// PNR validation: Exactly 6 alphanumeric characters
  static String? validatePnr(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter 6-character PNR';
    }
    final pnr = value.trim().toUpperCase();
    if (pnr.length != 6) {
      return 'PNR must be exactly 6 characters';
    }
    if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(pnr)) {
      return 'PNR must contain uppercase letters and numbers only';
    }
    return null;
  }

  /// Luhn algorithm check for Credit / Debit card numbers
  static bool checkLuhn(String cardNumber) {
    final digitsOnly = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (digitsOnly.length < 13 || digitsOnly.length > 19) return false;
    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) return false;

    int sum = 0;
    bool alternate = false;
    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      int n = int.parse(digitsOnly[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    return (sum % 10 == 0);
  }

  /// Card Number validator using Luhn check
  static String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter card number';
    }
    final cleaned = value.replaceAll(' ', '');
    if (cleaned.length < 13) {
      return 'Card number too short';
    }
    if (!checkLuhn(cleaned)) {
      return 'Invalid card number (checksum failed)';
    }
    return null;
  }

  /// Expiry Date MM/YY validator
  static String? validateExpiryDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter expiry (MM/YY)';
    }
    final cleaned = value.trim();
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(cleaned)) {
      return 'Enter valid date MM/YY';
    }
    final parts = cleaned.split('/');
    final month = int.parse(parts[0]);
    final year = 2000 + int.parse(parts[1]);

    final now = DateTime.now();
    // Valid until end of month
    final expiry = DateTime(year, month + 1, 0, 23, 59, 59);
    if (expiry.isBefore(now)) {
      return 'Card has expired';
    }
    return null;
  }

  /// CVV Validator (3 or 4 digits)
  static String? validateCvv(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter CVV';
    }
    final cleaned = value.trim();
    if (!RegExp(r'^\d{3,4}$').hasMatch(cleaned)) {
      return '3 or 4 digits';
    }
    return null;
  }

  /// Passport Number validation (alphanumeric, 6-9 chars)
  static String? validatePassport(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      if (required) return 'Passport number is required for international travel';
      return null;
    }
    final passport = value.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{6,12}$').hasMatch(passport)) {
      return 'Enter a valid passport number (6-12 alphanumeric characters)';
    }
    return null;
  }

  /// Password validator for auth
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

