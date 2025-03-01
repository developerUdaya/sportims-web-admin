import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String newString = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (newString.length > 8) {
      // Limit to 8 digits, with 2 hyphens, making total 10 characters
      return oldValue;
    }

    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < newString.length; i++) {
      if (i == 2 || i == 4) buffer.write('-');
      buffer.write(newString[i]);
    }

    // Add leading zeros if needed
    final String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: newValue.selection.copyWith(
        baseOffset: formatted.length,
        extentOffset: formatted.length,
      ),
    );
  }
}
