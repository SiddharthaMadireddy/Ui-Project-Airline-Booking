import 'package:flutter_test/flutter_test.dart';
import 'package:indian_airlines/core/validators.dart';
import 'package:indian_airlines/services/pnr_generator.dart';

void main() {
  group('Validators & PNR Tests', () {
    test('PNR generator outputs 6-character alphanumeric code starting with IA', () {
      for (int i = 0; i < 20; i++) {
        final pnr = PnrGenerator.generate();
        expect(pnr.length, equals(6));
        expect(pnr.startsWith('IA'), isTrue);
        expect(RegExp(r'^[A-Z0-9]{6}$').hasMatch(pnr), isTrue);
      }
    });

    test('validatePnr accepts valid 6-char PNR and rejects invalid', () {
      expect(AppValidators.validatePnr('IA7K9P'), isNull);
      expect(AppValidators.validatePnr(''), isNotNull);
      expect(AppValidators.validatePnr('IA7K9'), isNotNull); // 5 chars
      expect(AppValidators.validatePnr('IA7K9P9'), isNotNull); // 7 chars
    });

    test('Luhn algorithm correctly validates credit card numbers', () {
      // Standard valid Visa test card numbers
      expect(AppValidators.checkLuhn('4532015112830366'), isTrue);
      // Altered last digit should fail
      expect(AppValidators.checkLuhn('4532015112830367'), isFalse);
    });

    test('validateEmail handles valid and malformed addresses', () {
      expect(AppValidators.validateEmail('user@example.com'), isNull);
      expect(AppValidators.validateEmail('invalid-email'), isNotNull);
      expect(AppValidators.validateEmail('user@domain'), isNotNull);
      expect(AppValidators.validateEmail(''), isNotNull);
    });

    test('validatePhone validates 10-digit mobile numbers', () {
      expect(AppValidators.validatePhone('9876543210'), isNull);
      expect(AppValidators.validatePhone('12345'), isNotNull); // Too short
      expect(AppValidators.validatePhone('98765abcde'), isNotNull); // Letters
    });

    test('validateExpiryDate handles MM/YY formats and expired cards', () {
      expect(AppValidators.validateExpiryDate('12/28'), isNull); // Future
      expect(AppValidators.validateExpiryDate('01/20'), isNotNull); // Past (expired)
      expect(AppValidators.validateExpiryDate('13/28'), isNotNull); // Invalid month
      expect(AppValidators.validateExpiryDate('1228'), isNotNull); // Missing slash
    });

    test('validateCvv checks 3 or 4 digits', () {
      expect(AppValidators.validateCvv('123'), isNull);
      expect(AppValidators.validateCvv('1234'), isNull);
      expect(AppValidators.validateCvv('12'), isNotNull);
      expect(AppValidators.validateCvv('12a'), isNotNull);
    });
  });
}

