import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatting utilities for currency, dates, times and inputs
class AppFormatters {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrFormatDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format an amount in INR with Indian numbering system (e.g. ₹4,999)
  static String formatCurrency(num amount, {bool showDecimals = false}) {
    if (showDecimals) {
      return _inrFormatDecimals.format(amount);
    }
    return _inrFormat.format(amount.round());
  }

  /// Format a DateTime as "Fri, 15 Nov 2026"
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  /// Format a DateTime as "15 Nov 2026"
  static String formatDateShort(DateTime? date) {
    if (date == null) return '';
    return DateFormat('d MMM yyyy').format(date);
  }

  /// Format a DateTime as "15 Nov"
  static String formatDateCompact(DateTime? date) {
    if (date == null) return '';
    return DateFormat('d MMM').format(date);
  }

  /// Format a DateTime as "HH:mm" (24h)
  static String formatTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('HH:mm').format(date);
  }

  /// Format duration in minutes to "2h 45m"
  static String formatDuration(int minutes) {
    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

/// Text input formatter that inserts spaces every 4 digits for credit/debit cards
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Text input formatter that forces uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Text input formatter for Card Expiry Date (MM/YY)
class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

